// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// optimizer_gpu — in-place cuBLAS ops on persistent GpuBuf (Adam / Phase 4 #106).
import math
import vsl.cuda

// GpuBufF64 is a reusable f64 device buffer (element count tracked separately).
pub struct GpuBufF64 {
mut:
	ptr   voidptr
	bytes int
}

pub fn gpu_buf_f64_new(count int) !GpuBufF64 {
	mut ptr := unsafe { nil }
	sz := int(sizeof(f64)) * count
	status := C.cudaMalloc(&ptr, sz)
	if status != 0 {
		return error('gpu_buf_f64_new: cudaMalloc status ${status}')
	}
	return GpuBufF64{
		ptr:   ptr
		bytes: sz
	}
}

pub fn (mut b GpuBufF64) ensure(count int) ! {
	sz := int(sizeof(f64)) * count
	if !isnil(b.ptr) && b.bytes >= sz {
		return
	}
	b.release()
	mut ptr := unsafe { nil }
	status := C.cudaMalloc(&ptr, sz)
	if status != 0 {
		return error('gpu_buf_f64_ensure: cudaMalloc status ${status}')
	}
	b.ptr = ptr
	b.bytes = sz
}

pub fn (mut b GpuBufF64) upload(data []f64) ! {
	status := C.cudaMemcpy(b.ptr, data.data, int(sizeof(f64)) * data.len,
		C.cuda_memcpy_host_to_device)
	if status != 0 {
		return error('gpu_buf_f64.upload: cudaMemcpy H→D ${status}')
	}
}

pub fn (b &GpuBufF64) download(mut out []f64) ! {
	status := C.cudaMemcpy(out.data, b.ptr, int(sizeof(f64)) * out.len,
		C.cuda_memcpy_device_to_host)
	if status != 0 {
		return error('gpu_buf_f64.download: cudaMemcpy D→H ${status}')
	}
}

pub fn (b &GpuBufF64) release() {
	if !isnil(b.ptr) {
		C.cudaFree(b.ptr)
	}
}

pub fn gpu_buf_f64_dscal(dev &cuda.CudaDevice, mut b GpuBufF64, count int, alpha f64) ! {
	if isnil(dev.cublas) {
		return error('gpu_buf_f64_dscal: cublas unavailable')
	}
	status := C.cublasDscal_v2(dev.cublas, count, &alpha, &f64(b.ptr), 1)
	if status != cuda.cublas_status_success {
		return error('gpu_buf_f64_dscal: ${cuda.cublas_error(status)}')
	}
}

pub fn gpu_buf_f64_axpy(dev &cuda.CudaDevice, alpha f64, x &GpuBufF64, mut y GpuBufF64, count int) ! {
	if isnil(dev.cublas) {
		return error('gpu_buf_f64_axpy: cublas unavailable')
	}
	status := C.cublasDaxpy_v2(dev.cublas, count, &alpha, &f64(x.ptr), 1, &f64(y.ptr), 1)
	if status != cuda.cublas_status_success {
		return error('gpu_buf_f64_axpy: ${cuda.cublas_error(status)}')
	}
}

pub fn gpu_buf_f64_mul_vec(dev &cuda.CudaDevice, a &GpuBufF64, b &GpuBufF64, mut out GpuBufF64,
	count int) ! {
	if isnil(dev.cublas) {
		return error('gpu_buf_f64_mul_vec: cublas unavailable')
	}
	status :=
		C.cublasDdgmm(dev.cublas, 1, 1, count, &f64(a.ptr), 1, &f64(b.ptr), 1, &f64(out.ptr), 1)
	if status != cuda.cublas_status_success {
		return error('gpu_buf_f64_mul_vec: ${cuda.cublas_error(status)}')
	}
}

// gpu_buf_f64_sqrt_inplace: element-wise sqrt on device (single H↔D round-trip until GPU kernel).
pub fn gpu_buf_f64_sqrt_inplace(mut b GpuBufF64, count int) ! {
	mut host := []f64{len: count}
	b.download(mut host)!
	for i in 0 .. count {
		host[i] = math.sqrt(host[i])
	}
	b.upload(host)!
}

// gpu_buf_f64_add_scalar_inplace adds s to each element (host round-trip).
pub fn gpu_buf_f64_copy(mut dst GpuBufF64, src &GpuBufF64, count int) ! {
	sz := int(sizeof(f64)) * count
	status := C.cudaMemcpy(dst.ptr, src.ptr, sz, cuda.cuda_memcpy_device_to_device)
	if status != 0 {
		return error('gpu_buf_f64_copy: cudaMemcpy D→D ${status}')
	}
}

pub fn gpu_buf_f64_add_scalar_inplace(mut b GpuBufF64, count int, s f64) ! {
	mut host := []f64{len: count}
	b.download(mut host)!
	for i in 0 .. count {
		host[i] += s
	}
	b.upload(host)!
}
