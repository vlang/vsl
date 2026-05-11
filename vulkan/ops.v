module vulkan

// ============================================================================
// Linear algebra operations on Vulkan GPU
//
// Provides GPU-accelerated BLAS-style operations. All ops are blocking
// (synchronous) for simplicity.
//
// Operations:
//   vector_add(dst, a, b)           dst[i] = a[i] + b[i]
//   scale(dst, src, alpha)          dst[i] = alpha * src[i]
//   gemv(y, A, x, m, n)            y[m] = A[m,n] * x[n] (row-major)
//   sum(buf)                        returns sum of all f32 elements
//   relu(dst, src)                  dst[i] = max(0, src[i])
//   sigmoid(dst, src)              dst[i] = 1/(1+exp(-src[i]))
// ============================================================================

// Module-level device reference for pipeline dispatch.
// Set by pipeline_get() and used by submit_and_wait() / current_device().
__global g_last_dev = &Device(unsafe { nil })

// pipeline_cache maps type -> compiled pipeline.
// Module-level to avoid recompiling shaders on every op.
__global pipeline_cache = map[PipelineType]&ComputePipeline{}

// vector_add computes element-wise addition: dst = a + b
pub fn vector_add(dst &GpuBuffer, a &GpuBuffer, b &GpuBuffer) ! {
	pl := pipeline_get(.vector_add)!
	pl.update_buffer(0, a)!
	pl.update_buffer(1, b)!
	pl.update_buffer(2, dst)!
	dispatch_sync(pl, u32(dst.size / 4), 1, 1)!
}

// scale computes dst = alpha * src
pub fn scale(dst &GpuBuffer, src &GpuBuffer, alpha f32) ! {
	pl := pipeline_get(.scale)!
	// Upload alpha as a small GPU buffer (binding 3)
	mut abuf := pl.device.buffer(DeviceSize(4))!
	defer {
		abuf.release()
	}
	// Create byte representation of alpha
	mut alpha_bytes := []u8{len: 4}
	unsafe {
		*(&f32(&alpha_bytes[0])) = alpha
	}
	abuf.load(alpha_bytes)!
	pl.update_buffer(0, src)!
	pl.update_buffer(2, dst)!
	pl.update_buffer(3, abuf)!
	dispatch_sync(pl, u32(dst.size / 4), 1, 1)!
}

// gemv computes y = A * x (row-major: A[i*n + j])
pub fn gemv(y &GpuBuffer, a &GpuBuffer, x &GpuBuffer, m int, n int) ! {
	pl := pipeline_get(.gemv)!
	pl.update_buffer(1, a)!
	pl.update_buffer(2, x)!
	pl.update_buffer(3, y)!
	dispatch_sync(pl, u32(m), 1, 1)!
}

// sum computes the sum of all f32 elements in the buffer.
pub fn sum(buf &GpuBuffer) !f32 {
	n := int(buf.size / 4)
	workgroup_size := 256
	num_groups := (n + workgroup_size - 1) / workgroup_size
	mut scratch := buf.device.buffer(DeviceSize(num_groups * 4))!
	defer {
		scratch.release()
	}
	pl := pipeline_get(.reduce_sum)!
	pl.update_buffer(0, buf)!
	pl.update_buffer(2, scratch)!
	dispatch_sync(pl, u32(num_groups), 1, 1)!
	mut partial := []f32{len: num_groups}
	// Read back partial sums
	mut raw := []u8{len: num_groups * 4}
	raw = scratch.store(mut raw)!
	for i in 0 .. num_groups {
		unsafe {
			partial[i] = *(&f32(&raw[i * 4]))
		}
	}
	mut total := f32(0.0)
	for v in partial {
		total += v
	}
	return total
}

// relu computes dst[i] = max(0, src[i])
pub fn relu(dst &GpuBuffer, src &GpuBuffer) ! {
	pl := pipeline_get(.relu)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	dispatch_sync(pl, u32(src.size / 4), 1, 1)!
}

// sigmoid computes dst[i] = 1/(1+exp(-src[i]))
pub fn sigmoid(dst &GpuBuffer, src &GpuBuffer) ! {
	pl := pipeline_get(.sigmoid)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	dispatch_sync(pl, u32(src.size / 4), 1, 1)!
}

// gemm computes C = A * B (row-major, f32) on GPU.
// A: [M x K] row-major, B: [K x N] row-major, C: [M x N] row-major.
// All buffers must be f32 GpuBuffers.
pub fn gemm(dst &GpuBuffer, a &GpuBuffer, b &GpuBuffer, m u32, n u32, k u32) ! {
	// Create small params buffer with [M, N, K]
	mut params_buf := dst.device.buffer(DeviceSize(12))!
	defer { params_buf.release() }
	mut params_bytes := []u8{len: 12}
	unsafe {
		*(&u32(&params_bytes[0])) = m
		*(&u32(&params_bytes[4])) = n
		*(&u32(&params_bytes[8])) = k
	}
	params_buf.load(params_bytes)!

	pl := pipeline_get(.gemm)!
	pl.update_buffer(0, a)!
	pl.update_buffer(1, b)!
	pl.update_buffer(2, dst)!
	pl.update_buffer(3, params_buf)!
	dispatch_sync(pl, m, n, 1)!
}

// dispatch_sync submits a 3D compute dispatch and waits for completion.
// global_x, global_y, global_z = total work items (not workgroups).
// The function divides by WORKGROUP_SIZE_X to compute workgroup counts.
pub fn dispatch_sync(pl &ComputePipeline, global_x u32, global_y u32, global_z u32) ! {
	mut cmd := alloc_cmd_buffer(pl.device)!
	defer {
		vk_free_command_buffers(pl.device.device, pl.device.cmd_pool, 1, &cmd)
	}

	// Begin command buffer
	begin_info := C.VkCommandBufferBeginInfo{
		sType: structure_type_command_buffer_begin_info
	}
	mut res := vk_begin_command_buffer(cmd, &begin_info)
	if res != result_success {
		return error('vulkan: vkBeginCommandBuffer failed: ${res.str()}')
	}

	// Pipeline barrier: ensure host writes are visible to compute shader
	barrier := C.VkMemoryBarrier{
		sType:         structure_type_memory_barrier
		srcAccessMask: access_host_write_bit
		dstAccessMask: access_shader_read_bit
	}
	vk_cmd_pipeline_barrier(cmd, pipeline_stage_host_bit, pipeline_stage_compute_shader_bit,
		0, 1, &barrier, 0, unsafe { nil }, 0, unsafe { nil })

	// Bind compute pipeline
	vk_cmd_bind_pipeline(cmd, pipeline_bind_point_compute, pl.pipeline_handle)

	// Bind descriptor sets
	vk_cmd_bind_descriptor_sets(cmd, pipeline_bind_point_compute, pl.layout,
		0, 1, &pl.ds, 0, unsafe { nil })

	// Convert global work items to workgroup counts (vkCmdDispatch expects workgroups).
	// All current shaders use local_size_x = WORKGROUP_SIZE_X.
	group_x := (global_x + workgroup_size_x - 1) / workgroup_size_x
	group_y := global_y
	group_z := global_z
	vk_cmd_dispatch(cmd, group_x, group_y, group_z)

	// End command buffer
	res = vk_end_command_buffer(cmd)
	if res != result_success {
		return error('vulkan: vkEndCommandBuffer failed: ${res.str()}')
	}

	// Submit to queue and wait for completion
	return submit_and_wait(pl.device, cmd)
}

// alloc_cmd_buffer allocates a single-use command buffer.
fn alloc_cmd_buffer(d &Device) !VkCommandBuffer {
	info := C.VkCommandBufferAllocateInfo{
		sType:              structure_type_command_buffer_allocate_info
		commandPool:        d.cmd_pool
		level:              command_buffer_level_primary
		commandBufferCount: 1
	}
	mut cmd := VkCommandBuffer(unsafe { nil })
	res := vk_allocate_command_buffers(d.device, &info, &cmd)
	if res != result_success {
		return error('vulkan: vkAllocateCommandBuffers failed: ${res.str()}')
	}
	return cmd
}

// submit_and_wait submits cmdbuf to the given device's queue and waits via fence.
fn submit_and_wait(d &Device, cmd VkCommandBuffer) ! {
	finfo := C.VkFenceCreateInfo{
		sType: structure_type_fence_create_info
	}
	mut fence := VkFence(unsafe { nil })
	mut res := vk_create_fence(d.device, &finfo, unsafe { nil }, &fence)
	if res != result_success {
		return error('vulkan: vkCreateFence failed: ${res.str()}')
	}
	defer {
		vk_destroy_fence(d.device, fence, unsafe { nil })
	}
	si := C.VkSubmitInfo{
		sType:              structure_type_submit_info
		commandBufferCount: 1
		pCommandBuffers:    &cmd
		pWaitSemaphores:    unsafe { nil }
		pWaitDstStageMask:  unsafe { nil }
		pSignalSemaphores:  unsafe { nil }
	}
	res = vk_queue_submit(d.queue, 1, &si, fence)
	if res != result_success {
		return error('vulkan: vkQueueSubmit failed: ${res.str()}')
	}
	res = vk_wait_for_fences(d.device, 1, &fence, true, u64(10_000_000_000))
	if res != result_success {
		return error('vulkan: vkWaitForFences failed: ${res.str()}')
	}
}

// current_device returns the most recently created Device.
fn current_device() !&Device {
	d := unsafe { g_last_dev }
	if isnil(d) {
		return error('vulkan: no current device — call vulkan.new_device() first')
	}
	return d
}

// ComputePipeline type enum for the cache.
enum PipelineType {
	vector_add
	scale
	gemv
	reduce_sum
	relu
	sigmoid
	gemm
}

// pipeline_get lazily creates and caches a compute pipeline.
fn pipeline_get(t PipelineType) !&ComputePipeline {
	if p := pipeline_cache[t] {
		return p
	}
	d := current_device()!
	mut pl := &ComputePipeline(unsafe { nil })
	match t {
		.vector_add { pl = d.create_pipeline(vector_add_spv, 'main')! }
		.scale { pl = d.create_pipeline(scale_spv, 'main')! }
		.gemv { pl = d.create_pipeline(gemv_spv, 'main')! }
		.reduce_sum { pl = d.create_pipeline(reduce_sum_spv, 'main')! }
		.relu { pl = d.create_pipeline(relu_spv, 'main')! }
		.sigmoid { pl = d.create_pipeline(sigmoid_spv, 'main')! }
		.gemm { pl = d.create_pipeline(gemm_spv, 'main')! }
	}
	unsafe {
		g_last_dev = d
		pipeline_cache[t] = pl
	}
	return pl
}
