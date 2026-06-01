module compute

import vsl.vulkan

// gemv_vulkan_f32 exposes this operation as part of the public API.
pub fn gemv_vulkan_f32(dev &vulkan.Device, a_data []f32, x_data []f32, m int, n int) ![]f32 {
	if a_data.len != m * n {
		return error('gemv_vulkan_f32: expected a_data len=${m * n}, got ${a_data.len}')
	}
	if x_data.len != n {
		return error('gemv_vulkan_f32: expected x_data len=${n}, got ${x_data.len}')
	}

	mut a_buf := dev.buffer(vulkan.DeviceSize(a_data.len * 4))!
	defer {
		a_buf.release()
	}
	mut x_buf := dev.buffer(vulkan.DeviceSize(x_data.len * 4))!
	defer {
		x_buf.release()
	}
	mut y_buf := dev.buffer(vulkan.DeviceSize(m * 4))!
	defer {
		y_buf.release()
	}

	mut a_bytes := []u8{len: a_data.len * 4}
	mut x_bytes := []u8{len: x_data.len * 4}
	unsafe {
		C.memcpy(a_bytes.data, a_data.data, a_data.len * 4)
		C.memcpy(x_bytes.data, x_data.data, x_data.len * 4)
	}
	a_buf.load(a_bytes)!
	x_buf.load(x_bytes)!

	vulkan.gemv(dev, y_buf, a_buf, x_buf, m, n)!

	mut y_bytes := []u8{len: m * 4}
	y_bytes = y_buf.store(mut y_bytes)!
	mut out := []f32{len: m}
	unsafe {
		C.memcpy(out.data, y_bytes.data, m * 4)
	}
	return out
}

// gemv_vulkan exposes this operation as part of the public API.
pub fn gemv_vulkan(dev &vulkan.Device, a_data []f64, x_data []f64, m int, n int) ![]f64 {
	mut a_f32 := []f32{len: a_data.len}
	for i, v in a_data {
		a_f32[i] = f32(v)
	}
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	y_f32 := gemv_vulkan_f32(dev, a_f32, x_f32, m, n)!
	mut out := []f64{len: y_f32.len}
	for i, v in y_f32 {
		out[i] = f64(v)
	}
	return out
}
