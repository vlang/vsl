module compute

import vsl.vulkan

// gemm_vulkan_f32 computes C = A * B with row-major inputs/outputs.
// A is [m x k], B is [k x n], result is [m x n].
pub fn gemm_vulkan_f32(dev &vulkan.Device, a_data []f32, b_data []f32, m int, n int, k int) ![]f32 {
	if a_data.len != m * k {
		return error('gemm_vulkan_f32: expected a_data len=${m * k}, got ${a_data.len}')
	}
	if b_data.len != k * n {
		return error('gemm_vulkan_f32: expected b_data len=${k * n}, got ${b_data.len}')
	}

	a_size := vulkan.DeviceSize(a_data.len * 4)
	b_size := vulkan.DeviceSize(b_data.len * 4)
	c_size := vulkan.DeviceSize(m * n * 4)

	mut a_buf := dev.buffer(a_size)!
	defer {
		a_buf.release()
	}
	mut b_buf := dev.buffer(b_size)!
	defer {
		b_buf.release()
	}
	mut c_buf := dev.buffer(c_size)!
	defer {
		c_buf.release()
	}

	mut a_bytes := []u8{len: a_data.len * 4}
	mut b_bytes := []u8{len: b_data.len * 4}
	unsafe {
		C.memcpy(a_bytes.data, a_data.data, a_data.len * 4)
		C.memcpy(b_bytes.data, b_data.data, b_data.len * 4)
	}
	a_buf.load(a_bytes)!
	b_buf.load(b_bytes)!

	vulkan.gemm(dev, c_buf, a_buf, b_buf, u32(m), u32(n), u32(k))!

	mut c_bytes := []u8{len: m * n * 4}
	c_bytes = c_buf.store(mut c_bytes)!

	mut out := []f32{len: m * n}
	unsafe {
		C.memcpy(out.data, c_bytes.data, m * n * 4)
	}
	return out
}

// gemm_vulkan computes C = A * B with row-major inputs/outputs in f64 API.
// Internally uses f32 Vulkan kernels and converts back to f64.
pub fn gemm_vulkan(dev &vulkan.Device, a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	mut a_f32 := []f32{len: a_data.len}
	for i, v in a_data {
		a_f32[i] = f32(v)
	}
	mut b_f32 := []f32{len: b_data.len}
	for i, v in b_data {
		b_f32[i] = f32(v)
	}
	c_f32 := gemm_vulkan_f32(dev, a_f32, b_f32, m, n, k)!
	mut out := []f64{len: c_f32.len}
	for i, v in c_f32 {
		out[i] = f64(v)
	}
	return out
}
