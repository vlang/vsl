// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.cuda

// CUDABackend implements ComputeBackend using NVIDIA CUDA (cuBLAS/cuDNN).
//
// Status: Phase B — cuBLAS/cuDNN bindings active; operations run on GPU
// when a CUDA device is available, with CPU fallback otherwise.
//
// Memory layout: cuBLAS is column-major (same as VCL/Vulkan), so row↔col
// conversion is applied at the compute/dispatch boundary.

// CUDABackend defines a public data structure for this module.

// CUDABackend defines a public data structure for this module.
@[heap]
pub struct CUDABackend {
mut:
	dev &cuda.CudaDevice
}

// new_cuda_backend creates a CUDABackend with the default CUDA device.
// Returns an error if no CUDA devices are available or initialization fails.
pub fn new_cuda_backend() !CUDABackend {
	dev := cuda.get_default_device()!
	return CUDABackend{
		dev: dev
	}
}

// new_cuda_backend_with_device creates a CUDABackend from an existing CudaDevice.
pub fn new_cuda_backend_with_device(dev &cuda.CudaDevice) CUDABackend {
	return CUDABackend{
		dev: dev
	}
}

// name exposes this operation as part of the public API.
pub fn (b &CUDABackend) name() string {
	return 'cuda'
}

// supports exposes this operation as part of the public API.
pub fn (b &CUDABackend) supports(op string) bool {
	return op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec', 'add_scalar',
		'mul_scalar', 'softmax', 'layernorm', 'conv2d']
}

// gemm exposes this operation as part of the public API.
pub fn (b &CUDABackend) gemm(a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	return gemm_cuda(b.dev, a_data, b_data, m, n, k)
}

// gemv exposes this operation as part of the public API.
pub fn (b &CUDABackend) gemv(a_data []f64, x_data []f64, m int, n int) ![]f64 {
	return gemv_cuda(b.dev, a_data, x_data, m, n)
}

// relu exposes this operation as part of the public API.
pub fn (b &CUDABackend) relu(x_data []f64) ![]f64 {
	return relu_cuda(b.dev, x_data)
}

// sigmoid exposes this operation as part of the public API.
pub fn (b &CUDABackend) sigmoid(x_data []f64) ![]f64 {
	return sigmoid_cuda(b.dev, x_data)
}

// tanh exposes this operation as part of the public API.
pub fn (b &CUDABackend) tanh(x_data []f64) ![]f64 {
	return tanh_cuda(b.dev, x_data)
}

// add_vec exposes this operation as part of the public API.
pub fn (b &CUDABackend) add_vec(a_data []f64, b_data []f64) ![]f64 {
	return add_vec_cuda(b.dev, a_data, b_data)
}

// mul_vec exposes this operation as part of the public API.
pub fn (b &CUDABackend) mul_vec(a_data []f64, b_data []f64) ![]f64 {
	return mul_vec_cuda(b.dev, a_data, b_data)
}

// add_scalar exposes this operation as part of the public API.
pub fn (b &CUDABackend) add_scalar(x_data []f64, s f64) ![]f64 {
	return add_scalar_cuda(b.dev, x_data, s)
}

// mul_scalar exposes this operation as part of the public API.
pub fn (b &CUDABackend) mul_scalar(x_data []f64, s f64) ![]f64 {
	return mul_scalar_cuda(b.dev, x_data, s)
}

// softmax exposes this operation as part of the public API.
pub fn (b &CUDABackend) softmax(x_data []f64) ![]f64 {
	return softmax_cuda(b.dev, x_data)
}

// layernorm exposes this operation as part of the public API.
pub fn (b &CUDABackend) layernorm(x_data []f64, gamma []f64, beta []f64) ![]f64 {
	return layernorm_cuda(b.dev, x_data, gamma, beta)
}

// conv2d exposes this operation as part of the public API.
pub fn (b &CUDABackend) conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	return conv2d_cuda(b.dev, input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h, k_w, stride_h,
		stride_w)
}

// to_internal: cuBLAS is column-major, same as VCL/Vulkan.
pub fn (b &CUDABackend) to_internal(data []f64, rows int, cols int) ![]f64 {
	return row_to_col_major(data, rows, cols)
}

// from_internal: convert column-major back to row-major.
pub fn (b &CUDABackend) from_internal(data []f64, rows int, cols int) ![]f64 {
	return col_to_row_major(data, rows, cols)
}
