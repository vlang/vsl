// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// CUDABackend is a stub ComputeBackend implementation for CUDA.
// Phase B (#238) will replace this with actual cuBLAS/cuDNN bindings.
pub struct CUDABackend {
mut:
	strict bool
}

pub fn new_cuda_backend() CUDABackend {
	return CUDABackend{}
}

pub fn (b &CUDABackend) name() string {
	return 'cuda'
}

pub fn (b &CUDABackend) supports(op string) bool {
	// All ops return not-implemented errors below
	return op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec',
		'add_scalar', 'mul_scalar', 'softmax', 'layernorm', 'conv2d']
}

pub fn (b &CUDABackend) gemm(a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	return error('CUDABackend.gemm: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) gemv(a_data []f64, x_data []f64, m int, n int) ![]f64 {
	return error('CUDABackend.gemv: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) relu(x_data []f64) ![]f64 {
	return error('CUDABackend.relu: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) sigmoid(x_data []f64) ![]f64 {
	return error('CUDABackend.sigmoid: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) tanh(x_data []f64) ![]f64 {
	return error('CUDABackend.tanh: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) add_vec(a_data []f64, b_data []f64) ![]f64 {
	return error('CUDABackend.add_vec: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) mul_vec(a_data []f64, b_data []f64) ![]f64 {
	return error('CUDABackend.mul_vec: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) add_scalar(x_data []f64, s f64) ![]f64 {
	return error('CUDABackend.add_scalar: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) mul_scalar(x_data []f64, s f64) ![]f64 {
	return error('CUDABackend.mul_scalar: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) softmax(x_data []f64) ![]f64 {
	return error('CUDABackend.softmax: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) layernorm(x_data []f64, gamma []f64, beta []f64) ![]f64 {
	return error('CUDABackend.layernorm: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	return error('CUDABackend.conv2d: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) to_internal(data []f64, rows int, cols int) ![]f64 {
	return data // identity for stub
}

pub fn (b &CUDABackend) from_internal(data []f64, rows int, cols int) ![]f64 {
	return data // identity for stub
}