// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import math

// ComputeBackend is the interface that all compute backends must implement.
// Each backend owns its device lifecycle, memory layout, and kernel management.
pub interface ComputeBackend {
	// name returns the backend identifier (e.g., 'vulkan', 'cuda', 'vcl', 'cpu').
	name() string

	// supports returns true when an operation is implemented by this backend.
	supports(op string) bool

	// gemm computes C = A * B with row-major input/output.
	// A: [m x k], B: [k x n], result: [m x n].
	gemm(a []f64, b []f64, m int, n int, k int) ![]f64

	// gemv computes y = A * x with row-major A and result vector y.
	gemv(a_data []f64, x_data []f64, m int, n int) ![]f64

	// Element-wise unary ops.
	relu(x []f64) ![]f64
	sigmoid(x []f64) ![]f64
	tanh(x []f64) ![]f64

	// Element-wise binary ops.
	add_vec(a []f64, b []f64) ![]f64
	mul_vec(a []f64, b []f64) ![]f64

	// Scalar ops.
	add_scalar(x []f64, s f64) ![]f64
	mul_scalar(x []f64, s f64) ![]f64

	// Advanced ops.
	softmax(x []f64) ![]f64
	layernorm(x []f64, gamma []f64, beta []f64) ![]f64

	// conv2d computes 2D convolution: input [batch x in_h x in_w x in_ch],
	// kernel [out_ch x k_h x k_w x in_ch], output [batch x out_h x out_w x out_ch].
	conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64

	// to_internal converts row-major data to the backend's internal layout.
	to_internal(data []f64, rows int, cols int) ![]f64

	// from_internal converts backend-internal layout back to row-major.
	from_internal(data []f64, rows int, cols int) ![]f64
}

// Supported operations by any backend.
pub const supported_ops = ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec',
	'add_scalar', 'mul_scalar', 'softmax', 'layernorm', 'conv2d']

// new_cpu_backend creates a new CPU backend instance.
pub fn new_cpu_backend() CPUBackend {
	return CPUBackend{}
}

// CPUBackend is a pure-V fallback backend using naive V loops.
// Suitable when no GPU backend is available.
pub struct CPUBackend {
mut:
	strict bool
}

pub fn (c &CPUBackend) name() string {
	return 'cpu'
}

pub fn (c &CPUBackend) supports(op string) bool {
	return op in supported_ops
}

pub fn (c &CPUBackend) gemm(a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	if a_data.len != m * k {
		return error('CPUBackend.gemm: expected a len=${m * k}, got ${a_data.len}')
	}
	if b_data.len != k * n {
		return error('CPUBackend.gemm: expected b len=${k * n}, got ${b_data.len}')
	}
	return gemm_cpu_f64(a_data, b_data, m, n, k)
}

pub fn (c &CPUBackend) gemv(a []f64, x []f64, m int, n int) ![]f64 {
	if a.len != m * n {
		return error('CPUBackend.gemv: expected a len=${m * n}, got ${a.len}')
	}
	if x.len != n {
		return error('CPUBackend.gemv: expected x len=${n}, got ${x.len}')
	}
	return gemv_cpu_f64(a, x, m, n)
}

pub fn (c &CPUBackend) relu(x []f64) ![]f64 {
	return relu_cpu_f64(x)
}

pub fn (c &CPUBackend) sigmoid(x []f64) ![]f64 {
	return sigmoid_cpu_f64(x)
}

pub fn (c &CPUBackend) tanh(x []f64) ![]f64 {
	return tanh_cpu_f64(x)
}

pub fn (c &CPUBackend) add_vec(a_data []f64, b_data []f64) ![]f64 {
	return add_vec_cpu_f64(a_data, b_data)
}

pub fn (c &CPUBackend) mul_vec(a_data []f64, b_data []f64) ![]f64 {
	return mul_vec_cpu_f64(a_data, b_data)
}

pub fn (c &CPUBackend) add_scalar(x []f64, s f64) ![]f64 {
	return add_scalar_cpu_f64(x, s)
}

pub fn (c &CPUBackend) mul_scalar(x []f64, s f64) ![]f64 {
	return mul_scalar_cpu_f64(x, s)
}

pub fn (c &CPUBackend) softmax(x []f64) ![]f64 {
	return softmax_cpu_f64(x)
}

pub fn (c &CPUBackend) layernorm(x []f64, gamma []f64, beta []f64) ![]f64 {
	return layernorm_cpu_f64(x, gamma, beta)
}

pub fn (c &CPUBackend) conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	return error('CPUBackend.conv2d: not implemented')
}

pub fn (c &CPUBackend) to_internal(data []f64, rows int, cols int) ![]f64 {
	return data // row-major = identity for CPU
}

pub fn (c &CPUBackend) from_internal(data []f64, rows int, cols int) ![]f64 {
	return data // row-major = identity for CPU
}

// softmax_cpu_f64 computes row-wise softmax on CPU (numerically stable).
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

// layernorm_cpu_f64 computes row-wise layer norm on CPU.
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