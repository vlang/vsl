// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.vulkan

// relu_gpu computes ReLU in-place on GPU: dst[i] = max(0, src[i])
// src and dst are f32 GpuBuffers (must have same size).
pub fn relu_gpu(dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	vulkan.relu(dst, src)!
}

// sigmoid_gpu computes sigmoid in-place on GPU: dst[i] = 1/(1+exp(-src[i]))
// src and dst are f32 GpuBuffers (must have same size).
pub fn sigmoid_gpu(dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	vulkan.sigmoid(dst, src)!
}

// relu_matrix computes ReLU on a flat f64 array using GPU.
// Returns a new []f64 with relu applied element-wise.
pub fn relu_matrix(data []f64) ![]f64 {
	d := device()!
	n := data.len

	// Allocate GPU buffer
	size := vulkan.DeviceSize(n * 4)
	mut src_buf := d.buffer(size)!
	defer { src_buf.release() }
	mut dst_buf := d.buffer(size)!
	defer { dst_buf.release() }

	// Upload f64 → f32
	mut f32_data := []f32{len: n}
	for i in 0 .. n {
		f32_data[i] = f32(data[i])
	}
	mut bytes := []u8{len: n * 4}
	unsafe { C.memcpy(bytes.data, f32_data.data, n * 4) }
	src_buf.load(bytes)!

	// GPU relu
	vulkan.relu(dst_buf, src_buf)!

	// Read back
	mut out_bytes := []u8{len: n * 4}
	out_bytes = dst_buf.store(mut out_bytes) or { return error('compute.relu_matrix: readback failed: ${err}') }

	// Convert f32 → f64
	mut result := []f64{len: n}
	unsafe {
		out_f32 := &f32(out_bytes.data)
		for i in 0 .. n {
			result[i] = f64(out_f32[i])
		}
	}
	return result
}

// sigmoid_matrix computes sigmoid on a flat f64 array using GPU.
// Returns a new []f64 with sigmoid applied element-wise.
pub fn sigmoid_matrix(data []f64) ![]f64 {
	d := device()!
	n := data.len

	// Allocate GPU buffer
	size := vulkan.DeviceSize(n * 4)
	mut src_buf := d.buffer(size)!
	defer { src_buf.release() }
	mut dst_buf := d.buffer(size)!
	defer { dst_buf.release() }

	// Upload f64 → f32
	mut f32_data := []f32{len: n}
	for i in 0 .. n {
		f32_data[i] = f32(data[i])
	}
	mut bytes := []u8{len: n * 4}
	unsafe { C.memcpy(bytes.data, f32_data.data, n * 4) }
	src_buf.load(bytes)!

	// GPU sigmoid
	vulkan.sigmoid(dst_buf, src_buf)!

	// Read back
	mut out_bytes := []u8{len: n * 4}
	out_bytes = dst_buf.store(mut out_bytes) or { return error('compute.sigmoid_matrix: readback failed: ${err}') }

	// Convert f32 → f64
	mut result := []f64{len: n}
	unsafe {
		out_f32 := &f32(out_bytes.data)
		for i in 0 .. n {
			result[i] = f64(out_f32[i])
		}
	}
	return result
}
