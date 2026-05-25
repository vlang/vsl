// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

import vsl.cuda.compute as cuda_compute

// Device represents a CUDA device handle.
// The actual type is defined in cuda.c.v with C bindings.
pub type Device = voidptr

// CUDABackend implements ComputeBackend using NVIDIA CUDA (cuBLAS/cuDNN).
//
// Status: Phase B — infrastructure ready, actual CUDA bindings deferred
// until CUDA Toolkit is available on the build machine.
//
// Memory layout: cuBLAS is column-major (same as VCL/Vulkan), so row↔col
// conversion is applied at the compute/dispatch boundary.
pub struct CUDABackend {
mut:
	dev &Device
}

pub fn new_cuda_backend() CUDABackend {
	return CUDABackend{
		dev: &Device(unsafe { nil })
	}
}

// new_cuda_backend_with_device creates a CUDABackend from an existing CUDA device.
pub fn new_cuda_backend_with_device(dev &Device) CUDABackend {
	return CUDABackend{
		dev: dev
	}
}

pub fn (b &CUDABackend) name() string {
	return 'cuda'
}

pub fn (b &CUDABackend) supports(op string) bool {
	return op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec',
		'add_scalar', 'mul_scalar', 'softmax', 'layernorm', 'conv2d']
}

pub fn (b &CUDABackend) gemm(a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	return cuda_compute.gemm_cuda(b.dev, a_data, b_data, m, n, k)
}

pub fn (b &CUDABackend) gemv(a_data []f64, x_data []f64, m int, n int) ![]f64 {
	return cuda_compute.gemv_cuda(b.dev, a_data, x_data, m, n)
}

pub fn (b &CUDABackend) relu(x_data []f64) ![]f64 {
	return cuda_compute.relu_cuda(b.dev, x_data)
}

pub fn (b &CUDABackend) sigmoid(x_data []f64) ![]f64 {
	return cuda_compute.sigmoid_cuda(b.dev, x_data)
}

pub fn (b &CUDABackend) tanh(x_data []f64) ![]f64 {
	return cuda_compute.tanh_cuda(b.dev, x_data)
}

pub fn (b &CUDABackend) add_vec(a_data []f64, b_data []f64) ![]f64 {
	return cuda_compute.add_vec_cuda(b.dev, a_data, b_data)
}

pub fn (b &CUDABackend) mul_vec(a_data []f64, b_data []f64) ![]f64 {
	return cuda_compute.mul_vec_cuda(b.dev, a_data, b_data)
}

pub fn (b &CUDABackend) add_scalar(x_data []f64, s f64) ![]f64 {
	return cuda_compute.add_scalar_cuda(b.dev, x_data, s)
}

pub fn (b &CUDABackend) mul_scalar(x_data []f64, s f64) ![]f64 {
	return cuda_compute.mul_scalar_cuda(b.dev, x_data, s)
}

pub fn (b &CUDABackend) softmax(x_data []f64) ![]f64 {
	return cuda_compute.softmax_cuda(b.dev, x_data)
}

pub fn (b &CUDABackend) layernorm(x_data []f64, gamma []f64, beta []f64) ![]f64 {
	return cuda_compute.layernorm_cuda(b.dev, x_data, gamma, beta)
}

pub fn (b &CUDABackend) conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	return cuda_compute.conv2d_cuda(b.dev, input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h,
		k_w, stride_h, stride_w)
}

// to_internal: cuBLAS is column-major, same as VCL/Vulkan.
pub fn (b &CUDABackend) to_internal(data []f64, rows int, cols int) ![]f64 {
	return row_to_col_major(data, rows, cols)
}

// from_internal: convert column-major back to row-major.
pub fn (b &CUDABackend) from_internal(data []f64, rows int, cols int) ![]f64 {
	return col_to_row_major(data, rows, cols)
}

// row_to_col_major converts row-major flat array to column-major.
fn row_to_col_major(data []f64, rows int, cols int) []f64 {
	mut out := []f64{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r + c * rows] = data[r * cols + c]
		}
	}
	return out
}

// col_to_row_major converts column-major flat array back to row-major.
fn col_to_row_major(data []f64, rows int, cols int) []f64 {
	mut out := []f64{len: data.len}
	for r in 0 .. rows {
		for c in 0 .. cols {
			out[r * cols + c] = data[r + c * rows]
		}
	}
	return out
}