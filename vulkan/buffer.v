module vulkan

// ============================================================================
// Buffer — GPU memory buffer abstraction
//
// Mirrors vsl/vcl/buffer.c.v pattern:
//   - Device owns GpuBuffer; GpuBuffer holds reference back to Device
//   - Synchronous upload/download
//   - Automatic memory binding
// ============================================================================

// GpuBuffer is a GPU memory buffer allocated on a Vulkan Device.
pub struct GpuBuffer {
pub:
	size   DeviceSize
	device &Device
mut:
	buf VkBuffer
	mem VkDeviceMemory
}

// buffer allocates a new GPU storage buffer on the given device.
pub fn (d &Device) buffer(size DeviceSize) !&GpuBuffer {
	if size == 0 {
		return error('vulkan: buffer size must be > 0')
	}

	// 1. Create buffer
	info := C.VkBufferCreateInfo{
		sType:       structure_type_buffer_create_info
		size:        size
		usage:       buffer_usage_storage_buffer_bit
		sharingMode: u32(0) // VK_SHARING_MODE_EXCLUSIVE
	}
	mut buf := VkBuffer(unsafe { nil })
	mut res := vk_create_buffer(d.device, &info, unsafe { nil }, &buf)
	if res != result_success {
		return error('vulkan: vkCreateBuffer failed: ${res.str()}')
	}

	// 2. Query memory requirements
	mut reqs := C.VkMemoryRequirements{}
	vk_get_memory_requirements(d.device, buf, &reqs)

	// 3. Find a memory type that is HOST_VISIBLE | HOST_COHERENT
	mem_type := find_memory_type(d.physical_device, reqs.memoryTypeBits,
		memory_property_host_visible_bit | memory_property_host_coherent_bit) or {
		vk_destroy_buffer(d.device, buf, unsafe { nil })
		return err
	}

	// 4. Allocate device memory
	mem_info := C.VkMemoryAllocateInfo{
		sType:           structure_type_memory_allocate_info
		allocationSize:  reqs.size
		memoryTypeIndex: mem_type
	}
	mut mem := VkDeviceMemory(unsafe { nil })
	res = vk_allocate_memory(d.device, &mem_info, unsafe { nil }, &mem)
	if res != result_success {
		vk_destroy_buffer(d.device, buf, unsafe { nil })
		return error('vulkan: vkAllocateMemory failed: ${res.str()}')
	}

	// 5. Bind buffer to memory
	res = vk_bind_buffer_memory(d.device, buf, mem, DeviceSize(0))
	if res != result_success {
		vk_destroy_buffer(d.device, buf, unsafe { nil })
		vk_free_memory(d.device, mem, unsafe { nil })
		return error('vulkan: vkBindBufferMemory failed: ${res.str()}')
	}

	return &GpuBuffer{
		size:   size
		device: d
		buf:    buf
		mem:    mem
	}
}

// release frees the GPU buffer memory and Vulkan buffer handle.
pub fn (b &GpuBuffer) release() {
	if isnil(b.device) {
		return
	}
	vk_device_wait_idle(b.device.device)
	vk_free_memory(b.device.device, b.mem, unsafe { nil })
	vk_destroy_buffer(b.device.device, b.buf, unsafe { nil })
}

// load copies data from host to GPU buffer synchronously.
pub fn (b &GpuBuffer) load(data []u8) ! {
	if DeviceSize(data.len) != b.size {
		return error('vulkan: buffer size mismatch: expected ${b.size}, got ${data.len}')
	}
	mut ptr := voidptr(unsafe { nil })
	res := vk_map_memory(b.device.device, b.mem, DeviceSize(0), b.size, 0, &ptr)
	if res != result_success {
		return error('vulkan: vkMapMemory failed: ${res.str()}')
	}
	unsafe { C.memcpy(ptr, data.data, b.size) }
	vk_unmap_memory(b.device.device, b.mem)
}

// store reads data from GPU buffer to host memory synchronously.
pub fn (b &GpuBuffer) store(mut data []u8) ![]u8 {
	if b.size == 0 {
		return []
	}
	mut ptr := voidptr(unsafe { nil })
	mut res := vk_map_memory(b.device.device, b.mem, DeviceSize(0), b.size, 0, &ptr)
	if res != result_success {
		return error('vulkan: vkMapMemory failed: ${res.str()}')
	}

	// Flush mapped memory (ensure device writes are visible)
	range := C.VkMappedMemoryRange{
		sType:  structure_type_mapped_memory_range
		memory: b.mem
		offset: DeviceSize(0)
		size:   vk_whole_size
	}
	res = vk_flush_mapped_memory_ranges(b.device.device, 1, &range)
	if res != result_success {
		vk_unmap_memory(b.device.device, b.mem)
		return error('vulkan: vkFlushMappedMemoryRanges failed: ${res.str()}')
	}

	if data.len < int(b.size) {
		data = []u8{len: int(b.size)}
	}
	unsafe { C.memcpy(data.data, ptr, b.size) }
	vk_unmap_memory(b.device.device, b.mem)
	return data[..int(b.size)]
}

// --------------------------------------------------------------------------
// Internal helpers
// --------------------------------------------------------------------------

// vk_whole_size is a special value meaning "map the entire memory allocation".
const vk_whole_size = DeviceSize(u64(0xffffffffffffffff))

fn find_memory_type(gpu VkPhysicalDevice, type_bits u32, required MemoryPropertyFlags) !u32 {
	mut mem_props := C.VkPhysicalDeviceMemoryProperties{}
	vk_get_physical_device_memory_properties(gpu, &mem_props)
	for i := u32(0); i < mem_props.memoryTypeCount; i++ {
		if (type_bits & (1 << i)) != 0
			&& (mem_props.memoryTypes[i].propertyFlags & required) == required {
			return i
		}
	}
	return error('vulkan: no suitable memory type found (required flags: ${required})')
}
