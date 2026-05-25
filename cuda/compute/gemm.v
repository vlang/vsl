// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.cuda

// gemm_cuda computes C = A * B using cuBLAS dgemm.
// Inputs/outputs are row-major (VSL convention); cuBLAS column-major conversion
// is handled internally (row→col before, col→row after).
// A is [m x k], B is [k x n], result is [m x n].
pub fn gemm_cuda(dev &cuda.CudaDevice, a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	a_col := row_to_col_major(a_data, m, k)
	b_col := row_to_col_major(b_data, k, n)
	c_col := gemm_cuda_impl(dev, a_col, b_col, m, n, k)!
	return col_to_row_major(c_col, m, n)
}

// gemv_cuda computes y = A * x using cuBLAS dgemv.
// A is [m x n] row-major, x is [n], result is [m].
pub fn gemv_cuda(dev &cuda.CudaDevice, a_data []f64, x_data []f64, m int, n int) ![]f64 {
	a_col := row_to_col_major(a_data, m, n)
	return gemv_cuda_impl(dev, a_col, x_data, m, n)
}
