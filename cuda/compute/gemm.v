// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// gemm_cuda computes C = A * B using cuBLAS dgemm (column-major, f64).
// Inputs/outputs are row-major externally (VSL convention).
// Internally: row→col-major conversion → cuBLAS → col→row-major result.
pub fn gemm_cuda(dev voidptr, a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	// cuBLAS is column-major: A[m x k] col-major, B[k x n] col-major, C[m x n] col-major
	a_col := row_to_col_major(a_data, m, k)
	b_col := row_to_col_major(b_data, k, n)
	c_col := gemm_cuda_impl(dev, a_col, b_col, m, n, k)!
	return col_to_row_major(c_col, m, n)
}

// gemv_cuda computes y = A * x using cuBLAS dgvm (column-major, f64).
// A is [m x n] column-major, x is [n], y is [m].
pub fn gemv_cuda(dev voidptr, a_data []f64, x_data []f64, m int, n int) ![]f64 {
	a_col := row_to_col_major(a_data, m, n)
	return gemv_cuda_impl(dev, a_col, x_data, m, n)
}