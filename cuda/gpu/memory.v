// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module gpu

// CudaMemory is a helper for managing GPU device memory.
// It wraps cudaMalloc/cudaFree and provides upload/download methods.
pub struct CudaMemory[T] {
pub:
	ptr  voidptr
	size int
}

// cuda_memory_new allocates GPU memory for type T with count elements.
pub fn cuda_memory_new[T](count int) !CudaMemory[T] {
	mut ptr := unsafe { nil }
	size := int(sizeof(T)) * count
	status := C.cudaMalloc(&ptr, size)
	if status != 0 {
		return error('cuda_memory_new: cudaMalloc failed with status ${status}')
	}
	return CudaMemory[T]{
		ptr:  ptr
		size: size
	}
}

// upload copies data from host to device.
pub fn (mut m CudaMemory[T]) upload(data []T) ! {
	if data.len * int(sizeof(T)) > m.size {
		return error('CudaMemory.upload: data too large for allocated memory')
	}
	status := C.cudaMemcpy(m.ptr, data.data, int(sizeof(T)) * data.len,
		C.cuda_memcpy_host_to_device)
	if status != 0 {
		return error('CudaMemory.upload: cudaMemcpy host-to-device failed with status ${status}')
	}
}

// download copies data from device to host.
pub fn (mut m CudaMemory[T]) download(mut out []T) ! {
	if out.len * int(sizeof(T)) > m.size {
		return error('CudaMemory.download: output slice too large for allocated memory')
	}
	status := C.cudaMemcpy(out.data, m.ptr, int(sizeof(T)) * out.len, C.cuda_memcpy_device_to_host)
	if status != 0 {
		return error('CudaMemory.download: cudaMemcpy device-to-host failed with status ${status}')
	}
}

// free releases the GPU memory.
pub fn (m &CudaMemory[T]) free() ! {
	if m.ptr != unsafe { nil } {
		status := C.cudaFree(m.ptr)
		if status != 0 {
			return error('CudaMemory.free: cudaFree failed with status ${status}')
		}
	}
}

// destroy is an alias for free().
pub fn (m &CudaMemory[T]) destroy() ! {
	m.free()!
}
