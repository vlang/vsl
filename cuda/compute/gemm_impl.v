// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// gemm_cuda_impl is the internal GEMM implementation for CUDA.
// Uses cuBLAS dgemm when available, CPU fallback otherwise.
// All data is column-major (cuBLAS convention).
pub fn gemm_cuda_impl(mut dev cuda.Device, a_col []f64, b_col []f64, m int, n int, k int) ![]f64 {
	// TODO(#238): use cuBLAS when CUDA is available
	// cublasHandle_t handle;
	// cublasCreate(&handle);
	// double alpha = 1.0, beta = 0.0;
	// cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, m, n, k,
	//             &alpha, d_A, m, d_B, k, &beta, d_C, m);
	// For now, use CPU column-major GEMM
	return gemm_cpu_colmajor(a_col, b_col, m, n, k)
}

// gemv_cuda_impl is the internal GEMV implementation for CUDA.
// Uses cuBLAS dgvm when available, CPU fallback otherwise.
// A is column-major [m x n], x is [n], y is [m].
pub fn gemv_cuda_impl(mut dev cuda.Device, a_col []f64, x_data []f64, m int, n int) ![]f64 {
	// TODO(#238): use cuBLAS dgv when CUDA is available
	return gemv_cpu_colmajor(a_col, x_data, m, n)
}

// gemm_cpu_colmajor is column-major GEMM for CPU fallback.
fn gemm_cpu_colmajor(a_col []f64, b_col []f64, m int, n int, k int) []f64 {
	// Column-major: a_col[r + c*m], b_col[r + c*k]
	mut c_col := []f64{len: m * n}
	for col in 0 .. n {
		for row in 0 .. m {
			mut sum := f64(0.0)
			for kk in 0 .. k {
				sum += a_col[row + kk * m] * b_col[kk + col * k]
			}
			c_col[row + col * m] = sum
		}
	}
	return c_col
}

// gemv_cpu_colmajor is column-major GEMV for CPU fallback.
fn gemv_cpu_colmajor(a_col []f64, x_data []f64, m int, n int) []f64 {
	mut out := []f64{len: m}
	for row in 0 .. m {
		mut sum := f64(0.0)
		for col in 0 .. n {
			sum += a_col[row + col * m] * x_data[col]
		}
		out[row] = sum
	}
	return out
}