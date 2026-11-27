// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.cuda

// GpuBuf is a private helper for managing a GPU device memory buffer.
// It mirrors the role of vcl.Vector / vulkan.GpuBuffer in those backends.
struct GpuBuf {
mut:
	ptr  voidptr
	size int
}

// CudaI8Matrix owns an aligned signed-INT8 matrix uploaded to a CUDA device.
@[heap]
pub struct CudaI8Matrix {
mut:
	rows        int
	cols        int
	padded_rows int
	padded_cols int
	device_id   int
	data GpuBuf
}

// gpu_buf_new allocates count * sizeof(T) bytes on the GPU.
fn gpu_buf_new[T](count int) !GpuBuf {
	mut ptr := unsafe { nil }
	sz := int(sizeof(T)) * count
	status := C.cudaMalloc(&ptr, sz)
	if status != 0 {
		return error('gpu_buf_new: cudaMalloc failed (status ${status})')
	}
	return GpuBuf{
		ptr:  ptr
		size: sz
	}
}

// upload copies host slice → GPU buffer.
fn (mut b GpuBuf) upload[T](data []T) ! {
	status := C.cudaMemcpy(b.ptr, data.data, int(sizeof(T)) * data.len,
		C.cuda_memcpy_host_to_device)
	if status != 0 {
		return error('GpuBuf.upload: cudaMemcpy H→D failed (status ${status})')
	}
}

// download copies GPU buffer → host slice.
fn (b &GpuBuf) download[T](mut out []T) ! {
	status := C.cudaMemcpy(out.data, b.ptr, int(sizeof(T)) * out.len, C.cuda_memcpy_device_to_host)
	if status != 0 {
		return error('GpuBuf.download: cudaMemcpy D→H failed (status ${status})')
	}
}

const max_i8_gemm_reduction = 131068

// release frees the GPU buffer.
fn (b &GpuBuf) release() {
	if !isnil(b.ptr) {
		C.cudaFree(b.ptr)
	}
}

// gemm_cuda_impl computes C = A * B using cuBLAS dgemm (column-major, f64).
// All inputs/outputs are column-major (cuBLAS convention).
pub fn gemm_cuda_impl(dev &cuda.CudaDevice, a_col []f64, b_col []f64, m int, n int, k int) ![]f64 {
	alpha := f64(1.0)
	beta := f64(0.0)

	mut d_a := gpu_buf_new[f64](m * k)!
	defer { d_a.release() }
	mut d_b := gpu_buf_new[f64](k * n)!
	defer { d_b.release() }
	mut d_c := gpu_buf_new[f64](m * n)!
	defer { d_c.release() }

	d_a.upload[f64](a_col)!
	d_b.upload[f64](b_col)!

	// cuBLAS dgemm: C = alpha*A*B + beta*C  (column-major)
	// cublasOperation_t: 0=non-transpose, 1=transpose, 2=conjugate-transpose
	status := C.cublasDgemm_v2(dev.cublas, 0, 0, m, n, k, &alpha, &f64(d_a.ptr), m, &f64(d_b.ptr),
		k, &beta, &f64(d_c.ptr), m)
	if status != cuda.cublas_status_success {
		return error('gemm_cuda_impl: cublasDgemm_v2 failed: ${cuda.cublas_error(status)}')
	}

	mut c_col := []f64{len: m * n}
	d_c.download[f64](mut c_col)!
	return c_col
}

// gemm_i8_i64_cuda_impl computes row-major A[M,K] * B[K,N] with cuBLAS.
// Each device reduction is bounded so its exact INT32 result cannot overflow.
fn gemm_i8_i64_cuda_impl(dev &cuda.CudaDevice, a_data []i8, b_data []i8, m int, n int, k int) ![]i64 {
	mut d_b := gpu_buf_new[i8](b_data.len)!
	defer { d_b.release() }
	d_b.upload[i8](b_data)!
	return gemm_i8_i64_cuda_preuploaded_b_impl(dev, a_data, d_b.ptr, m, n, k)
}

fn upload_i8_matrix_cuda_impl(data []i8) !GpuBuf {
	mut device_data := gpu_buf_new[i8](data.len)!
	device_data.upload[i8](data) or {
		device_data.release()
		return err
	}
	return device_data
}

fn gemm_i8_i64_cuda_preuploaded_b_impl(dev &cuda.CudaDevice, a_data []i8, b_ptr voidptr, m int, n int, k int) ![]i64 {
	mut d_a := gpu_buf_new[i8](a_data.len)!
	defer { d_a.release() }
	mut d_c := gpu_buf_new[i32](m * n)!
	defer { d_c.release() }
	d_a.upload[i8](a_data)!
	alpha := i32(1)
	beta := i32(0)
	mut result := []i64{len: m * n}
	mut partial := []i32{len: m * n}
	for k_start := 0; k_start < k; k_start += max_i8_gemm_reduction {
		chunk_k := if k - k_start > max_i8_gemm_reduction {
			max_i8_gemm_reduction
		} else {
			k - k_start
		}
		// Row-major buffers are interpreted as their transposed column-major views:
		// Cᵀ = Bᵀ * Aᵀ.
		// CUDA is supported only on 64-bit targets; uint may truncate device addresses.
		chunk_b_ptr := unsafe { voidptr(u64(b_ptr) + u64(k_start * n)) }
		a_ptr := unsafe { voidptr(u64(d_a.ptr) + u64(k_start)) }
		status := C.cublasGemmEx(dev.cublas, cuda.cublas_op_n, cuda.cublas_op_n, n, m,
			chunk_k, &alpha, chunk_b_ptr, cuda.cuda_data_type_i8, n, a_ptr,
			cuda.cuda_data_type_i8, k, &beta, d_c.ptr, cuda.cuda_data_type_i32, n,
			cuda.cublas_compute_32i, cuda.cublas_gemm_default)
		if status != cuda.cublas_status_success {
			return error('gemm_i8_i64_cuda_impl: cublasGemmEx failed: ${cuda.cublas_error(status)}')
		}
		d_c.download[i32](mut partial)!
		for i, value in partial {
			result[i] += i64(value)
		}
	}
	return result
}

// gemv_cuda_impl computes y = A * x using cuBLAS dgemv (column-major, f64).
pub fn gemv_cuda_impl(dev &cuda.CudaDevice, a_col []f64, x_data []f64, m int, n int) ![]f64 {
	alpha := f64(1.0)
	beta := f64(0.0)

	mut d_a := gpu_buf_new[f64](m * n)!
	defer { d_a.release() }
	mut d_x := gpu_buf_new[f64](n)!
	defer { d_x.release() }
	mut d_y := gpu_buf_new[f64](m)!
	defer { d_y.release() }

	d_a.upload[f64](a_col)!
	d_x.upload[f64](x_data)!

	status := C.cublasDgemv_v2(dev.cublas, 0, m, n, &alpha, &f64(d_a.ptr), m, &f64(d_x.ptr), 1,
		&beta, &f64(d_y.ptr), 1)
	if status != cuda.cublas_status_success {
		return error('gemv_cuda_impl: cublasDgemv_v2 failed: ${cuda.cublas_error(status)}')
	}

	mut y := []f64{len: m}
	d_y.download[f64](mut y)!
	return y
}

// mul_scalar_cuda_impl scales a vector: y = s * x using cuBLAS dscal.
pub fn mul_scalar_cuda_impl(dev &cuda.CudaDevice, x_data []f64, s f64) ![]f64 {
	mut d_x := gpu_buf_new[f64](x_data.len)!
	defer { d_x.release() }

	d_x.upload[f64](x_data)!

	status := C.cublasDscal_v2(dev.cublas, x_data.len, &s, &f64(d_x.ptr), 1)
	if status != cuda.cublas_status_success {
		return error('mul_scalar_cuda_impl: cublasDscal_v2 failed: ${cuda.cublas_error(status)}')
	}

	mut result := []f64{len: x_data.len}
	d_x.download[f64](mut result)!
	return result
}

// gemm_cpu_colmajor is the column-major GEMM CPU fallback.
fn gemm_cpu_colmajor(a_col []f64, b_col []f64, m int, n int, k int) []f64 {
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

// gemv_cpu_colmajor is the column-major GEMV CPU fallback.
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
