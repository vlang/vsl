// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.vulkan

// relu_gpu computes dst[i] = max(0, src[i]) on GPU.
// ctx must be a vulkan ComputeContext created via new_vulkan_context().
pub fn relu_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	if ctx.backend != .vulkan {
		return error('compute.relu_gpu: only vulkan backend implemented')
	}
	vulkan.relu(ctx.vulkan_device, dst, src)!
}

// sigmoid_gpu computes dst[i] = 1/(1+exp(-src[i])) on GPU.
// ctx must be a vulkan ComputeContext created via new_vulkan_context().
pub fn sigmoid_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	if ctx.backend != .vulkan {
		return error('compute.sigmoid_gpu: only vulkan backend implemented')
	}
	vulkan.sigmoid(ctx.vulkan_device, dst, src)!
}

// relu_matrix computes relu on a flat []f64 slice via GPU (f32 internally).
// ctx must be a vulkan ComputeContext created via new_vulkan_context().
pub fn relu_matrix(ctx &ComputeContext, data []f64) ![]f64 {
	if ctx.backend != .vulkan {
		return error('compute.relu_matrix: only vulkan backend implemented')
	}
	dev := ctx.vulkan_device
	n := data.len

	size := vulkan.DeviceSize(n * 4)
	mut src_buf := dev.buffer(size)!
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(size)!
	defer { dst_buf.release() }

	mut f32_data := []f32{len: n}
	for i in 0 .. n {
		f32_data[i] = f32(data[i])
	}
	mut bytes := []u8{len: n * 4}
	unsafe { C.memcpy(bytes.data, f32_data.data, n * 4) }
	src_buf.load(bytes)!

	vulkan.relu(dev, dst_buf, src_buf)!

	mut out_bytes := []u8{len: n * 4}
	out_bytes = dst_buf.store(mut out_bytes) or {
		return error('compute.relu_matrix: readback failed: ${err}')
	}

	mut result := []f64{len: n}
	unsafe {
		out_f32 := &f32(out_bytes.data)
		for i in 0 .. n {
			result[i] = f64(out_f32[i])
		}
	}
	return result
}

// sigmoid_matrix computes sigmoid on a flat []f64 slice via GPU (f32 internally).
// ctx must be a vulkan ComputeContext created via new_vulkan_context().
pub fn sigmoid_matrix(ctx &ComputeContext, data []f64) ![]f64 {
	if ctx.backend != .vulkan {
		return error('compute.sigmoid_matrix: only vulkan backend implemented')
	}
	dev := ctx.vulkan_device
	n := data.len

	size := vulkan.DeviceSize(n * 4)
	mut src_buf := dev.buffer(size)!
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(size)!
	defer { dst_buf.release() }

	mut f32_data := []f32{len: n}
	for i in 0 .. n {
		f32_data[i] = f32(data[i])
	}
	mut bytes := []u8{len: n * 4}
	unsafe { C.memcpy(bytes.data, f32_data.data, n * 4) }
	src_buf.load(bytes)!

	vulkan.sigmoid(dev, dst_buf, src_buf)!

	mut out_bytes := []u8{len: n * 4}
	out_bytes = dst_buf.store(mut out_bytes) or {
		return error('compute.sigmoid_matrix: readback failed: ${err}')
	}

	mut result := []f64{len: n}
	unsafe {
		out_f32 := &f32(out_bytes.data)
		for i in 0 .. n {
			result[i] = f64(out_f32[i])
		}
	}
	return result
}

// gemv_gpu computes y = A * x (row-major) on GPU, with f64 data via f32 Vulkan ops.
// A is [m x n] row-major, x is [n], result is [m].
pub fn gemv_gpu(ctx &ComputeContext, a_data []f64, m int, n int, x_data []f64) ![]f64 {
	if ctx.backend != .vulkan {
		return error('compute.gemv_gpu: only vulkan backend implemented')
	}
	dev := ctx.vulkan_device

	a_size := vulkan.DeviceSize(m * n * 4)
	x_size := vulkan.DeviceSize(n * 4)
	y_size := vulkan.DeviceSize(m * 4)

	mut a_buf := dev.buffer(a_size)!
	defer { a_buf.release() }
	mut x_buf := dev.buffer(x_size)!
	defer { x_buf.release() }
	mut y_buf := dev.buffer(y_size)!
	defer { y_buf.release() }

	mut a_f32 := []f32{len: m * n}
	for i in 0 .. a_f32.len { a_f32[i] = f32(a_data[i]) }
	mut a_bytes := []u8{len: m * n * 4}
	unsafe { C.memcpy(a_bytes.data, a_f32.data, m * n * 4) }
	a_buf.load(a_bytes)!

	mut x_f32 := []f32{len: n}
	for i in 0 .. n { x_f32[i] = f32(x_data[i]) }
	mut x_bytes := []u8{len: n * 4}
	unsafe { C.memcpy(x_bytes.data, x_f32.data, n * 4) }
	x_buf.load(x_bytes)!

	vulkan.gemv(dev, y_buf, a_buf, x_buf, m, n)!

	mut out_bytes := []u8{len: m * 4}
	out_bytes = y_buf.store(mut out_bytes) or {
		return error('compute.gemv_gpu: readback failed: ${err}')
	}

	mut result := []f64{len: m}
	unsafe {
		out_f32 := &f32(out_bytes.data)
		for i in 0 .. m {
			result[i] = f64(out_f32[i])
		}
	}
	return result
}
