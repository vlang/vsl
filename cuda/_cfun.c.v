// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// ============================================================================
// cuBLAS function declarations (v2 API — CUDA 10.1+)
// ============================================================================

// cublasCreate creates a cuBLAS handle.
fn C.cublasCreate_v2(handle &CublasHandle) CublasStatus

// cublasDestroy destroys a cuBLAS handle.
fn C.cublasDestroy_v2(handle CublasHandle) CublasStatus

// cublasSetStream sets the CUDA stream for cuBLAS operations.
fn C.cublasSetStream_v2(handle CublasHandle, streamId CudaStream) CublasStatus

// cublasGetStream gets the CUDA stream associated with a cuBLAS handle.
fn C.cublasGetStream_v2(handle CublasHandle, streamId &CudaStream) CublasStatus

// cublasSetPointerMode sets whether scalars are on host or device.
fn C.cublasSetPointerMode_v2(handle CublasHandle, mode CublasPointerMode) CublasStatus

// cublasGetPointerMode gets the current pointer mode.
fn C.cublasGetPointerMode_v2(handle CublasHandle, mode &CublasPointerMode) CublasStatus

// cublasDgemm performs double-precision matrix-matrix multiply.
// C = alpha * op(A) * op(B) + beta * C
// All matrices are column-major (cuBLAS convention).
// A is [m x k] if transa=N, [k x m] if transa=T
// B is [k x n] if transb=N, [n x k] if transb=T
// C is [m x n]
fn C.cublasDgemm_v2(handle CublasHandle, transa CublasOperation, transb CublasOperation, m int, n int, k int, alpha &f64, A &f64, lda int, B &f64, ldb int, beta &f64, C &f64, ldc int) CublasStatus

// cublasDgemv performs double-precision matrix-vector multiply.
// y = alpha * op(A) * x + beta * y
fn C.cublasDgemv_v2(handle CublasHandle, trans CublasOperation, m int, n int, alpha &f64, A &f64, lda int, x &f64, incx int, beta &f64, y &f64, incy int) CublasStatus

// cublasDscal scales a vector by a scalar: x = alpha * x
fn C.cublasDscal_v2(handle CublasHandle, n int, alpha &f64, x &f64, incx int) CublasStatus

// cublasDaxpy adds scaled vector to another: y = alpha * x + y
fn C.cublasDaxpy_v2(handle CublasHandle, n int, alpha &f64, x &f64, incx int, y &f64, incy int) CublasStatus

// cublasDdgmm: C = diag(A) * B (no alpha/beta; legacy API on some distros).
fn C.cublasDdgmm(handle CublasHandle, side int, m int, n int, A &f64, lda int, B &f64, ldb int, C &f64, ldc int) CublasStatus

// ============================================================================
// CUDA Runtime functions (memory management)
// ============================================================================

// Define CUDA memcpy kind constants — needed because the CUDA headers
// are not available at preprocessor check time when using TCC.
#flag linux -Dcuda_memcpy_host_to_device=2 -Dcuda_memcpy_device_to_host=3
#flag linux -I/opt/cuda/include
#flag linux -Wl,-rpath,/opt/cuda/lib64
#flag darwin -Dcuda_memcpy_host_to_device=2 -Dcuda_memcpy_device_to_host=3
#flag darwin -I/usr/local/cuda/include

// cudaMalloc allocates memory on the device.
fn C.cudaMalloc(ptr &voidptr, size int) int

// cudaFree frees device memory.
fn C.cudaFree(ptr voidptr) int

// cudaMemcpy copies memory between host and device.
// kind: 1=host-to-host, 2=host-to-device, 3=device-to-host, 4=device-to-device
fn C.cudaMemcpy(dst voidptr, src voidptr, size int, kind int) int

const cuda_memcpy_host_to_device = 2
const cuda_memcpy_device_to_host = 3

// ============================================================================
// CUDA Runtime device management
// ============================================================================

// cuInit initializes the CUDA driver API.
fn C.cuInit(flags int) int

// cuDeviceGetCount returns the number of CUDA-capable devices.
fn C.cuDeviceGetCount(count &int) int

// cuDeviceGet returns the device handle for the given index.
fn C.cuDeviceGet(device &CudaDevice, ordinal int) int

// cuDeviceGetName returns the device name as a null-terminated string.
fn C.cuDeviceGetName(name &char, len int, device CudaDevice) int

// cuDeviceGetAttribute returns attribute information about the device.
fn C.cuDeviceGetAttribute(pi &int, attrib int, device CudaDevice) int

// cuCtxCreate creates a CUDA context for the device.
fn C.cuCtxCreate(ctx &CudaContext, flags int, device CudaDevice) int

// cuCtxDestroy destroys a CUDA context.
fn C.cuCtxDestroy(ctx CudaContext) int

// cuCtxSetCurrent sets the current context for the calling thread.
fn C.cuCtxSetCurrent(ctx CudaContext) int

// cudaSetDevice sets the active CUDA device for the runtime API.
fn C.cudaSetDevice(device int) int

// ============================================================================
// cuDNN function declarations (v9 API)
// ============================================================================

// cudnnCreate creates a cuDNN handle.
fn C.cudnnCreate(handle &CudnnHandle) CudnnStatus

// cudnnDestroy destroys a cuDNN handle.
fn C.cudnnDestroy(handle CudnnHandle) CudnnStatus

// cudnnSetStream sets the CUDA stream for cuDNN operations.
fn C.cudnnSetStream(handle CudnnHandle, streamId CudaStream) CudnnStatus

// cudnnGetStream gets the CUDA stream associated with a cuDNN handle.
fn C.cudnnGetStream(handle CudnnHandle, streamId &CudaStream) CudnnStatus

// cudnnCreateTensorDescriptor creates a tensor descriptor.
fn C.cudnnCreateTensorDescriptor(tensorDesc &&CudnnTensorDescriptor) CudnnStatus

// cudnnDestroyTensorDescriptor destroys a tensor descriptor.
fn C.cudnnDestroyTensorDescriptor(tensorDesc CudnnTensorDescriptor) CudnnStatus

// cudnnSetTensor4dDescriptor sets a 4D tensor descriptor.
// layout must be CUDNN_TENSOR_NCHW (row-major in VSL).
// dataType must be CUDNN_DATA_TYPE_DOUBLE for f64.
fn C.cudnnSetTensor4dDescriptor(tensorDesc CudnnTensorDescriptor, layout CudnnTensorFormat, dataType CudnnDataType, n int, c int, h int, w int) CudnnStatus

// cudnnSetTensor4dDescriptorEx sets a 4D tensor descriptor with strides.
fn C.cudnnSetTensor4dDescriptorEx(tensorDesc CudnnTensorDescriptor, dataType CudnnDataType, n int, c int, h int, w int, nStride int, cStride int, hStride int, wStride int) CudnnStatus

// cudnnGetTensor4dDescriptor gets the parameters of a 4D tensor descriptor.
fn C.cudnnGetTensor4dDescriptor(tensorDesc CudnnTensorDescriptor, dataType &CudnnDataType, n &int, c &int, h &int, w int, nStride &int, cStride &int, hStride &int, wStride &int) CudnnStatus

// cudnnCreateActivationDescriptor creates an activation descriptor.
fn C.cudnnCreateActivationDescriptor(activationDesc &&CudnnActivationDescriptor) CudnnStatus

// cudnnDestroyActivationDescriptor destroys an activation descriptor.
fn C.cudnnDestroyActivationDescriptor(activationDesc CudnnActivationDescriptor) CudnnStatus

// cudnnSetActivationDescriptor sets an activation descriptor.
fn C.cudnnSetActivationDescriptor(activationDesc CudnnActivationDescriptor, mode CudnnActivationMode, reluInfOrNanMode int, reluLowerClip f64) CudnnStatus

// cudnnActivationForward performs a forward activation.
// y = activation(x)
fn C.cudnnActivationForward(handle CudnnHandle, activationDesc CudnnActivationDescriptor, alpha &f64, xDesc CudnnTensorDescriptor, x &f64, beta &f64, yDesc CudnnTensorDescriptor, y &f64) CudnnStatus

// cudnnSoftmaxForward performs softmax forward.
// y = softmax(x)
fn C.cudnnSoftmaxForward(handle CudnnHandle, algo CudnnSoftmaxAlgorithm, mode CudnnSoftmaxMode, alpha &f64, xDesc CudnnTensorDescriptor, x &f64, beta &f64, yDesc CudnnTensorDescriptor, y &f64) CudnnStatus

// cudnnCreateFilterDescriptor creates a filter descriptor.
fn C.cudnnCreateFilterDescriptor(filterDesc &&CudnnFilterDescriptor) CudnnStatus

// cudnnDestroyFilterDescriptor destroys a filter descriptor.
fn C.cudnnDestroyFilterDescriptor(filterDesc CudnnFilterDescriptor) CudnnStatus

// cudnnSetFilter4dDescriptor sets a 4D filter descriptor.
// format must be CUDNN_TENSOR_NCHW.
fn C.cudnnSetFilter4dDescriptor(filterDesc CudnnFilterDescriptor, dataType CudnnDataType, layout CudnnTensorFormat, k int, c int, h int, w int) CudnnStatus

// cudnnCreateConvolutionDescriptor creates a convolution descriptor.
fn C.cudnnCreateConvolutionDescriptor(convDesc &&CudnnConvolutionDescriptor) CudnnStatus

// cudnnDestroyConvolutionDescriptor destroys a convolution descriptor.
fn C.cudnnDestroyConvolutionDescriptor(convDesc CudnnConvolutionDescriptor) CudnnStatus

// cudnnSetConvolution2dDescriptor sets a 2D convolution descriptor.
fn C.cudnnSetConvolution2dDescriptor(convDesc CudnnConvolutionDescriptor, padH int, padW int, vertStride int, horizStride int, dilationH int, dilationW int, mode int) CudnnStatus

// cudnnGetConvolution2dDescriptor gets the parameters of a 2D convolution descriptor.
fn C.cudnnGetConvolution2dDescriptor(convDesc CudnnConvolutionDescriptor, padH &int, padW &int, vertStride &int, horizStride &int, dilationH &int, dilationW &int, mode &int) CudnnStatus

// cudnnGetConvolution2dForwardOutputDim gets the output dimensions of a convolution.
fn C.cudnnGetConvolution2dForwardOutputDim(convDesc CudnnConvolutionDescriptor, inputTensorDesc CudnnTensorDescriptor, filterDesc CudnnFilterDescriptor, n &int, c &int, h &int, w &int) CudnnStatus

// cudnnFindConvolutionForwardAlgorithm finds the best convolution algorithm.
fn C.cudnnFindConvolutionForwardAlgorithm(handle CudnnHandle, xDesc CudnnTensorDescriptor, wDesc CudnnFilterDescriptor, convDesc CudnnConvolutionDescriptor, yDesc CudnnTensorDescriptor, requestedAlgoCount int, returnedAlgoCount &int, perfResults &CudnnConvolutionFwdAlgoPerf) CudnnStatus

// cudnnGetConvolutionForwardAlgorithm_v7 gets the available convolution algorithms.
fn C.cudnnGetConvolutionForwardAlgorithm_v7(handle CudnnHandle, xDesc CudnnTensorDescriptor, wDesc CudnnFilterDescriptor, convDesc CudnnConvolutionDescriptor, yDesc CudnnTensorDescriptor, requestedAlgoCount int, returnedAlgoCount &int, algo &CudnnConvolutionFwdAlgo) CudnnStatus

// cudnnGetConvolutionForwardWorkspaceSize returns workspace bytes for forward conv.
fn C.cudnnGetConvolutionForwardWorkspaceSize(handle CudnnHandle, xDesc CudnnTensorDescriptor, wDesc CudnnFilterDescriptor, convDesc CudnnConvolutionDescriptor, yDesc CudnnTensorDescriptor, algo CudnnConvolutionFwdAlgo, sizeInBytes &usize) CudnnStatus

// cudnnConvolutionForward performs a forward convolution.
// y = alpha * conv(x, filter) + beta * y
fn C.cudnnConvolutionForward(handle CudnnHandle, alpha &f64, xDesc CudnnTensorDescriptor, x &f64, wDesc CudnnFilterDescriptor, w &f64, convDesc CudnnConvolutionDescriptor, algo CudnnConvolutionFwdAlgo, workSpace voidptr, workSpaceSizeInBytes int, beta &f64, yDesc CudnnTensorDescriptor, y &f64) CudnnStatus

// cudnnCreateTensorDescriptorFromDescriptor is a helper to get descriptor from plan.
fn C.cudnnCreateTensorDescriptorFromDescriptor(descriptor CudnnTensorDescriptor, data []f64) CudnnStatus

// ============================================================================
// cuDNN Layer Normalization (cuDNN 9.x)
// ============================================================================

// cudnnLayerNormForward performs layer normalization forward.
// y = gamma * (x - mean) / sqrt(variance + epsilon) + beta
fn C.cudnnLayerNormForward(handle CudnnHandle, normDesc CudnnTensorDescriptor, normAlpha &f64, normBeta &f64, xDesc CudnnTensorDescriptor, x &f64, epsilon f64, gamma &f64, beta &f64, yDesc CudnnTensorDescriptor, y &f64, mean &f64, invVariance &f64) CudnnStatus

// ============================================================================
// CUDA Runtime types (needed for stream management)
// ============================================================================

// CudaStream is an opaque CUDA stream handle.
type CudaStream = voidptr

// CudnnConvolutionFwdAlgoPerf holds performance results for convolution algorithms.
type CudnnConvolutionFwdAlgoPerf = voidptr

// CudaContext is an opaque CUDA context (driver API handle).
type CudaContext = voidptr

// char is used for C strings in driver API.
type CChar = u8
