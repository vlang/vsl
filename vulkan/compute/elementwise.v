module compute

import vsl.vulkan

fn run_unary_f32(dev &vulkan.Device, x_data []f32, op fn (&vulkan.Device, &vulkan.GpuBuffer, &vulkan.GpuBuffer) !) ![]f32 {
	size := vulkan.DeviceSize(x_data.len * 4)
	mut src := dev.buffer(size)!
	defer {
		src.release()
	}
	mut dst := dev.buffer(size)!
	defer {
		dst.release()
	}

	mut bytes := []u8{len: x_data.len * 4}
	unsafe {
		C.memcpy(bytes.data, x_data.data, x_data.len * 4)
	}
	src.load(bytes)!

	op(dev, dst, src)!

	mut out_bytes := []u8{len: x_data.len * 4}
	out_bytes = dst.store(mut out_bytes)!
	mut out := []f32{len: x_data.len}
	unsafe {
		C.memcpy(out.data, out_bytes.data, x_data.len * 4)
	}
	return out
}

pub fn relu_vulkan_f32(dev &vulkan.Device, x_data []f32) ![]f32 {
	return run_unary_f32(dev, x_data, vulkan.relu)
}

pub fn sigmoid_vulkan_f32(dev &vulkan.Device, x_data []f32) ![]f32 {
	return run_unary_f32(dev, x_data, vulkan.sigmoid)
}

pub fn relu_vulkan(dev &vulkan.Device, x_data []f64) ![]f64 {
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	y_f32 := relu_vulkan_f32(dev, x_f32)!
	mut out := []f64{len: y_f32.len}
	for i, v in y_f32 {
		out[i] = f64(v)
	}
	return out
}

pub fn sigmoid_vulkan(dev &vulkan.Device, x_data []f64) ![]f64 {
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	y_f32 := sigmoid_vulkan_f32(dev, x_f32)!
	mut out := []f64{len: y_f32.len}
	for i, v in y_f32 {
		out[i] = f64(v)
	}
	return out
}
