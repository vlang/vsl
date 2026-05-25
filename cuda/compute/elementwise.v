// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// elementwise.v — GPU-accelerated element-wise activation functions via cuDNN.
//
// All functions operate on flat f64 arrays and return flat f64 arrays.
// Where cuDNN provides a native kernel the GPU path is used; otherwise CPU fallback.

import math
import vsl.cuda

// activation_forward_cuda is a private helper that runs a cuDNN activation forward pass.
// mode: cuda.cudnn_activation_relu / sigmoid / tanh
// Tensor is expressed as [1, 1, 1, n] NCHW f64 — valid for 1-D element-wise ops.
fn activation_forward_cuda(dev &cuda.CudaDevice, mode cuda.CudnnActivationMode, x_data []f64) ![]f64 {
	n := x_data.len

	// Create and configure activation descriptor
	mut act_desc := cuda.CudnnActivationDescriptor(unsafe { nil })
	s0 := C.cudnnCreateActivationDescriptor(&act_desc)
	if s0 != cuda.cudnn_status_success {
		return error('activation_forward_cuda: cudnnCreateActivationDescriptor: ${cuda.cudnn_error(s0)}')
	}
	// cudnnSetActivationDescriptor(desc, mode, nanOpt=0 (propagate_nan), coef=0.0)
	s1 := C.cudnnSetActivationDescriptor(act_desc, mode, 0, 0.0)
	if s1 != cuda.cudnn_status_success {
		C.cudnnDestroyActivationDescriptor(act_desc)
		return error('activation_forward_cuda: cudnnSetActivationDescriptor: ${cuda.cudnn_error(s1)}')
	}
	defer { C.cudnnDestroyActivationDescriptor(act_desc) }

	// Create tensor descriptor: NCHW [1, 1, 1, n], double
	mut tensor_desc := cuda.CudnnTensorDescriptor(unsafe { nil })
	s2 := C.cudnnCreateTensorDescriptor(&tensor_desc)
	if s2 != cuda.cudnn_status_success {
		return error('activation_forward_cuda: cudnnCreateTensorDescriptor: ${cuda.cudnn_error(s2)}')
	}
	// cudnnSetTensor4dDescriptor(desc, format=NCHW, dataType=DOUBLE, n=1, c=1, h=1, w=n)
	s3 := C.cudnnSetTensor4dDescriptor(tensor_desc, cuda.cudnn_tensor_nchw, cuda.cudnn_data_type_double,
		1, 1, 1, n)
	if s3 != cuda.cudnn_status_success {
		C.cudnnDestroyTensorDescriptor(tensor_desc)
		return error('activation_forward_cuda: cudnnSetTensor4dDescriptor: ${cuda.cudnn_error(s3)}')
	}
	defer { C.cudnnDestroyTensorDescriptor(tensor_desc) }

	mut d_x := gpu_buf_new[f64](n)!
	defer { d_x.release() }
	mut d_y := gpu_buf_new[f64](n)!
	defer { d_y.release() }

	d_x.upload[f64](x_data)!

	alpha := f64(1.0)
	beta := f64(0.0)
	s4 := C.cudnnActivationForward(dev.cudnn, act_desc, &alpha, tensor_desc, &f64(d_x.ptr),
		&beta, tensor_desc, &f64(d_y.ptr))
	if s4 != cuda.cudnn_status_success {
		return error('activation_forward_cuda: cudnnActivationForward: ${cuda.cudnn_error(s4)}')
	}

	mut out := []f64{len: n}
	d_y.download[f64](mut out)!
	return out
}

// relu_cuda applies ReLU: y[i] = max(0, x[i]) using cuDNN activation.
pub fn relu_cuda(dev &cuda.CudaDevice, x_data []f64) ![]f64 {
	if isnil(dev.cudnn) {
		return relu_cpu_f64(x_data)
	}
	return activation_forward_cuda(dev, cuda.CudnnActivationMode(cuda.cudnn_activation_relu),
		x_data)
}

// sigmoid_cuda applies Sigmoid: y[i] = 1/(1+exp(-x[i])) using cuDNN activation.
pub fn sigmoid_cuda(dev &cuda.CudaDevice, x_data []f64) ![]f64 {
	if isnil(dev.cudnn) {
		return sigmoid_cpu_f64(x_data)
	}
	return activation_forward_cuda(dev, cuda.CudnnActivationMode(cuda.cudnn_activation_sigmoid),
		x_data)
}

// tanh_cuda applies Tanh: y[i] = tanh(x[i]) using cuDNN activation.
pub fn tanh_cuda(dev &cuda.CudaDevice, x_data []f64) ![]f64 {
	if isnil(dev.cudnn) {
		return tanh_cpu_f64(x_data)
	}
	return activation_forward_cuda(dev, cuda.CudnnActivationMode(cuda.cudnn_activation_tanh),
		x_data)
}

// add_vec_cuda computes y[i] = a[i] + b[i] element-wise.
// cuBLAS DAXPY: y = alpha*x + y — used with alpha=1.0 to add two vectors.
pub fn add_vec_cuda(dev &cuda.CudaDevice, a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('add_vec_cuda: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	if isnil(dev.cublas) {
		return add_vec_cpu_f64(a_data, b_data)
	}
	n := a_data.len
	mut d_a := gpu_buf_new[f64](n)!
	defer { d_a.release() }
	mut d_b := gpu_buf_new[f64](n)!
	defer { d_b.release() }

	d_a.upload[f64](a_data)!
	d_b.upload[f64](b_data)!

	// DAXPY: d_b = 1.0 * d_a + d_b  →  d_b[i] = a[i] + b[i]
	alpha := f64(1.0)
	status := C.cublasDaxpy_v2(dev.cublas, n, &alpha, &f64(d_a.ptr), 1, &f64(d_b.ptr), 1)
	if status != cuda.cublas_status_success {
		return error('add_vec_cuda: cublasDaxpy_v2 failed: ${cuda.cublas_error(status)}')
	}

	mut out := []f64{len: n}
	d_b.download[f64](mut out)!
	return out
}

// mul_vec_cuda computes y[i] = a[i] * b[i] element-wise (CPU fallback; no native cuBLAS op).
// TODO(#238): implement via custom CUDA kernel.
pub fn mul_vec_cuda(dev &cuda.CudaDevice, a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('mul_vec_cuda: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	return mul_vec_cpu_f64(a_data, b_data)
}

// add_scalar_cuda computes y[i] = x[i] + s (CPU fallback; no direct cuBLAS op).
// TODO(#238): implement via custom CUDA kernel.
pub fn add_scalar_cuda(dev &cuda.CudaDevice, x_data []f64, s f64) ![]f64 {
	return add_scalar_cpu_f64(x_data, s)
}

// mul_scalar_cuda computes y = s * x using cuBLAS dscal.
pub fn mul_scalar_cuda(dev &cuda.CudaDevice, x_data []f64, s f64) ![]f64 {
	if isnil(dev.cublas) {
		return mul_scalar_cpu_f64(x_data, s)
	}
	return mul_scalar_cuda_impl(dev, x_data, s)
}

// softmax_cuda applies row-wise softmax (CPU fallback; full GPU softmax requires custom kernel).
// TODO(#238): replace with cuDNN softmax forward.
pub fn softmax_cuda(dev &cuda.CudaDevice, x_data []f64) ![]f64 {
	return softmax_cpu_f64(x_data)
}

// layernorm_cuda applies layer normalisation (CPU fallback).
// TODO(#238): replace with cuDNN layer norm.
pub fn layernorm_cuda(dev &cuda.CudaDevice, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	return layernorm_cpu_f64(x_data, gamma, beta)
}

// conv2d_cuda applies 2-D convolution (CPU fallback).
// TODO(#238): replace with cuDNN convolution forward.
pub fn conv2d_cuda(dev &cuda.CudaDevice, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	return conv2d_cpu_f64(input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h, k_w,
		stride_h, stride_w)
}

// ─── CPU fallback helpers ────────────────────────────────────────────────────

fn relu_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = if v > 0.0 { v } else { 0.0 }
	}
	return out
}

fn sigmoid_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = 1.0 / (1.0 + math.exp(-v))
	}
	return out
}

fn tanh_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = math.tanh(v)
	}
	return out
}

fn add_vec_cpu_f64(a_data []f64, b_data []f64) []f64 {
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] + b_data[i]
	}
	return out
}

fn mul_vec_cpu_f64(a_data []f64, b_data []f64) []f64 {
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] * b_data[i]
	}
	return out
}

fn add_scalar_cpu_f64(x_data []f64, s f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i in 0 .. x_data.len {
		out[i] = x_data[i] + s
	}
	return out
}

fn mul_scalar_cpu_f64(x_data []f64, s f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i in 0 .. x_data.len {
		out[i] = x_data[i] * s
	}
	return out
}

fn softmax_cpu_f64(x []f64) ![]f64 {
	cols := x.len
	mut out := []f64{len: cols}
	mut mx := x[0]
	for i in 1 .. cols {
		if x[i] > mx {
			mx = x[i]
		}
	}
	mut sum := 0.0
	for i in 0 .. cols {
		out[i] = math.exp(x[i] - mx)
		sum += out[i]
	}
	for i in 0 .. cols {
		out[i] /= sum
	}
	return out
}

fn layernorm_cpu_f64(x []f64, gamma []f64, beta []f64) ![]f64 {
	cols := x.len
	mut out := []f64{len: cols}
	mut mean := 0.0
	for i in 0 .. cols {
		mean += x[i]
	}
	mean /= f64(cols)
	mut variance := 0.0
	for i in 0 .. cols {
		d := x[i] - mean
		variance += d * d
	}
	variance /= f64(cols)
	inv_std := 1.0 / math.sqrt(variance + 1e-5)
	for i in 0 .. cols {
		out[i] = (x[i] - mean) * inv_std * gamma[i] + beta[i]
	}
	return out
}

fn conv2d_cpu_f64(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	out_h := (in_h - k_h) / stride_h + 1
	out_w := (in_w - k_w) / stride_w + 1
	out_size := batch * out_ch * out_h * out_w
	mut out := []f64{len: out_size}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for oh in 0 .. out_h {
				for ow in 0 .. out_w {
					mut sum := 0.0
					for ic in 0 .. in_ch {
						for krow in 0 .. k_h {
							for kcol in 0 .. k_w {
								ih := oh * stride_h + krow
								iw := ow * stride_w + kcol
								in_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
								k_idx := ((oc * in_ch + ic) * k_h + krow) * k_w + kcol
								sum += input[in_idx] * kernel[k_idx]
							}
						}
					}
					out_idx := ((b * out_ch + oc) * out_h + oh) * out_w + ow
					out[out_idx] = sum
				}
			}
		}
	}
	return out
}
