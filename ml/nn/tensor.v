// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
//
// ml/nn/tensor.v — Tensor with autograd for neural networks on GPU/CPU

module nn

import math

// Grad holds gradient data and the operation that produced this tensor.
@[heap]
pub struct Grad {
pub mut:
	data    []f64       // gradient data
	grad_fn voidptr = unsafe { nil } // operation that created this tensor
}

// GradFn is the base for all autograd functions.
pub struct GradFn {
pub:
	inputs []&Tensor // tensors whose gradients this function computes
}

// GemmGrad implements backward for matrix multiplication: C = A * B
pub struct GemmGrad {
	GradFn
pub:
	a &Tensor
	b &Tensor
}

// ReluGrad implements backward for ReLU: y = max(0, x)
pub struct ReluGrad {
	GradFn
pub:
	x &Tensor
}

// SigmoidGrad implements backward for Sigmoid: y = 1/(1+exp(-x))
pub struct SigmoidGrad {
	GradFn
pub:
	x &Tensor
}

// TanhGrad implements backward for Tanh
pub struct TanhGrad {
	GradFn
pub:
	x &Tensor
}

// SoftmaxGrad implements backward for Softmax
pub struct SoftmaxGrad {
	GradFn
pub:
	x        &Tensor
	axis_len int
}

// AddScalarGrad implements backward for AddScalar
pub struct AddScalarGrad {
	GradFn
pub:
	x &Tensor
}

// MulScalarGrad implements backward for MulScalar
pub struct MulScalarGrad {
	GradFn
pub:
	x      &Tensor
	scalar f64
}

// Tensor is the core autograd building block.
@[heap]
pub struct Tensor {
pub mut:
	data          []f64       // flat data, row-major
	shape         []int       // dimensions
	requires_grad bool
	grad    &Grad = unsafe { nil }  // accumulated gradient
	grad_fn voidptr = unsafe { nil } // operation that created this tensor
}

// new_tensor creates a new tensor with given data and shape.
pub fn new_tensor(data []f64, shape []int) &Tensor {
	return &Tensor{
		data: data
		shape: shape
		requires_grad: false
	}
}

// zeros creates a zero tensor.
pub fn zeros(shape []int) &Tensor {
	mut nelem := shape[0]
	for i := 1; i < shape.len; i++ {
		nelem *= shape[i]
	}
	return &Tensor{
		data: []f64{len: nelem}
		shape: shape
		requires_grad: false
	}
}

// rand creates a tensor with random values in [0, 1).
pub fn rand(shape []int) &Tensor {
	mut nelem := shape[0]
	for i := 1; i < shape.len; i++ {
		nelem *= shape[i]
	}
	mut data := []f64{len: nelem}
	for i := 0; i < nelem; i++ {
		data[i] = f64((i * 7 + 13) % 100) / 100.0
	}
	return &Tensor{
		data: data
		shape: shape
		requires_grad: false
	}
}

// shape_str returns a human-readable shape string.
pub fn (t &Tensor) shape_str() string {
	mut s := '['
	for i, v in t.shape {
		if i > 0 {
			s += ', '
		}
		s += v.str()
	}
	s += ']'
	return s
}