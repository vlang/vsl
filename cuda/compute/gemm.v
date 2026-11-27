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

// gemm_i8_i64_cuda computes C = A * B for row-major signed INT8 matrices and
// returns exact INT64 accumulators. INT32 GPU reductions are split as needed.
pub fn gemm_i8_i64_cuda(dev &cuda.CudaDevice, a_data []i8, b_data []i8, m int, n int, k int) ![]i64 {
	if m < 0 || n < 0 || k < 0 {
		return error('gemm_i8_i64_cuda: matrix dimensions must be non-negative')
	}
	if (m > 0 && k > max_int / m) || (k > 0 && n > max_int / k)
		|| (m > 0 && n > max_int / m) {
		return error('gemm_i8_i64_cuda: matrix dimensions exceed supported integer sizes')
	}
	if a_data.len != m * k {
		return error('gemm_i8_i64_cuda: expected a_data len=${m * k}, got ${a_data.len}')
	}
	if b_data.len != k * n {
		return error('gemm_i8_i64_cuda: expected b_data len=${k * n}, got ${b_data.len}')
	}
	if m == 0 || n == 0 {
		return []i64{}
	}
	if k == 0 {
		return []i64{len: m * n}
	}
	padded_m := pad_i8_gemm_dimension(m)!
	padded_n := pad_i8_gemm_dimension(n)!
	padded_k := pad_i8_gemm_dimension(k)!
	if padded_m > max_int / padded_k || padded_k > max_int / padded_n
		|| padded_m > max_int / padded_n
		|| padded_m * padded_n > max_int / int(sizeof(i64)) {
		return error('gemm_i8_i64_cuda: padded matrix dimensions exceed supported integer sizes')
	}
	mut padded_a := []i8{len: padded_m * padded_k}
	mut padded_b := []i8{len: padded_k * padded_n}
	for row in 0 .. m {
		for col in 0 .. k {
			padded_a[row * padded_k + col] = a_data[row * k + col]
		}
	}
	for row in 0 .. k {
		for col in 0 .. n {
			padded_b[row * padded_n + col] = b_data[row * n + col]
		}
	}
	padded_result := gemm_i8_i64_cuda_impl(dev, padded_a, padded_b, padded_m, padded_n,
		padded_k)!
	mut result := []i64{len: m * n}
	for row in 0 .. m {
		for col in 0 .. n {
			result[row * n + col] = padded_result[row * padded_n + col]
		}
	}
	return result
}

fn pad_i8_gemm_dimension(value int) !int {
	padding := (4 - value % 4) % 4
	if value > max_int - padding {
		return error('gemm_i8_i64_cuda: padded matrix dimensions exceed supported integer sizes')
	}
	return value + padding
}

// gemv_cuda computes y = A * x using cuBLAS dgemv.
// A is [m x n] row-major, x is [n], result is [m].
pub fn gemv_cuda(dev &cuda.CudaDevice, a_data []f64, x_data []f64, m int, n int) ![]f64 {
	a_col := row_to_col_major(a_data, m, n)
	return gemv_cuda_impl(dev, a_col, x_data, m, n)
}
