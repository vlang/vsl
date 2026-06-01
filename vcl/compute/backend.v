// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.vcl

// VCLBackend implements ComputeBackend using the OpenCL compute API.
pub struct VCLBackend {
mut:
	dev vcl.Device
}

// new_vcl_backend exposes this operation as part of the public API.
pub fn new_vcl_backend(mut dev vcl.Device) VCLBackend {
	return VCLBackend{
		dev: dev
	}
}

// name exposes this operation as part of the public API.
pub fn (b &VCLBackend) name() string {
	return 'vcl'
}

// supports exposes this operation as part of the public API.
pub fn (b &VCLBackend) supports(op string) bool {
	return op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec', 'add_scalar',
		'mul_scalar', 'softmax', 'layernorm', 'conv2d']
}

// gemm exposes this operation as part of the public API.
pub fn (b &VCLBackend) gemm(a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	// VCL uses column-major internally; convert row-major → col-major → compute → row-major
	a_col := row_to_col_major(a_data, m, k)
	b_col := row_to_col_major(b_data, k, n)
	mut d := b.dev
	c_col := vcl_compute.gemm_vcl(mut d, a_col, b_col, m, n, k)!
	return col_to_row_major(c_col, m, n)
}

// gemv exposes this operation as part of the public API.
pub fn (b &VCLBackend) gemv(a_data []f64, x_data []f64, m int, n int) ![]f64 {
	a_col := row_to_col_major(a_data, m, n)
	mut d := b.dev
	return vcl_compute.gemv_vcl(mut d, a_col, x_data, m, n)
}

// relu exposes this operation as part of the public API.
pub fn (b &VCLBackend) relu(x_data []f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.relu_vcl(mut d, x_data)
}

// sigmoid exposes this operation as part of the public API.
pub fn (b &VCLBackend) sigmoid(x_data []f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.sigmoid_vcl(mut d, x_data)
}

// tanh exposes this operation as part of the public API.
pub fn (b &VCLBackend) tanh(x_data []f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.tanh_vcl(mut d, x_data)
}

// add_vec exposes this operation as part of the public API.
pub fn (b &VCLBackend) add_vec(a_data []f64, b_data []f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.add_vec_vcl(mut d, a_data, b_data)
}

// mul_vec exposes this operation as part of the public API.
pub fn (b &VCLBackend) mul_vec(a_data []f64, b_data []f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.mul_vec_vcl(mut d, a_data, b_data)
}

// add_scalar exposes this operation as part of the public API.
pub fn (b &VCLBackend) add_scalar(x_data []f64, s f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.add_scalar_vcl(mut d, x_data, s)
}

// mul_scalar exposes this operation as part of the public API.
pub fn (b &VCLBackend) mul_scalar(x_data []f64, s f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.mul_scalar_vcl(mut d, x_data, s)
}

// softmax exposes this operation as part of the public API.
pub fn (b &VCLBackend) softmax(x_data []f64) ![]f64 {
	mut d := b.dev
	// softmax is row-wise; assume 1 row (vector)
	return vcl_compute.softmax_vcl(mut d, x_data, 1, x_data.len)
}

// layernorm exposes this operation as part of the public API.
pub fn (b &VCLBackend) layernorm(x_data []f64, gamma []f64, beta []f64) ![]f64 {
	mut d := b.dev
	return vcl_compute.layernorm_vcl(mut d, x_data, gamma, beta, 1, x_data.len, 1e-5)
}

// conv2d exposes this operation as part of the public API.
pub fn (b &VCLBackend) conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	mut d := b.dev
	return vcl_compute.conv2d_vcl(mut d, input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h, k_w,
		stride_h, stride_w)
}

// to_internal: VCL uses column-major, same as Vulkan.
pub fn (b &VCLBackend) to_internal(data []f64, rows int, cols int) ![]f64 {
	return row_to_col_major(data, rows, cols)
}

// from_internal: convert column-major back to row-major.
pub fn (b &VCLBackend) from_internal(data []f64, rows int, cols int) ![]f64 {
	return col_to_row_major(data, rows, cols)
}
