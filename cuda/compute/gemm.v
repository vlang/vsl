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

// upload_i8_matrix_cuda pads and uploads a row-major INT8 matrix for reuse.
pub fn upload_i8_matrix_cuda(dev &cuda.CudaDevice, data []i8, rows int, cols int) !&CudaI8Matrix {
	if rows <= 0 || cols <= 0 {
		return error('upload_i8_matrix_cuda: matrix dimensions must be positive')
	}
	if rows > max_int / cols || data.len != rows * cols {
		return error('upload_i8_matrix_cuda: matrix dimensions do not match data length')
	}
	padded_rows := pad_i8_gemm_dimension(rows)!
	padded_cols := pad_i8_gemm_dimension(cols)!
	if padded_rows > max_int / padded_cols {
		return error('upload_i8_matrix_cuda: padded matrix dimensions exceed supported integer sizes')
	}
	mut padded_data := []i8{len: padded_rows * padded_cols}
	for row in 0 .. rows {
		for col in 0 .. cols {
			padded_data[row * padded_cols + col] = data[row * cols + col]
		}
	}
	device_data := upload_i8_matrix_cuda_impl(padded_data)!
	return &CudaI8Matrix{
		rows:        rows
		cols:        cols
		padded_rows: padded_rows
		padded_cols: padded_cols
		device_id:   dev.device_id
		data:        device_data
	}
}

// gemm_i8_i64_cuda_with_b computes A[M,K] * a reusable device matrix B[K,N].
pub fn gemm_i8_i64_cuda_with_b(dev &cuda.CudaDevice, a_data []i8, m int, n int, k int, b &CudaI8Matrix) ![]i64 {
	if m < 0 || n < 0 || k < 0 {
		return error('gemm_i8_i64_cuda_with_b: matrix dimensions must be non-negative')
	}
	if b.rows != k || b.cols != n {
		return error('gemm_i8_i64_cuda_with_b: device matrix shape does not match [${k}, ${n}]')
	}
	if b.device_id != dev.device_id {
		return error('gemm_i8_i64_cuda_with_b: device matrix belongs to CUDA device ${b.device_id}, got ${dev.device_id}')
	}
	if isnil(b.data.ptr) {
		return error('gemm_i8_i64_cuda_with_b: device matrix has been released')
	}
	if (m > 0 && k > max_int / m) || (m > 0 && n > max_int / m) {
		return error('gemm_i8_i64_cuda_with_b: matrix dimensions exceed supported integer sizes')
	}
	if a_data.len != m * k {
		return error('gemm_i8_i64_cuda_with_b: expected a_data len=${m * k}, got ${a_data.len}')
	}
	if m == 0 || n == 0 {
		return []i64{}
	}
	if k == 0 {
		return []i64{len: m * n}
	}
	padded_m := pad_i8_gemm_dimension(m)!
	padded_k := pad_i8_gemm_dimension(k)!
	if b.padded_rows != padded_k || b.padded_cols != pad_i8_gemm_dimension(n)! {
		return error('gemm_i8_i64_cuda_with_b: device matrix has incompatible padded dimensions')
	}
	if padded_m > max_int / padded_k || padded_m > max_int / b.padded_cols
		|| padded_m * b.padded_cols > max_int / int(sizeof(i64)) {
		return error('gemm_i8_i64_cuda_with_b: padded matrix dimensions exceed supported integer sizes')
	}
	mut padded_a := []i8{len: padded_m * padded_k}
	for row in 0 .. m {
		for col in 0 .. k {
			padded_a[row * padded_k + col] = a_data[row * k + col]
		}
	}
	padded_result := gemm_i8_i64_cuda_preuploaded_b_impl(dev, padded_a, b.data.ptr, padded_m,
		b.padded_cols, padded_k)!
	mut result := []i64{len: m * n}
	for row in 0 .. m {
		for col in 0 .. n {
			result[row * n + col] = padded_result[row * b.padded_cols + col]
		}
	}
	return result
}

// release frees the uploaded matrix; repeated calls are safe.
pub fn (mut b CudaI8Matrix) release() ! {
	if isnil(b.data.ptr) {
		return
	}
	status := C.cudaFree(b.data.ptr)
	if status != 0 {
		return error('CudaI8Matrix.release: cudaFree failed (status ${status})')
	}
	b.data.ptr = unsafe { nil }
	b.data.size = 0
}

// gemv_cuda computes y = A * x using cuBLAS dgemv.
// A is [m x n] row-major, x is [n], result is [m].
pub fn gemv_cuda(dev &cuda.CudaDevice, a_data []f64, x_data []f64, m int, n int) ![]f64 {
	a_col := row_to_col_major(a_data, m, n)
	return gemv_cuda_impl(dev, a_col, x_data, m, n)
}
