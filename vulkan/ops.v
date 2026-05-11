module vulkan

// ============================================================================
// Linear algebra operations on Vulkan GPU
//
// Provides GPU-accelerated BLAS-style operations. All ops are blocking
// (synchronous) for simplicity. The Device is passed explicitly so no
// module-level globals are needed.
//
// Operations:
//   vector_add(dst, a, b)           dst[i] = a[i] + b[i]
//   scale(dst, src, alpha)         dst[i] = alpha * src[i]
//   gemv(y, A, x, m, n)            y[m] = A[m,n] * x[n] (row-major)
//   sum(buf)                       returns sum of all f32 elements
//   relu(dst, src)                  dst[i] = max(0, src[i])
//   sigmoid(dst, src)             dst[i] = 1/(1+exp(-src[i]))
//   softmax(dst, src, n)           numerically-stable row softmax
//   layernorm(dst, src, n, eps)    layer norm (no affine; apply gamma/beta on CPU)
//   reduce(dst, src, n, op)        per-workgroup sum or max into dst[num_groups]
// ============================================================================

// ComputePipeline type enum for the cache.
enum PipelineType {
	vector_add
	scale
	gemv
	reduce_sum
	relu
	sigmoid
	gemm
	softmax
	layernorm
	reduction
	im2col
	avgpool2d
	global_avgpool2d
	embedding_gather
	gelu
	maxpool2d
	batchnorm1d
	// Backward kernels
	d_relu
	d_sigmoid
	d_tanh
	d_gelu
	d_gemm_da
	d_gemm_db
	d_softmax
	d_layernorm
	broadcast_grad
}

// vector_add computes element-wise addition: dst = a + b
pub fn vector_add(dev &Device, dst &GpuBuffer, a &GpuBuffer, b &GpuBuffer) ! {
	pl := pipeline_get(dev, .vector_add)!
	pl.update_buffer(0, a)!
	pl.update_buffer(1, b)!
	pl.update_buffer(2, dst)!
	dispatch_sync(dev, pl, u32(dst.size / 4), 1, 1)!
}

// scale computes dst = alpha * src
pub fn scale(dev &Device, dst &GpuBuffer, src &GpuBuffer, alpha f32) ! {
	pl := pipeline_get(dev, .scale)!
	// Upload alpha as a small GPU buffer (binding 3)
	mut abuf := dev.buffer(DeviceSize(4))!
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
	dispatch_sync(dev, pl, u32(dst.size / 4), 1, 1)!
}

// gemv computes y = A * x (row-major: A[i*n + j])
pub fn gemv(dev &Device, y &GpuBuffer, a &GpuBuffer, x &GpuBuffer, m int, n int) ! {
	pl := pipeline_get(dev, .gemv)!
	pl.update_buffer(1, a)!
	pl.update_buffer(2, x)!
	pl.update_buffer(3, y)!
	dispatch_sync(dev, pl, u32(m), 1, 1)!
}

// sum computes the sum of all f32 elements in the buffer.
pub fn sum(dev &Device, buf &GpuBuffer) !f32 {
	n := int(buf.size / 4)
	workgroup_size := 256
	num_groups := (n + workgroup_size - 1) / workgroup_size
	mut scratch := dev.buffer(DeviceSize(num_groups * 4))!
	defer {
		scratch.release()
	}
	pl := pipeline_get(dev, .reduce_sum)!
	pl.update_buffer(0, buf)!
	pl.update_buffer(2, scratch)!
	dispatch_sync(dev, pl, u32(n), 1, 1)!
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
pub fn relu(dev &Device, dst &GpuBuffer, src &GpuBuffer) ! {
	pl := pipeline_get(dev, .relu)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	dispatch_sync(dev, pl, u32(src.size / 4), 1, 1)!
}

// sigmoid computes dst[i] = 1/(1+exp(-src[i]))
pub fn sigmoid(dev &Device, dst &GpuBuffer, src &GpuBuffer) ! {
	pl := pipeline_get(dev, .sigmoid)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	dispatch_sync(dev, pl, u32(src.size / 4), 1, 1)!
}

// gemm computes C = A * B (row-major, f32) on GPU.
// A: [M x K] row-major, B: [K x N] row-major, C: [M x N] row-major.
// All buffers must be f32 GpuBuffers.
pub fn gemm(dev &Device, dst &GpuBuffer, a &GpuBuffer, b &GpuBuffer, m u32, n u32, k u32) ! {
	// Create small params buffer with [M, N, K]
	mut params_buf := dev.buffer(DeviceSize(12))!
	defer { params_buf.release() }
	mut params_bytes := []u8{len: 12}
	unsafe {
		*(&u32(&params_bytes[0])) = m
		*(&u32(&params_bytes[4])) = n
		*(&u32(&params_bytes[8])) = k
	}
	params_buf.load(params_bytes)!

	pl := pipeline_get(dev, .gemm)!
	pl.update_buffer(0, a)!
	pl.update_buffer(1, b)!
	pl.update_buffer(2, dst)!
	pl.update_buffer(3, params_buf)!
	dispatch_sync(dev, pl, m, n, 1)!
}

// softmax computes per-row numerically stable softmax on a 1-D vector of length n.
// Binding layout (v2 shader, no push_constants):
//   0: in_data (f32[n])  1: out_data (f32[n])  2: params_data (u32[2] = [n, num_groups])  3: scratch_data (f32[2*num_groups])
pub fn softmax(dev &Device, dst &GpuBuffer, src &GpuBuffer, n u32) ! {
	wg_size := u32(256)
	num_groups := (n + wg_size - 1) / wg_size

	// params: [n, num_groups]
	mut params_buf := dev.buffer(DeviceSize(8))!
	defer { params_buf.release() }
	mut pb := []u8{len: 8}
	unsafe {
		*(&u32(&pb[0])) = n
		*(&u32(&pb[4])) = num_groups
	}
	params_buf.load(pb)!

	// scratch: 2 * num_groups f32s (max phase + sum phase)
	scratch_size := DeviceSize(u64(num_groups) * 2 * 4)
	mut scratch_buf := dev.buffer(scratch_size)!
	defer { scratch_buf.release() }

	pl := pipeline_get(dev, .softmax)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	pl.update_buffer(2, params_buf)!
	pl.update_buffer(3, scratch_buf)!
	dispatch_sync(dev, pl, n, 1, 1)!
}

// layernorm computes layer normalisation: out[i] = (x[i] - mean) * inv_std.
// Gamma/beta affine transform must be applied by the caller on CPU.
// Binding layout (v2 shader):
//   0: in_data (f32[n])  1: out_data (f32[n])  2: params_data (u32[2] = [n, eps_bits])  3: scratch_data (f32[2])
pub fn layernorm(dev &Device, dst &GpuBuffer, src &GpuBuffer, n u32, eps f32) ! {
	// Encode eps as raw bits so it survives the u32 SSBO
	eps_bits := unsafe { *(&u32(&eps)) }

	mut params_buf := dev.buffer(DeviceSize(8))!
	defer { params_buf.release() }
	mut pb := []u8{len: 8}
	unsafe {
		*(&u32(&pb[0])) = n
		*(&u32(&pb[4])) = eps_bits
	}
	params_buf.load(pb)!

	// scratch: [mean, variance] — 2 f32s shared across workgroups
	mut scratch_buf := dev.buffer(DeviceSize(8))!
	defer { scratch_buf.release() }

	pl := pipeline_get(dev, .layernorm)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	pl.update_buffer(2, params_buf)!
	pl.update_buffer(3, scratch_buf)!
	dispatch_sync(dev, pl, n, 1, 1)!
}

// ReductionOp selects the operation performed by the reduction kernel.
pub enum ReductionOp {
	sum = 0
	max = 1
}

// reduce computes a per-workgroup reduction (sum or max) into out_data[num_groups].
// Binding layout (v2 shader):
//   0: in_data (f32[n])  1: out_data (f32[num_groups])  2: params_data (u32[2] = [n, op])  3: scratch_data (f32[num_groups])
pub fn reduce(dev &Device, dst &GpuBuffer, src &GpuBuffer, n u32, op ReductionOp) ! {
	wg_size := u32(256)
	num_groups := (n + wg_size - 1) / wg_size

	mut params_buf := dev.buffer(DeviceSize(8))!
	defer { params_buf.release() }
	mut pb := []u8{len: 8}
	unsafe {
		*(&u32(&pb[0])) = n
		*(&u32(&pb[4])) = u32(op)
	}
	params_buf.load(pb)!

	mut scratch_buf := dev.buffer(DeviceSize(u64(num_groups) * 4))!
	defer { scratch_buf.release() }

	pl := pipeline_get(dev, .reduction)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	pl.update_buffer(2, params_buf)!
	pl.update_buffer(3, scratch_buf)!
	dispatch_sync(dev, pl, n, 1, 1)!
}

// im2col performs im2col transformation for GEMM-based convolution.
// Input: [N, C, H, W] (NCHW layout)
// Output: [N*out_h*out_w, C*k_h*k_w] (im2col matrix)
// Params: N, C, H, W, k_h, k_w, out_h, out_w, pad_h, pad_w, stride_h, stride_w, dil_h, dil_w
pub fn im2col(dev &Device, dst &GpuBuffer, src &GpuBuffer, n u32, c u32, h u32, w u32, k_h u32, k_w u32, out_h u32, out_w u32, pad_h u32, pad_w u32, stride_h u32, stride_w u32, dil_h u32, dil_w u32) ! {
	// Allocate params buffer
	mut params_buf := dev.buffer(DeviceSize(14 * 4))!
	defer { params_buf.release() }
	mut pb := []u8{len: 14 * 4}
	unsafe {
		*(&u32(&pb[0])) = n
		*(&u32(&pb[4])) = c
		*(&u32(&pb[8])) = h
		*(&u32(&pb[12])) = w
		*(&u32(&pb[16])) = k_h
		*(&u32(&pb[20])) = k_w
		*(&u32(&pb[24])) = out_h
		*(&u32(&pb[28])) = out_w
		*(&u32(&pb[32])) = pad_h
		*(&u32(&pb[36])) = pad_w
		*(&u32(&pb[40])) = stride_h
		*(&u32(&pb[44])) = stride_w
		*(&u32(&pb[48])) = dil_h
		*(&u32(&pb[52])) = dil_w
	}
	params_buf.load(pb)!

	pl := pipeline_get(dev, .im2col)!
	pl.update_buffer(0, src)!
	pl.update_buffer(1, dst)!
	pl.update_buffer(2, params_buf)!

	// Dispatch: total elements = N * out_h * out_w * C * k_h * k_w
	total_elems := n * out_h * out_w * c * k_h * k_w
	dispatch_sync(dev, pl, total_elems, 1, 1)!
}

// avgpool2d performs 2D average pooling on GPU.
// input: [batch, in_ch, in_h, in_w]
// output: [batch, in_ch, out_h, out_w]
// Params: [batch, in_ch, in_h, in_w, k_h, k_w, out_h, out_w, pad_h, pad_w, stride_h, stride_w]
pub fn avgpool2d(dev &Device, dst &GpuBuffer, src &GpuBuffer, batch u32, in_ch u32, in_h u32, in_w u32, k_h u32, k_w u32, out_h u32, out_w u32, pad_h u32, pad_w u32, stride_h u32, stride_w u32) ! {
	// Allocate params buffer (12 u32 values)
	mut params_buf := dev.buffer(DeviceSize(12 * 4))!
	defer { params_buf.release() }
	mut pb := []u8{len: 12 * 4}
	unsafe {
		*(&u32(&pb[0])) = batch
		*(&u32(&pb[4])) = in_ch
		*(&u32(&pb[8])) = in_h
		*(&u32(&pb[12])) = in_w
		*(&u32(&pb[16])) = k_h
		*(&u32(&pb[20])) = k_w
		*(&u32(&pb[24])) = out_h
		*(&u32(&pb[28])) = out_w
		*(&u32(&pb[32])) = pad_h
		*(&u32(&pb[36])) = pad_w
		*(&u32(&pb[40])) = stride_h
		*(&u32(&pb[44])) = stride_w
	}
	params_buf.load(pb)!

	pl := pipeline_get(dev, .avgpool2d)!
	pl.update_buffer(0, dst)!
	pl.update_buffer(1, src)!
	pl.update_buffer(2, params_buf)!

	// Dispatch: total elements = batch * in_ch * out_h * out_w
	total_elems := batch * in_ch * out_h * out_w
	dispatch_sync(dev, pl, total_elems, 1, 1)!
}

// global_avgpool2d performs global average pooling (reduces H×W spatial dims to 1×1 per channel).
// input: [batch, channels, height, width]
// output: [batch, channels, 1, 1]
// Params: [batch, channels, height, width]
// Dispatch: one workgroup per (batch, channel) pair.
pub fn global_avgpool2d(dev &Device, dst &GpuBuffer, src &GpuBuffer, batch u32, channels u32, height u32, width u32) ! {
	// Allocate params buffer (4 u32 values)
	mut params_buf := dev.buffer(DeviceSize(4 * 4))!
	defer { params_buf.release() }
	mut pb := []u8{len: 4 * 4}
	unsafe {
		*(&u32(&pb[0])) = batch
		*(&u32(&pb[4])) = channels
		*(&u32(&pb[8])) = height
		*(&u32(&pb[12])) = width
	}
	params_buf.load(pb)!

	pl := pipeline_get(dev, .global_avgpool2d)!
	pl.update_buffer(0, dst)!
	pl.update_buffer(1, src)!
	pl.update_buffer(2, params_buf)!

	// Dispatch: one workgroup per (batch, channel) pair
	global_x := batch * channels
	dispatch_sync(dev, pl, global_x, 1, 1)!
}

// dispatch_sync submits a 3D compute dispatch and waits for completion.
// global_x, global_y, global_z = total work items (not workgroups).
// The function divides by WORKGROUP_SIZE_X to compute workgroup counts.
pub fn dispatch_sync(dev &Device, pl &ComputePipeline, global_x u32, global_y u32, global_z u32) ! {
	mut cmd := alloc_cmd_buffer(dev)!
	defer {
		vk_free_command_buffers(dev.device, dev.cmd_pool, 1, &cmd)
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
	vk_cmd_pipeline_barrier(cmd, pipeline_stage_host_bit, pipeline_stage_compute_shader_bit, 0, 1,
		&barrier, 0, unsafe { nil }, 0, unsafe { nil })

	// Bind compute pipeline
	vk_cmd_bind_pipeline(cmd, pipeline_bind_point_compute, pl.pipeline_handle)

	// Bind descriptor sets
	vk_cmd_bind_descriptor_sets(cmd, pipeline_bind_point_compute, pl.layout, 0, 1, &pl.ds, 0,
		unsafe { nil })

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
	return submit_and_wait(dev, cmd)
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

// pipeline_get lazily creates and caches a compute pipeline on the given device.
fn pipeline_get(d &Device, t PipelineType) !&ComputePipeline {
	if p := d.pipeline_cache[t] {
		return p
	}
	mut pl := &ComputePipeline(unsafe { nil })
	match t {
		.vector_add { pl = d.create_pipeline(vector_add_spv, 'main')! }
		.scale { pl = d.create_pipeline(scale_spv, 'main')! }
		.gemv { pl = d.create_pipeline(gemv_spv, 'main')! }
		.reduce_sum { pl = d.create_pipeline(reduce_sum_spv, 'main')! }
		.relu { pl = d.create_pipeline(relu_spv, 'main')! }
		.sigmoid { pl = d.create_pipeline(sigmoid_spv, 'main')! }
		.gemm { pl = d.create_pipeline(gemm_spv, 'main')! }
		.softmax { pl = d.create_pipeline(softmax_spv, 'main')! }
		.layernorm { pl = d.create_pipeline(layernorm_spv, 'main')! }
		.reduction { pl = d.create_pipeline(reduction_spv, 'main')! }
		.im2col { pl = d.create_pipeline(im2col_spv, 'main')! }
		.avgpool2d { pl = d.create_pipeline(avgpool2d_spv, 'main')! }
		.global_avgpool2d { pl = d.create_pipeline(global_avgpool2d_spv, 'main')! }
		.embedding_gather { pl = d.create_pipeline(embedding_gather_spv, 'main')! }
		.gelu { pl = d.create_pipeline(gelu_spv, 'main')! }
		.maxpool2d { pl = d.create_pipeline(maxpool2d_spv, 'main')! }
		.batchnorm1d { pl = d.create_pipeline(batchnorm1d_spv, 'main')! }
		// Backward kernels
		.d_relu { pl = d.create_pipeline(spv_d_relu, 'main')! }
		.d_sigmoid { pl = d.create_pipeline(spv_d_sigmoid, 'main')! }
		.d_tanh { pl = d.create_pipeline(spv_d_tanh, 'main')! }
		.d_gelu { pl = d.create_pipeline(spv_d_gelu, 'main')! }
		.d_gemm_da { pl = d.create_pipeline(spv_d_gemm_da, 'main')! }
		.d_gemm_db { pl = d.create_pipeline(spv_d_gemm_db, 'main')! }
		.d_softmax { pl = d.create_pipeline(spv_d_softmax, 'main')! }
		.d_layernorm { pl = d.create_pipeline(spv_d_layernorm, 'main')! }
		.broadcast_grad { pl = d.create_pipeline(spv_broadcast_grad, 'main')! }
	}

	unsafe {
		d.pipeline_cache[t] = pl
	}
	return pl
}

// embedding_gather performs embedding table lookups by index.
// indices: [num_indices] (u32)
// embedding_table: [vocab_size, embed_dim] row-major (f32)
// output: [num_indices, embed_dim] (f32)
// Params: [num_indices, vocab_size, embed_dim]
pub fn embedding_gather(dev &Device, dst &GpuBuffer, indices_buf &GpuBuffer, embedding_table_buf &GpuBuffer, num_indices u32, vocab_size u32, embed_dim u32) ! {
	// Allocate params buffer (3 u32 values)
	mut params_buf := dev.buffer(DeviceSize(3 * 4))!
	defer { params_buf.release() }
	mut pb := []u8{len: 3 * 4}
	unsafe {
		*(&u32(&pb[0])) = num_indices
		*(&u32(&pb[4])) = vocab_size
		*(&u32(&pb[8])) = embed_dim
	}
	params_buf.load(pb)!

	pl := pipeline_get(dev, .embedding_gather)!
	pl.update_buffer(0, indices_buf)!
	pl.update_buffer(1, embedding_table_buf)!
	pl.update_buffer(2, dst)!
	pl.update_buffer(3, params_buf)!

	// Dispatch: total elements = num_indices * embed_dim
	total_elems := num_indices * embed_dim
	dispatch_sync(dev, pl, total_elems, 1, 1)!
}

// gelu computes the GELU activation: dst[i] = 0.5 * x * (1 + tanh(sqrt(2/pi) * (x + 0.044715*x^3)))
pub fn gelu(dev &Device, dst &GpuBuffer, src &GpuBuffer, n u32) ! {
	mut pc_buf := dev.buffer(DeviceSize(4))!
	defer { pc_buf.release() }
	mut pb := []u8{len: 4}
	unsafe {
		*(&u32(&pb[0])) = n
	}
	pc_buf.load(pb)!

	pl := pipeline_get(dev, .gelu)!
	pl.update_buffer(0, dst)!
	pl.update_buffer(1, src)!
	pl.update_buffer(2, pc_buf)!
	dispatch_sync(dev, pl, n, 1, 1)!
}

// maxpool2d performs 2D max pooling on NCHW input.
pub fn maxpool2d(dev &Device, dst &GpuBuffer, src &GpuBuffer, batch u32, in_ch u32, in_h u32, in_w u32, k_h u32, k_w u32, out_h u32, out_w u32, pad_h u32, pad_w u32, stride_h u32, stride_w u32) ! {
	mut pc_buf := dev.buffer(DeviceSize(12 * 4))!
	defer { pc_buf.release() }
	mut pb := []u8{len: 12 * 4}
	params := [batch, in_ch, in_h, in_w, k_h, k_w, out_h, out_w, pad_h, pad_w, stride_h, stride_w]
	for i, v in params {
		unsafe {
			*(&u32(&pb[i * 4])) = v
		}
	}
	pc_buf.load(pb)!

	pl := pipeline_get(dev, .maxpool2d)!
	pl.update_buffer(0, dst)!
	pl.update_buffer(1, src)!
	pl.update_buffer(2, pc_buf)!
	total := batch * in_ch * out_h * out_w
	dispatch_sync(dev, pl, total, 1, 1)!
}

// batchnorm1d normalises input[N, C] along the batch (N) dimension per feature.
// params SSBO: [n, c, eps_bits] where eps_bits = uintBitsToFloat(eps).
// Output is normalised only — caller applies gamma/beta on CPU.
pub fn batchnorm1d(dev &Device, dst &GpuBuffer, src &GpuBuffer, n u32, c u32, eps f32) ! {
	mut pc_buf := dev.buffer(DeviceSize(3 * 4))!
	defer { pc_buf.release() }
	mut pb := []u8{len: 3 * 4}
	unsafe {
		*(&u32(&pb[0])) = n
		*(&u32(&pb[4])) = c
		*(&f32(&pb[8])) = eps
	}
	pc_buf.load(pb)!

	pl := pipeline_get(dev, .batchnorm1d)!
	pl.update_buffer(0, dst)!
	pl.update_buffer(1, src)!
	pl.update_buffer(2, pc_buf)!
	// dispatch one workgroup per feature; 256 threads per group handle N samples
	dispatch_sync(dev, pl, c * u32(workgroup_size_x), 1, 1)!
}

// ===========================================================================
// Backward-pass GPU operations
// ===========================================================================

// d_relu computes the ReLU backward pass.
// grad_out: upstream gradient [n], input_val: forward input [n]
// grad_in: output gradient [n]
// grad_in[i] = grad_out[i] if input_val[i] > 0 else 0
pub fn d_relu(dev &Device, grad_in &GpuBuffer, grad_out &GpuBuffer, input_val &GpuBuffer) ! {
	pl := pipeline_get(dev, .d_relu)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, input_val)!
	pl.update_buffer(2, grad_in)!
	dispatch_sync(dev, pl, u32(grad_out.size / 4), 1, 1)!
}

// d_sigmoid computes the sigmoid backward pass.
// grad_in[i] = grad_out[i] * sigmoid_out[i] * (1 - sigmoid_out[i])
pub fn d_sigmoid(dev &Device, grad_in &GpuBuffer, grad_out &GpuBuffer, sigmoid_out &GpuBuffer) ! {
	pl := pipeline_get(dev, .d_sigmoid)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, sigmoid_out)!
	pl.update_buffer(2, grad_in)!
	dispatch_sync(dev, pl, u32(grad_out.size / 4), 1, 1)!
}

// d_tanh computes the tanh backward pass.
// grad_in[i] = grad_out[i] * (1 - tanh_out[i]^2)
pub fn d_tanh(dev &Device, grad_in &GpuBuffer, grad_out &GpuBuffer, tanh_out &GpuBuffer) ! {
	pl := pipeline_get(dev, .d_tanh)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, tanh_out)!
	pl.update_buffer(2, grad_in)!
	dispatch_sync(dev, pl, u32(grad_out.size / 4), 1, 1)!
}

// d_gelu computes the GELU backward pass.
// grad_in[i] = grad_out[i] * gelu'(input_val[i])
pub fn d_gelu(dev &Device, grad_in &GpuBuffer, grad_out &GpuBuffer, input_val &GpuBuffer) ! {
	pl := pipeline_get(dev, .d_gelu)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, input_val)!
	pl.update_buffer(2, grad_in)!
	dispatch_sync(dev, pl, u32(grad_out.size / 4), 1, 1)!
}

// d_gemm_da computes the gradient of A in C = A @ B.
// dA [M x K] = grad_out [M x N] @ B^T [N x K]
// dims_buf holds [M, N, K] as three u32 values.
pub fn d_gemm_da(dev &Device, da &GpuBuffer, grad_out &GpuBuffer, b_mat &GpuBuffer, m u32, n u32, k u32) ! {
	mut dims_buf := dev.buffer(DeviceSize(3 * 4))!
	defer { dims_buf.release() }
	mut pb := []u8{len: 12}
	unsafe {
		*(&u32(&pb[0])) = m
		*(&u32(&pb[4])) = n
		*(&u32(&pb[8])) = k
	}
	dims_buf.load(pb)!
	pl := pipeline_get(dev, .d_gemm_da)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, b_mat)!
	pl.update_buffer(2, da)!
	pl.update_buffer(3, dims_buf)!
	dispatch_sync(dev, pl, m * k, 1, 1)!
}

// d_gemm_db computes the gradient of B in C = A @ B.
// dB [K x N] = A^T [K x M] @ grad_out [M x N]
pub fn d_gemm_db(dev &Device, db &GpuBuffer, grad_out &GpuBuffer, a_mat &GpuBuffer, m u32, n u32, k u32) ! {
	mut dims_buf := dev.buffer(DeviceSize(3 * 4))!
	defer { dims_buf.release() }
	mut pb := []u8{len: 12}
	unsafe {
		*(&u32(&pb[0])) = m
		*(&u32(&pb[4])) = n
		*(&u32(&pb[8])) = k
	}
	dims_buf.load(pb)!
	pl := pipeline_get(dev, .d_gemm_db)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, a_mat)!
	pl.update_buffer(2, db)!
	pl.update_buffer(3, dims_buf)!
	dispatch_sync(dev, pl, k * n, 1, 1)!
}

// d_softmax computes the softmax backward pass (Jacobian-vector product).
// grad_in[i] = softmax_out[i] * (grad_out[i] - dot(grad_out_row, softmax_out_row))
// rows: number of independent softmax rows, n: row length
pub fn d_softmax(dev &Device, grad_in &GpuBuffer, grad_out &GpuBuffer, softmax_out &GpuBuffer, rows u32, n u32) ! {
	mut dims_buf := dev.buffer(DeviceSize(2 * 4))!
	defer { dims_buf.release() }
	mut pb := []u8{len: 8}
	unsafe {
		*(&u32(&pb[0])) = rows
		*(&u32(&pb[4])) = n
	}
	dims_buf.load(pb)!
	pl := pipeline_get(dev, .d_softmax)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, softmax_out)!
	pl.update_buffer(2, grad_in)!
	pl.update_buffer(3, dims_buf)!
	// One workgroup per row
	dispatch_sync(dev, pl, rows * u32(workgroup_size_x), 1, 1)!
}

// d_layernorm computes the layer normalization backward pass (no affine).
// rows: number of independent layer-norm rows, n: row length, eps: small epsilon
pub fn d_layernorm(dev &Device, grad_in &GpuBuffer, grad_out &GpuBuffer, input_val &GpuBuffer, rows u32, n u32, eps f32) ! {
	mut params_buf := dev.buffer(DeviceSize(2 * 4))!
	defer { params_buf.release() }
	mut pb := []u8{len: 8}
	unsafe {
		*(&u32(&pb[0])) = n
		*(&f32(&pb[4])) = eps
	}
	params_buf.load(pb)!
	pl := pipeline_get(dev, .d_layernorm)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, input_val)!
	pl.update_buffer(2, grad_in)!
	pl.update_buffer(3, params_buf)!
	// One workgroup per row
	dispatch_sync(dev, pl, rows * u32(workgroup_size_x), 1, 1)!
}

// broadcast_grad broadcasts a reduced gradient back to full shape.
// grad_out[0..n-1] is the reduced gradient; grad_in[0..total-1] is the output.
// scale: multiplier applied to each element (1.0 for sum backward, 1/k for mean backward).
pub fn broadcast_grad(dev &Device, grad_in &GpuBuffer, grad_out &GpuBuffer, n u32, scale f32) ! {
	mut params_buf := dev.buffer(DeviceSize(2 * 4))!
	defer { params_buf.release() }
	mut pb := []u8{len: 8}
	unsafe {
		*(&u32(&pb[0])) = n
		*(&f32(&pb[4])) = scale
	}
	params_buf.load(pb)!
	pl := pipeline_get(dev, .broadcast_grad)!
	pl.update_buffer(0, grad_out)!
	pl.update_buffer(1, grad_in)!
	pl.update_buffer(2, params_buf)!
	dispatch_sync(dev, pl, u32(grad_in.size / 4), 1, 1)!
}
