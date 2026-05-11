// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.vulkan

// __global device is lazily initialized and shared across compute calls.
__global g_dev = &vulkan.Device(unsafe { nil })

// device returns the shared Vulkan device, creating it if needed.
fn device() !&vulkan.Device {
	d := unsafe { g_dev }
	if isnil(d) {
		mut new_d := vulkan.new_device()!
		unsafe {
			g_dev = new_d
		}
		return new_d
	}
	return d
}

// gemm_gpu computes C = A * B on GPU using Vulkan compute.
// All matrices are f64, row-major (same layout as VSL Matrix).
//   a_data: A matrix data, [a_m x a_n] row-major
//   b_data: B matrix data, [b_m x b_n] row-major
// Returns C matrix data as []f64, [a_m x b_n] row-major.
// Returns error if dimensions don't match or Vulkan dispatch fails.
pub fn gemm_gpu(a_data []f64, a_m int, a_n int, b_data []f64, b_m int, b_n int) ![]f64 {
	if a_n != b_m {
		return error('compute.gemm_gpu: dimension mismatch: A(${a_m}x${a_n}) * B(${b_m}x${b_n})')
	}

	m := u32(a_m)
	n := u32(b_n)
	k := u32(a_n)

	d := device()!

	// Allocate GPU buffers for A, B, C (f32)
	a_size := usize(m * k * 4)
	b_size := usize(k * n * 4)
	c_size := usize(m * n * 4)

	mut a_buf := d.buffer(vulkan.DeviceSize(a_size))!
	defer { a_buf.release() }
	mut b_buf := d.buffer(vulkan.DeviceSize(b_size))!
	defer { b_buf.release() }
	mut c_buf := d.buffer(vulkan.DeviceSize(c_size))!
	defer { c_buf.release() }

	// Convert f64 → f32 and upload A
	{
		mut a_f32 := []f32{len: int(m * k)}
		for i in 0 .. a_f32.len {
			a_f32[i] = f32(a_data[i])
		}
		mut a_bytes := []u8{len: int(a_size)}
		unsafe { C.memcpy(a_bytes.data, a_f32.data, a_size) }
		a_buf.load(a_bytes)!
	}

	// Convert f64 → f32 and upload B
	{
		mut b_f32 := []f32{len: int(k * n)}
		for i in 0 .. b_f32.len {
			b_f32[i] = f32(b_data[i])
		}
		mut b_bytes := []u8{len: int(b_size)}
		unsafe { C.memcpy(b_bytes.data, b_f32.data, b_size) }
		b_buf.load(b_bytes)!
	}

	// Execute GEMM on GPU
	vulkan.gemm(c_buf, a_buf, b_buf, m, n, k)!

	// Read back C from GPU
	mut c_bytes := []u8{len: int(c_size)}
	c_bytes = c_buf.store(mut c_bytes) or { return error('compute.gemm_gpu: readback failed: ${err}') }

	// Convert f32 → f64
	mut c_data := []f64{len: int(m * n)}
	unsafe {
		c_f32 := &f32(c_bytes.data)
		for i in 0 .. c_data.len {
			c_data[i] = f64(c_f32[i])
		}
	}

	return c_data
}
