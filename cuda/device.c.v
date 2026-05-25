// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// CudaDevice represents a CUDA device with its cuBLAS and cuDNN handles.
// It wraps all GPU resource management for the CUDA backend.
@[heap]
pub struct CudaDevice {
pub mut:
	// handle is the CUDA device pointer (CUdeviceptr or similar).
	handle voidptr
	// cublas is the cuBLAS context handle.
	cublas CublasHandle
	// cudnn is the cuDNN context handle.
	cudnn CudnnHandle
	// stream is the CUDA stream used for operations.
	stream CudaStream
}

// release releases all CUDA resources (cuBLAS, cuDNN, stream).
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
}

// init initializes cuBLAS and cuDNN handles for this device.
// Call this after creating or acquiring a CUDA device.
pub fn (mut d CudaDevice) init() ! {
	// Create cuBLAS handle
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

// name returns the device name.
pub fn (d &CudaDevice) name() string {
	return 'NVIDIA CUDA Device'
}

// get_default_device returns the first available CUDA device.
// Currently uses CPU fallback while real device enumeration is implemented.
pub fn get_default_device() !&CudaDevice {
	// TODO(#238): enumerate CUDA devices with cuInit + cuDeviceGet
	// For now, create a placeholder device with nil handle.
	// Real implementation will use cuInit(0), cuDeviceGet, cuCtxCreate.
	mut d := &CudaDevice{
		handle: voidptr(0)
	}
	d.init()!
	return d
}

// get_device_count returns the number of available CUDA devices.
pub fn get_device_count() !int {
	// TODO(#238): use cuDeviceGetCount
	return 1
}

// get_device returns the CUDA device with the given index.
pub fn get_device(index int) !&CudaDevice {
	if index < 0 || index >= get_device_count()! {
		return error('cuda: device index ${index} out of range')
	}
	mut d := &CudaDevice{
		handle: voidptr(index)
	}
	d.init()!
	return d
}