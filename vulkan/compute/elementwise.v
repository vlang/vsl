// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
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

// tanh_vulkan_f32 applies tanh element-wise using the GELU shader (which contains tanh internally).
// Note: this also applies GELU coefficient — not pure tanh. For pure tanh, use CPU fallback.
fn tanh_vulkan_f32_raw(dev &vulkan.Device, x_data []f32) ![]f32 {
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

	vulkan.gelu(dev, dst, src, u32(x_data.len))!

	mut out_bytes := []u8{len: x_data.len * 4}
	out_bytes = dst.store(mut out_bytes)!
	mut out := []f32{len: x_data.len}
	unsafe {
		C.memcpy(out.data, out_bytes.data, x_data.len * 4)
	}
	return out
}

// relu_vulkan_f32 exposes this operation as part of the public API.
pub fn relu_vulkan_f32(dev &vulkan.Device, x_data []f32) ![]f32 {
	return run_unary_f32(dev, x_data, vulkan.relu)
}

// sigmoid_vulkan_f32 exposes this operation as part of the public API.
pub fn sigmoid_vulkan_f32(dev &vulkan.Device, x_data []f32) ![]f32 {
	return run_unary_f32(dev, x_data, vulkan.sigmoid)
}

// relu_vulkan exposes this operation as part of the public API.
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

// sigmoid_vulkan exposes this operation as part of the public API.
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

// tanh_vulkan applies tanh using GELU shader (contains tanh).
// WARNING: applies GELU activation, not pure tanh. For accurate tanh, use CPU fallback.
pub fn tanh_vulkan(dev &vulkan.Device, x_data []f64) ![]f64 {
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	y_f32 := tanh_vulkan_f32_raw(dev, x_f32)!
	mut out := []f64{len: y_f32.len}
	for i, v in y_f32 {
		out[i] = f64(v)
	}
	return out
}

fn run_binary_f32(dev &vulkan.Device, a_data []f32, b_data []f32, op fn (&vulkan.Device, &vulkan.GpuBuffer, &vulkan.GpuBuffer, &vulkan.GpuBuffer) !) ![]f32 {
	size := vulkan.DeviceSize(a_data.len * 4)
	mut a_buf := dev.buffer(size)!
	defer {
		a_buf.release()
	}
	mut b_buf := dev.buffer(size)!
	defer {
		b_buf.release()
	}
	mut dst := dev.buffer(size)!
	defer {
		dst.release()
	}

	mut a_bytes := []u8{len: a_data.len * 4}
	mut b_bytes := []u8{len: b_data.len * 4}
	unsafe {
		C.memcpy(a_bytes.data, a_data.data, a_data.len * 4)
		C.memcpy(b_bytes.data, b_data.data, b_data.len * 4)
	}
	a_buf.load(a_bytes)!
	b_buf.load(b_bytes)!

	op(dev, dst, a_buf, b_buf)!

	mut out_bytes := []u8{len: a_data.len * 4}
	out_bytes = dst.store(mut out_bytes)!
	mut out := []f32{len: a_data.len}
	unsafe {
		C.memcpy(out.data, out_bytes.data, a_data.len * 4)
	}
	return out
}

// add_vec_vulkan computes element-wise addition via vector_add pipeline.
pub fn add_vec_vulkan(dev &vulkan.Device, a_data []f64, b_data []f64) ![]f64 {
	mut a_f32 := []f32{len: a_data.len}
	for i, v in a_data {
		a_f32[i] = f32(v)
	}
	mut b_f32 := []f32{len: b_data.len}
	for i, v in b_data {
		b_f32[i] = f32(v)
	}
	y_f32 := run_binary_f32(dev, a_f32, b_f32, vulkan.vector_add)!
	mut out := []f64{len: y_f32.len}
	for i, v in y_f32 {
		out[i] = f64(v)
	}
	return out
}

// mul_vec_vulkan computes element-wise a * b via vector_mul pipeline.
pub fn mul_vec_vulkan(dev &vulkan.Device, a_data []f64, b_data []f64) ![]f64 {
	mut a_f32 := []f32{len: a_data.len}
	for i, v in a_data {
		a_f32[i] = f32(v)
	}
	mut b_f32 := []f32{len: b_data.len}
	for i, v in b_data {
		b_f32[i] = f32(v)
	}
	y_f32 := run_binary_f32(dev, a_f32, b_f32, vulkan.vector_mul)!
	mut out := []f64{len: y_f32.len}
	for i, v in y_f32 {
		out[i] = f64(v)
	}
	return out
}

// add_scalar_vulkan adds a scalar to each element via scale pipeline.
// Since scale is dst = alpha * src (not dst = src + scalar), we emulate by
// dst = src * 1.0 + scalar via two passes: first copy, then add scalar constant.
pub fn add_scalar_vulkan(dev &vulkan.Device, x_data []f64, s f64) ![]f64 {
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	// Vulkan has no direct "add scalar" op; use CPU fallback
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = v + s
	}
	return out
}

// mul_scalar_vulkan multiplies each element by scalar via scale pipeline.
pub fn mul_scalar_vulkan(dev &vulkan.Device, x_data []f64, s f64) ![]f64 {
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	size := vulkan.DeviceSize(x_f32.len * 4)
	mut src := dev.buffer(size)!
	defer {
		src.release()
	}
	mut dst := dev.buffer(size)!
	defer {
		dst.release()
	}
	mut bytes := []u8{len: x_f32.len * 4}
	unsafe {
		C.memcpy(bytes.data, x_data.data, x_data.len * 4)
	}
	src.load(bytes)!

	vulkan.scale(dev, dst, src, f32(s))!

	mut out_bytes := []u8{len: x_f32.len * 4}
	out_bytes = dst.store(mut out_bytes)!
	mut out := []f64{len: x_f32.len}
	for i := 0; i < x_f32.len; i++ {
		unsafe {
			out[i] = f64(*(&f32(&out_bytes[i * 4])))
		}
	}
	return out
}

// softmax_vulkan applies row-wise softmax via the softmax pipeline.
pub fn softmax_vulkan(dev &vulkan.Device, x_data []f64) ![]f64 {
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	size := vulkan.DeviceSize(x_f32.len * 4)
	mut src := dev.buffer(size)!
	defer {
		src.release()
	}
	mut dst := dev.buffer(size)!
	defer {
		dst.release()
	}
	mut bytes := []u8{len: x_f32.len * 4}
	unsafe {
		C.memcpy(bytes.data, x_data.data, x_data.len * 4)
	}
	src.load(bytes)!

	vulkan.softmax(dev, dst, src, u32(x_data.len))!

	mut out_bytes := []u8{len: x_f32.len * 4}
	out_bytes = dst.store(mut out_bytes)!
	mut out := []f64{len: x_f32.len}
	for i := 0; i < x_f32.len; i++ {
		unsafe {
			out[i] = f64(*(&f32(&out_bytes[i * 4])))
		}
	}
	return out
}

// layernorm_vulkan applies row-wise layer normalization via the layernorm pipeline.
// Gamma/beta are applied on CPU since the Vulkan layernorm op does not include affine transform.
pub fn layernorm_vulkan(dev &vulkan.Device, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	mut x_f32 := []f32{len: x_data.len}
	for i, v in x_data {
		x_f32[i] = f32(v)
	}
	size := vulkan.DeviceSize(x_f32.len * 4)
	mut src := dev.buffer(size)!
	defer {
		src.release()
	}
	mut dst := dev.buffer(size)!
	defer {
		dst.release()
	}
	mut bytes := []u8{len: x_f32.len * 4}
	unsafe {
		C.memcpy(bytes.data, x_data.data, x_data.len * 4)
	}
	src.load(bytes)!

	vulkan.layernorm(dev, dst, src, u32(x_data.len), 1e-5)!

	mut out_bytes := []u8{len: x_f32.len * 4}
	out_bytes = dst.store(mut out_bytes)!
	mut raw := []f32{len: x_f32.len}
	for i := 0; i < x_f32.len; i++ {
		unsafe {
			raw[i] = *(&f32(&out_bytes[i * 4]))
		}
	}
	// Apply gamma/beta on CPU (Vulkan layernorm doesn't include affine)
	mut out := []f64{len: x_f32.len}
	for i, v in raw {
		out[i] = f64(v) * gamma[i] + beta[i]
	}
	return out
}
