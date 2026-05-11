module vulkan

// ============================================================================
// Device — Vulkan compute device abstraction
//
// Mirrors the VCL Device pattern from vsl/vcl/device.c.v:
//   - Abstracts instance, physical device, logical device, queue, cmdpool
//   - Manages device lifecycle (create, destroy)
//   - Provides compute queue discovery
// ============================================================================

// Device is the main Vulkan compute device handle.
// Mirrors vsl.vcl.Device — owns all Vulkan handles and resources.
@[heap]
pub struct Device {
pub:
	instance           VkInstance
	physical_device    VkPhysicalDevice
	device             VkDevice
	queue              VkQueue
	queue_family_index u32
mut:
	cmd_pool VkCommandPool
	// cached resources
	buffers []VkBuffer
	memory  []VkDeviceMemory
	// pipeline cache keyed by pipeline type
	pipeline_cache map[PipelineType]&ComputePipeline
}

// new_device finds a physical device with a compute queue and creates a Device.
pub fn new_device() !&Device {
	// 1. Create Vulkan instance
	inst := create_instance()!

	// 2. Find a physical device with a compute queue
	gpu := find_compute_gpu(inst) or {
		vk_destroy_instance(inst, unsafe { nil })
		return error('vulkan: no GPU found with compute support')
	}

	// 3. Find the compute queue family index
	qfi := find_compute_queue_family(gpu) or {
		vk_destroy_instance(inst, unsafe { nil })
		return error('vulkan: no compute queue family found')
	}

	// 4. Create logical device + queue
	dev, queue := create_device(gpu, qfi) or {
		vk_destroy_instance(inst, unsafe { nil })
		return error('vulkan: failed to create device: ${err}')
	}

	// 5. Create command pool
	cmd_pool := create_command_pool(dev, qfi) or {
		vk_destroy_device(dev, unsafe { nil })
		vk_destroy_instance(inst, unsafe { nil })
		return error('vulkan: failed to create command pool: ${err}')
	}

	// Create device object and set module-level reference so ops
	// (vector_add, scale, etc.) can find the device without explicit plumbing.
	mut dev_obj := &Device{
		instance:           inst
		physical_device:    gpu
		device:             dev
		queue:              queue
		queue_family_index: qfi
		cmd_pool:           cmd_pool
	}
	return dev_obj
	// NOTE: Instance is NOT destroyed here — Device.release() handles all
	// cleanup. Do NOT add a defer that destroys inst (it would leave the
	// returned Device holding a dangling handle).
}

// release destroys the logical device, all buffers/memory, and the instance.
pub fn (mut d Device) release() ! {
	// Wait for all pending operations on this device
	res := vk_device_wait_idle(d.device)
	if res != result_success {
		return error('vulkan: vkDeviceWaitIdle failed: ${res.str()}')
	}

	// Free cached pipelines
	for _, mut pl in d.pipeline_cache {
		pl.release()
	}

	// Free command pool
	vk_destroy_command_pool(d.device, d.cmd_pool, unsafe { nil })

	// Free memory
	for mem in d.memory {
		vk_free_memory(d.device, mem, unsafe { nil })
	}

	// Destroy buffers
	for buf in d.buffers {
		vk_destroy_buffer(d.device, buf, unsafe { nil })
	}

	// Destroy logical device
	vk_destroy_device(d.device, unsafe { nil })

	// Destroy instance
	vk_destroy_instance(d.instance, unsafe { nil })
}

// gpu_name returns the human-readable GPU name from the physical device.
pub fn (d &Device) gpu_name() string {
	mut props := C.VkPhysicalDeviceProperties{}
	vk_get_physical_device_properties(d.physical_device, &props)
	// Extract null-terminated string from fixed-size char array
	mut name := ''
	for c in props.deviceName {
		if c == 0 {
			break
		}
		name += c.ascii_str()
	}
	return name
}

// device_type returns a human-readable GPU vendor/type string.
pub fn (d &Device) device_type() string {
	mut props := C.VkPhysicalDeviceProperties{}
	vk_get_physical_device_properties(d.physical_device, &props)
	return device_type_name(props.deviceType)
}

// str returns a summary string for the device.
pub fn (d &Device) str() string {
	return 'vulkan.Device{ gpu: ${d.gpu_name()} (${d.device_type()}), qfi: ${d.queue_family_index} }'
}

// --------------------------------------------------------------------------
// Internal helpers
// --------------------------------------------------------------------------

fn create_instance() !VkInstance {
	$if prod {
		return create_instance_plain()
	} $else {
		return create_instance_debug()
	}
}

// device_type_name returns a human-readable string for a VkPhysicalDeviceType integer.
fn device_type_name(dtype u32) string {
	return match dtype {
		1 { 'Other' }
		2 { 'Integrated GPU' }
		3 { 'Discrete GPU' }
		4 { 'Virtual GPU' }
		5 { 'CPU' }
		else { 'Unknown' }
	}
}

// device_type_priority returns a sort key for GPU selection (lower = more preferred).
// Discrete GPU → 0, Integrated GPU → 1, Virtual GPU → 2, Other → 3, CPU → 4.
fn device_type_priority(dtype u32) int {
	return match dtype {
		3 { 0 } // VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU
		2 { 1 } // VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
		4 { 2 } // VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU
		1 { 3 } // VK_PHYSICAL_DEVICE_TYPE_OTHER
		5 { 4 } // VK_PHYSICAL_DEVICE_TYPE_CPU
		else { 5 }
	}
}

fn gpu_name_from_props(props C.VkPhysicalDeviceProperties) string {
	mut name := ''
	for c in props.deviceName {
		if c == 0 {
			break
		}
		name += c.ascii_str()
	}
	return name
}

fn physical_has_compute_queue(gpu VkPhysicalDevice) bool {
	mut count := u32(0)
	vk_get_physical_device_queue_family_properties(gpu, &count, unsafe { nil })
	if count == 0 {
		return false
	}
	mut families := unsafe { []C.VkQueueFamilyProperties{len: int(count)} }
	vk_get_physical_device_queue_family_properties(gpu, &count, unsafe { &families[0] })
	for i := u32(0); i < count; i++ {
		if (families[i].queueFlags & queue_compute_bit) != 0 {
			return true
		}
	}
	return false
}

fn find_compute_gpu(inst VkInstance) !VkPhysicalDevice {
	mut count := u32(0)
	mut res := vk_enumerate_physical_devices(inst, &count, unsafe { nil })
	if res != result_success && res != result_incomplete {
		return error('vulkan: vkEnumeratePhysicalDevices failed: ${res.str()}')
	}
	if count == 0 {
		return error('vulkan: no physical devices found')
	}
	mut devs := unsafe { []VkPhysicalDevice{len: int(count)} }
	res = vk_enumerate_physical_devices(inst, &count, unsafe { &devs[0] })
	if res != result_success {
		return error('vulkan: vkEnumeratePhysicalDevices (2nd) failed: ${res.str()}')
	}

	mut best := VkPhysicalDevice(unsafe { nil })
	mut best_priority := 999
	mut best_name := ''
	mut best_dtype := u32(0)

	for i := 0; i < int(count); i++ {
		gpu := devs[i]
		if !physical_has_compute_queue(gpu) {
			continue
		}
		mut props := C.VkPhysicalDeviceProperties{}
		vk_get_physical_device_properties(gpu, &props)
		prio := device_type_priority(props.deviceType)
		if prio < best_priority {
			best_priority = prio
			best = gpu
			best_name = gpu_name_from_props(props)
			best_dtype = props.deviceType
		}
	}

	if best == VkPhysicalDevice(unsafe { nil }) {
		return error('vulkan: no GPU with compute support found')
	}

	eprintln('vulkan: selected ${best_name} (${device_type_name(best_dtype)})')
	return best
}

fn find_compute_queue_family(gpu VkPhysicalDevice) !u32 {
	mut count := u32(0)
	vk_get_physical_device_queue_family_properties(gpu, &count, unsafe { nil })
	if count == 0 {
		return error('vulkan: no queue families found')
	}
	mut families := unsafe { []C.VkQueueFamilyProperties{len: int(count)} }
	vk_get_physical_device_queue_family_properties(gpu, &count, unsafe { &families[0] })
	for i := u32(0); i < count; i++ {
		if (families[i].queueFlags & queue_compute_bit) != 0 {
			return i
		}
	}
	return error('vulkan: no compute queue family found')
}

fn create_device(gpu VkPhysicalDevice, qfi u32) !(VkDevice, VkQueue) {
	mut dev := VkDevice(unsafe { nil })
	mut queue := VkQueue(unsafe { nil })
	vk_create_device_simple(gpu, qfi, &dev, &queue)!
	return dev, queue
}

fn create_command_pool(dev VkDevice, qfi u32) !VkCommandPool {
	info := C.VkCommandPoolCreateInfo{
		sType:            structure_type_command_pool_create_info
		queueFamilyIndex: qfi
	}
	mut pool := VkCommandPool(unsafe { nil })
	res := vk_create_command_pool(dev, &info, unsafe { nil }, &pool)
	if res != result_success {
		return error('vulkan: vkCreateCommandPool failed: ${res.str()}')
	}
	return pool
}
