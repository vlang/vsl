// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// ============================================================================
// cuBLAS types
// ============================================================================

// cublasStatus_t is the return type for cuBLAS functions.
type CublasStatus = int

// cublasOperation_t specifies whether to transpose a matrix.
type CublasOperation = int

// cublasPointerMode_t specifies whether scalars are on host or device.
type CublasPointerMode = int

pub const cublas_status_success = 0

// CublasOperation values.
pub const cublas_op_n = 0 // Non-transpose
pub const cublas_op_t = 1 // Transpose
pub const cublas_op_c = 2 // Conjugate transpose

// CublasPointerMode values.
const cublas_pointer_mode_host = 0
const cublas_pointer_mode_device = 1

// cublasHandle_t is an opaque handle to a cuBLAS context.
type CublasHandle = voidptr

// ============================================================================
// cuDNN types
// ============================================================================

// cudnnStatus_t is the return type for cuDNN functions.
type CudnnStatus = int

pub const cudnn_status_success = 0

// cudnnHandle_t is an opaque handle to a cuDNN context.
type CudnnHandle = voidptr

// cudnnActivationMode_t specifies the activation mode.
pub type CudnnActivationMode = int

// cudnnSoftmaxAlgorithm_t specifies the softmax algorithm.
pub type CudnnSoftmaxAlgorithm = int

// cudnnSoftmaxMode_t specifies the softmax mode.
pub type CudnnSoftmaxMode = int

// cudnnTensorDescriptor_t is a handle to a tensor descriptor.
pub type CudnnTensorDescriptor = voidptr

// cudnnActivationDescriptor_t is a handle to an activation descriptor.
pub type CudnnActivationDescriptor = voidptr

// cudnnConvolutionDescriptor_t is a handle to a convolution descriptor.
pub type CudnnConvolutionDescriptor = voidptr

// cudnnFilterDescriptor_t is a handle to a filter descriptor.
pub type CudnnFilterDescriptor = voidptr

// cudnnTensorFormat_t specifies the memory layout of a tensor.
pub type CudnnTensorFormat = int

// cudnnDataType_t specifies the data type of a tensor.
pub type CudnnDataType = int

// cudnnConvolutionFwdAlgo_t specifies the convolution forward algorithm.
pub type CudnnConvolutionFwdAlgo = int

// cudnnConvolutionBwdDataAlgo_t / BwdFilterAlgo_t — backward convolution algorithms.
pub type CudnnConvolutionBwdDataAlgo = int
pub type CudnnConvolutionBwdFilterAlgo = int

// CudnnActivationMode values (cuDNN 9.x deprecated legacy API).
// Matches cudnnActivationMode_t enum in cudnn_graph_v9.h:
//   CUDNN_ACTIVATION_SIGMOID=0, RELU=1, TANH=2, CLIPPED_RELU=3, ELU=4, ...
pub const cudnn_activation_relu = 1
pub const cudnn_activation_sigmoid = 0
pub const cudnn_activation_tanh = 2

// CudnnSoftmaxAlgorithm values.
pub const cudnn_softmax_fast = 0
const cudnn_softmax_accurate = 1
const cudnn_softmax_log = 2

// CudnnSoftmaxMode values.
pub const cudnn_softmax_mode_instance = 0 // apply softmax per image (NCHW)
pub const cudnn_softmax_mode_channel = 1 // apply softmax per spatial location (CHANNELS)

// CudnnTensorFormat values.
pub const cudnn_tensor_nhwc = 0 // NCHW format (row-major in VSL)
pub const cudnn_tensor_nchw = 1 // NCHW format

// CudnnDataType values.
pub const cudnn_data_type_double = 1 // f64
pub const cudnn_data_type_float = 0 // f32

// ============================================================================
// Error helper
// ============================================================================

// cublas_error returns a string description of a cuBLAS status code.
pub fn cublas_error(status CublasStatus) string {
	return match status {
		0 { 'CUBLAS_STATUS_SUCCESS' }
		1 { 'CUBLAS_STATUS_NOT_INITIALIZED' }
		3 { 'CUBLAS_STATUS_ALLOC_FAILED' }
		7 { 'CUBLAS_STATUS_INVALID_VALUE' }
		8 { 'CUBLAS_STATUS_ARCH_MISMATCH' }
		11 { 'CUBLAS_STATUS_MAPPING_ERROR' }
		13 { 'CUBLAS_STATUS_EXECUTION_FAILED' }
		14 { 'CUBLAS_STATUS_INTERNAL_ERROR' }
		else { 'CUBLAS_STATUS_UNKNOWN(${status})' }
	}
}

// cudnn_error returns a string description of a cuDNN status code.
pub fn cudnn_error(status CudnnStatus) string {
	return match status {
		0 { 'CUDNN_STATUS_SUCCESS' }
		1 { 'CUDNN_STATUS_NOT_INITIALIZED' }
		2 { 'CUDNN_STATUS_ALLOC_FAILED' }
		7 { 'CUDNN_STATUS_BAD_PARAM' }
		8 { 'CUDNN_STATUS_INTERNAL_ERROR' }
		9 { 'CUDNN_STATUS_INVALID_VALUE' }
		10 { 'CUDNN_STATUS_ARCH_MISMATCH' }
		11 { 'CUDNN_STATUS_MAPPING_ERROR' }
		13 { 'CUDNN_STATUS_EXECUTION_FAILED' }
		14 { 'CUDNN_STATUS_RUNTIME_ERROR' }
		15 { 'CUDNN_STATUS_CUDNN_UNEXPECTED_CUDNN_HEADER' }
		else { 'CUDNN_STATUS_UNKNOWN(${status})' }
	}
}
