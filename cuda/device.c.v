// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// init_cuda initializes the CUDA driver API. Must be called before any device operations.
// Thread-safe — calling multiple times is safe (returns immediately after first call).
fn init_cuda() ! {
	status := C.cuInit(0)
	if status != 0 {
		return error('cuda: cuInit failed (status ${status})')
	}
}

// CudaDevice represents a CUDA device with its cuBLAS and cuDNN handles.
// It wraps all GPU resource management for the CUDA backend.
@[heap]
pub struct CudaDevice {
pub mut:
	// device_id is the CUDA device ordinal (0, 1, ...).
	device_id int
	// name is the human-readable device name (e.g. "NVIDIA GeForce RTX 4060").
	name string
	// handle is the CUDA device handle (CUdevice for driver API).
	handle voidptr
	// ctx is the CUDA context for this device (driver API), if created.
	ctx CudaContext
	// cublas is the cuBLAS context handle.
	cublas CublasHandle
	// cudnn is the cuDNN context handle.
	cudnn CudnnHandle
	// stream is the CUDA stream used for operations.
	stream CudaStream
}

// release releases all CUDA resources (context, cuBLAS, cuDNN, stream).
pub fn (mut d CudaDevice) release() ! {
	if d.cublas != 0 {
		status := C.cublasDestroy_v2(d.cublas)
		if status != cublas_status_success {
			return error('cuda: failed to destroy cuBLAS handle: ${cublas_error(status)}')
		}
		d.cublas = 0
	}
	if d.cudnn != 0 {
		status := C.cudnnDestroy(d.cudnn)
		if status != cudnn_status_success {
			return error('cuda: failed to destroy cuDNN handle: ${cudnn_error(status)}')
		}
		d.cudnn = 0
	}
	if d.ctx != CudaContext(0) {
		C.cuCtxDestroy(d.ctx)
		d.ctx = CudaContext(0)
	}
}

// init initializes cuBLAS and cuDNN handles for this device.
pub fn (mut d CudaDevice) init() ! {
	// Set the runtime API device — this creates a runtime context on the GPU.
	// cuBLAS and cuDNN use the runtime API, so this is the only context needed.
	// We manage it purely through the runtime API (cudaSetDevice) rather than
	// mixing in the driver API context creation, which can conflict.
	cuda_set_dev_status := C.cudaSetDevice(d.device_id)
	if cuda_set_dev_status != 0 {
		return error('cuda: cudaSetDevice(${d.device_id}) failed (status ${cuda_set_dev_status})')
	}

	// Create cuBLAS handle — uses runtime's current context.
	mut cublas := CublasHandle(0)
	status := C.cublasCreate_v2(&cublas)
	if status != cublas_status_success {
		return error('cuda: failed to create cuBLAS handle: ${cublas_error(status)}')
	}
	d.cublas = cublas

	// Create cuDNN handle
	mut cudnn := CudnnHandle(0)
	cudnn_status := C.cudnnCreate(&cudnn)
	if cudnn_status != cudnn_status_success {
		C.cublasDestroy_v2(d.cublas)
		return error('cuda: failed to create cuDNN handle: ${cudnn_error(cudnn_status)}')
	}
	d.cudnn = cudnn
}

// get_device_count returns the number of available CUDA devices.
// Calls cuInit internally if not yet initialized.
pub fn get_device_count() !int {
	init_cuda()!
	mut count := 0
	status := C.cuDeviceGetCount(&count)
	if status != 0 {
		return error('cuda: cuDeviceGetCount failed (status ${status})')
	}
	if count == 0 {
		return error('cuda: no CUDA devices found')
	}
	return count
}

// get_device returns the CUDA device with the given index (0-based).
pub fn get_device(index int) !&CudaDevice {
	count := get_device_count()!
	if index < 0 || index >= count {
		return error('cuda: device index ${index} out of range (have ${count} devices)')
	}
	init_cuda()!

	// Allocate device struct and get the CUDA device handle via driver API.
	mut d := &CudaDevice{
		device_id: index
	}
	status := C.cuDeviceGet(&d.handle, index)
	if status != 0 {
		return error('cuda: cuDeviceGet failed for index ${index} (status ${status})')
	}

	// Get device name via driver API.
	mut name_buf := [256]u8{}
	C.cuDeviceGetName(&name_buf[0], 256, d.handle)
	d.name = unsafe { tos(&name_buf[0], 256) }

	// Note: we do NOT create a driver-API context here (no cuCtxCreate).
	// The runtime API (cudaSetDevice) manages its own context, and
	// cuBLAS/cuDNN work fine with just the runtime context.
	d.init()!
	return d
}

// get_default_device returns the first available CUDA device.
// Convenience wrapper; equivalent to get_device(0).
pub fn get_default_device() !&CudaDevice {
	return get_device(0)
}