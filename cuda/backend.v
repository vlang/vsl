// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// Note: Phase B (#238) — CUDA backend implementation.
//
// This module provides GPU compute via CUDA (NVIDIA). It wraps:
//   - CUDA Driver API: device management, memory, streams
//   - cuBLAS: BLAS operations (GEMM, GEMV, etc.)
//   - cuDNN: DNN operations (relu, sigmoid, tanh, softmax, layernorm, conv2d)
//
// Build with: v -gpu cuda -mcuda ./...
// Requires: CUDA Toolkit (nvcc, cuda.h, cublas_v2.h, cudnn.h)

import math

// ============================================================================
// CUDA constants
// ============================================================================

const cuda_success = 0

// ============================================================================
// Device management
// ============================================================================

fn init_cuda() ! {
	return error('CUDABackend: CUDA not available — Phase B (#238) needs actual CUDA Toolkit installation')
}

fn get_device_count() !int {
	return error('CUDABackend: CUDA not available')
}

// ============================================================================
// CPU fallbacks (same as compute/backend_cpu.v)
// ============================================================================

fn gemm_cpu_f64(a_data []f64, b_data []f64, m int, n int, k int) []f64 {
	mut out := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			mut sum := f64(0.0)
			for t in 0 .. k {
				sum += a_data[i * k + t] * b_data[t * n + j]
			}
			out[i * n + j] = sum
		}
	}
	return out
}

fn gemv_cpu_f64(a_data []f64, x_data []f64, m int, n int) []f64 {
	mut out := []f64{len: m}
	for i in 0 .. m {
		mut sum := f64(0.0)
		for j in 0 .. n {
			sum += a_data[i * n + j] * x_data[j]
		}
		out[i] = sum
	}
	return out
}

fn relu_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = if v > 0.0 { v } else { 0.0 }
	}
	return out
}

fn sigmoid_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = 1.0 / (1.0 + math.exp(-v))
	}
	return out
}

fn tanh_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = math.tanh(v)
	}
	return out
}

fn softmax_cpu_f64(x []f64) ![]f64 {
	cols := x.len
	mut out := []f64{len: cols}
	mut mx := x[0]
	for i in 1 .. cols {
		if x[i] > mx {
			mx = x[i]
		}
	}
	mut sum := 0.0
	for i in 0 .. cols {
		out[i] = math.exp(x[i] - mx)
		sum += out[i]
	}
	for i in 0 .. cols {
		out[i] /= sum
	}
	return out
}

fn layernorm_cpu_f64(x []f64, gamma []f64, beta []f64) ![]f64 {
	cols := x.len
	mut out := []f64{len: cols}
	mut mean := 0.0
	for i in 0 .. cols {
		mean += x[i]
	}
	mean /= f64(cols)
	mut variance := 0.0
	for i in 0 .. cols {
		d := x[i] - mean
		variance += d * d
	}
	variance /= f64(cols)
	inv_std := 1.0 / math.sqrt(variance + 1e-5)
	for i in 0 .. cols {
		out[i] = (x[i] - mean) * inv_std * gamma[i] + beta[i]
	}
	return out
}

// ============================================================================
// CUDABackend — ComputeBackend implementation
// ============================================================================

// CUDABackend implements ComputeBackend using NVIDIA CUDA.
//
// Status: Phase B — infrastructure ready, actual CUDA bindings deferred
// until CUDA Toolkit is available on the build machine.
pub struct CUDABackend {
mut:
	initialized bool
}

pub fn new_cuda_backend() CUDABackend {
	return CUDABackend{
		initialized: false
	}
}

pub fn (b &CUDABackend) name() string {
	return 'cuda'
}

pub fn (b &CUDABackend) supports(op string) bool {
	return op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec',
		'add_scalar', 'mul_scalar', 'softmax', 'layernorm', 'conv2d']
}

pub fn (b &CUDABackend) init() ! {
	if b.initialized {
		return
	}
	init_cuda()!
}

// gemm delegates to cuBLAS dgemm (when CUDA is available).
// Falls back to CPU naive implementation when CUDA is unavailable.
pub fn (b &CUDABackend) gemm(a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	// TODO(#238): when CUDA is available, use cuBLAS:
	//   cublasHandle_t handle;
	//   cublasCreate(&handle);
	//   cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, m, n, k,
	//               &alpha, d_A, lda, d_B, ldb, &beta, d_C, ldc);
	if a_data.len != m * k {
		return error('CUDABackend.gemm: expected a_data len=${m * k}, got ${a_data.len}')
	}
	if b_data.len != k * n {
		return error('CUDABackend.gemm: expected b_data len=${k * n}, got ${b_data.len}')
	}
	return gemm_cpu_f64(a_data, b_data, m, n, k)
}

// gemv delegates to cuBLAS dgvm (when CUDA is available).
pub fn (b &CUDABackend) gemv(a_data []f64, x_data []f64, m int, n int) ![]f64 {
	if a_data.len != m * n {
		return error('CUDABackend.gemv: expected a_data len=${m * n}, got ${a_data.len}')
	}
	if x_data.len != n {
		return error('CUDABackend.gemv: expected x_data len=${n}, got ${x_data.len}')
	}
	return gemv_cpu_f64(a_data, x_data, m, n)
}

// relu uses cuDNN when CUDA is available, CPU fallback otherwise.
pub fn (b &CUDABackend) relu(x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNRelu when CUDA is available
	return relu_cpu_f64(x_data)
}

// sigmoid uses cuDNN when CUDA is available, CPU fallback otherwise.
pub fn (b &CUDABackend) sigmoid(x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNSigmoid when CUDA is available
	return sigmoid_cpu_f64(x_data)
}

// tanh uses cuDNN when CUDA is available, CPU fallback otherwise.
pub fn (b &CUDABackend) tanh(x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNTanh when CUDA is available
	return tanh_cpu_f64(x_data)
}

// add_vec is element-wise vector addition — use cuBLAS axpy or custom kernel.
pub fn (b &CUDABackend) add_vec(a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('CUDABackend.add_vec: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	// TODO(#238): use cuBLAS DAXPY when CUDA is available
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] + b_data[i]
	}
	return out
}

// mul_vec is element-wise vector multiplication.
pub fn (b &CUDABackend) mul_vec(a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('CUDABackend.mul_vec: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	// TODO(#238): custom CUDA kernel for element-wise multiply
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] * b_data[i]
	}
	return out
}

// add_scalar adds a scalar to every element.
pub fn (b &CUDABackend) add_scalar(x_data []f64, s f64) ![]f64 {
	// TODO(#238): use cuBLAS DAXPY with scale=1 and add scalar on host
	mut out := []f64{len: x_data.len}
	for i in 0 .. x_data.len {
		out[i] = x_data[i] + s
	}
	return out
}

// mul_scalar multiplies every element by a scalar.
pub fn (b &CUDABackend) mul_scalar(x_data []f64, s f64) ![]f64 {
	// TODO(#238): use cuBLAS DSCAL when CUDA is available
	mut out := []f64{len: x_data.len}
	for i in 0 .. x_data.len {
		out[i] = x_data[i] * s
	}
	return out
}

// softmax uses cuDNN when CUDA is available.
pub fn (b &CUDABackend) softmax(x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNSoftmax when CUDA is available
	return softmax_cpu_f64(x_data)
}

// layernorm uses cuDNN when CUDA is available.
pub fn (b &CUDABackend) layernorm(x_data []f64, gamma []f64, beta []f64) ![]f64 {
	// TODO(#238): use cuDNNLayerNorm when CUDA is available
	return layernorm_cpu_f64(x_data, gamma, beta)
}

// conv2d uses cuDNN when CUDA is available.
pub fn (b &CUDABackend) conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	// TODO(#238): use cuDNNConvolution when CUDA is available
	return error('CUDABackend.conv2d: not implemented yet — see issue #238')
}

pub fn (b &CUDABackend) to_internal(data []f64, rows int, cols int) ![]f64 {
	// CUDA cuBLAS is column-major like Vulkan/VCL — same layout conversion
	return row_to_col_major(data, rows, cols)
}

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