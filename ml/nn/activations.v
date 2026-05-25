// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
//
// ml/nn/activations.v — GPU-accelerated activation functions

module nn

import vsl.compute

// ReLU applies element-wise y = max(0, x) using GPU when available.
pub fn relu(x &Tensor, mut ctx compute.ComputeContext) &Tensor {
	res_data := compute.relu(mut ctx, x.data) or { panic('relu failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: x.shape
		requires_grad: x.requires_grad
	}
	if x.requires_grad {
		result.grad_fn = &ReluGrad{inputs: [x], x: x}
	}
	return result
}

// sigmoid applies element-wise y = 1/(1+exp(-x)) using GPU.
pub fn sigmoid(x &Tensor, mut ctx compute.ComputeContext) &Tensor {
	res_data := compute.sigmoid(mut ctx, x.data) or { panic('sigmoid failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: x.shape
		requires_grad: x.requires_grad
	}
	if x.requires_grad {
		result.grad_fn = &SigmoidGrad{inputs: [x], x: x}
	}
	return result
}

// tanh applies element-wise y = tanh(x) using GPU.
pub fn tanh_fn(x &Tensor, mut ctx compute.ComputeContext) &Tensor {
	res_data := compute.tanh(mut ctx, x.data) or { panic('tanh failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: x.shape
		requires_grad: x.requires_grad
	}
	if x.requires_grad {
		result.grad_fn = &TanhGrad{inputs: [x], x: x}
	}
	return result
}

// softmax applies softmax over the last dimension using GPU.
pub fn softmax(x &Tensor, mut ctx compute.ComputeContext) &Tensor {
	axis_len := if x.shape.len > 1 { x.shape[x.shape.len - 1] } else { x.shape[0] }
	res_data := compute.softmax(mut ctx, x.data) or { panic('softmax failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: x.shape
		requires_grad: x.requires_grad
	}
	if x.requires_grad {
		result.grad_fn = &SoftmaxGrad{inputs: [x], x: x, axis_len: axis_len}
	}
	return result
}

// add_scalar adds a scalar to each element.
pub fn add_scalar(x &Tensor, s f64, mut ctx compute.ComputeContext) &Tensor {
	res_data := compute.add_scalar(mut ctx, x.data, s) or { panic('add_scalar failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: x.shape
		requires_grad: x.requires_grad
	}
	if x.requires_grad {
		result.grad_fn = &AddScalarGrad{inputs: [x], x: x}
	}
	return result
}

// mul_scalar multiplies each element by a scalar.
pub fn mul_scalar(x &Tensor, s f64, mut ctx compute.ComputeContext) &Tensor {
	res_data := compute.mul_scalar(mut ctx, x.data, s) or { panic('mul_scalar failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: x.shape
		requires_grad: x.requires_grad
	}
	if x.requires_grad {
		result.grad_fn = &MulScalarGrad{inputs: [x], x: x, scalar: s}
	}
	return result
}

// add performs element-wise addition of two tensors (broadcasting supported).
pub fn add(a &Tensor, b &Tensor, mut ctx compute.ComputeContext) &Tensor {
	res_data := compute.add_vec(mut ctx, a.data, b.data) or { panic('add failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: a.shape
		requires_grad: a.requires_grad || b.requires_grad
	}
	return result
}

// mul performs element-wise multiplication of two tensors.
pub fn mul(a &Tensor, b &Tensor, mut ctx compute.ComputeContext) &Tensor {
	res_data := compute.mul_vec(mut ctx, a.data, b.data) or { panic('mul failed: ${err}') }
	mut result := &Tensor{
		data: res_data
		shape: a.shape
		requires_grad: a.requires_grad || b.requires_grad
	}
	return result
}

// matmul computes matrix multiplication using GPU GEMM.
pub fn matmul(a &Tensor, b &Tensor, mut ctx compute.ComputeContext) &Tensor {
	// a: (m, k), b: (k, n) -> (m, n)
	if a.shape.len < 2 || b.shape.len < 2 {
		panic('matmul requires at least 2D tensors')
	}
	m := a.shape[a.shape.len - 2]
	k := a.shape[a.shape.len - 1]
	n := b.shape[b.shape.len - 1]
	res_data := compute.gemm(mut ctx, a.data, b.data, m, n, k) or {
		panic('matmul failed: ${err}')
	}
	// Preserve batch dimensions if present
	mut result_shape := a.shape[..a.shape.len - 2]
	result_shape << n
	mut result := &Tensor{
		data: res_data
		shape: result_shape
		requires_grad: a.requires_grad || b.requires_grad
	}
	if a.requires_grad || b.requires_grad {
		result.grad_fn = &GemmGrad{inputs: [a, b], a: a, b: b}
	}
	return result
}