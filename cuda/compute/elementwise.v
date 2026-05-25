// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import math

// relu_cuda applies ReLU: y[i] = max(0, x[i]) using cuDNN.
// Falls back to CPU when CUDA is unavailable.
pub fn relu_cuda(dev voidptr, x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNReluDescriptor and cuDNNAddTensor when CUDA is available
	// For now, use CPU fallback
	return relu_cpu_f64(x_data)
}

// sigmoid_cuda applies Sigmoid: y[i] = 1/(1+exp(-x[i])) using cuDNN.
pub fn sigmoid_cuda(dev voidptr, x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNSigmoid when CUDA is available
	return sigmoid_cpu_f64(x_data)
}

// tanh_cuda applies Tanh: y[i] = tanh(x[i]) using cuDNN.
pub fn tanh_cuda(dev voidptr, x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNTanh when CUDA is available
	return tanh_cpu_f64(x_data)
}

// add_vec_cuda computes y[i] = a[i] + b[i] element-wise using cuBLAS DAXPY or custom kernel.
pub fn add_vec_cuda(dev voidptr, a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('add_vec_cuda: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	// TODO(#238): use cuBLAS DAXPY when CUDA is available
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] + b_data[i]
	}
	return out
}

// mul_vec_cuda computes y[i] = a[i] * b[i] element-wise using custom CUDA kernel.
pub fn mul_vec_cuda(dev voidptr, a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('mul_vec_cuda: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	// TODO(#238): custom CUDA kernel for element-wise multiply
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] * b_data[i]
	}
	return out
}

// add_scalar_cuda computes y[i] = x[i] + scalar using custom kernel or cuBLAS.
pub fn add_scalar_cuda(dev voidptr, x_data []f64, s f64) ![]f64 {
	// TODO(#238): custom CUDA kernel for add_scalar when CUDA is available
	mut out := []f64{len: x_data.len}
	for i in 0 .. x_data.len {
		out[i] = x_data[i] + s
	}
	return out
}

// mul_scalar_cuda computes y[i] = x[i] * scalar using cuBLAS DSCAL.
pub fn mul_scalar_cuda(dev voidptr, x_data []f64, s f64) ![]f64 {
	// TODO(#238): use cuBLAS DSCAL when CUDA is available
	mut out := []f64{len: x_data.len}
	for i in 0 .. x_data.len {
		out[i] = x_data[i] * s
	}
	return out
}

// softmax_cuda applies row-wise numerically stable softmax via cuDNN.
pub fn softmax_cuda(dev voidptr, x_data []f64) ![]f64 {
	// TODO(#238): use cuDNNSoftmaxForward when CUDA is available
	return softmax_cpu_f64(x_data)
}

// layernorm_cuda applies row-wise layer normalization via cuDNN.
// Applies gamma/beta on CPU (cuDNN layernorm does not include affine by default).
pub fn layernorm_cuda(dev voidptr, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	// TODO(#238): use cuDNNLayerNorm when CUDA is available
	return layernorm_cpu_f64(x_data, gamma, beta)
}

// conv2d_cuda computes 2D convolution via cuDNN.
// Input: [batch x in_h x in_w x in_ch] row-major flat
// Kernel: [out_ch x k_h x k_w x in_ch] row-major flat
// Output: [batch x out_h x out_w x out_ch]
pub fn conv2d_cuda(dev voidptr, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	// TODO(#238): use cuDNNConvolutionForward when CUDA is available
	return error('conv2d_cuda: not implemented yet — see issue #238')
}

// CPU fallbacks (same as compute/backend_cpu.v)
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