// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
//
// ml/nn/dense.v — Dense (linear) layer: y = x @ W^T + b
//
// y_i = sum_j x_j * W[j][i] + b_i
// Shape: (batch, in_features) @ (out_features, in_features) -> (batch, out_features)

module nn

import vsl.compute
import math

// Dense is a fully-connected layer: y = x @ W^T + b
pub struct Dense {
pub:
	in_features  int
	out_features int
pub mut:
	w   &Tensor = unsafe { nil } // weight matrix (out_features, in_features)
	b   &Tensor = unsafe { nil } // bias vector (out_features,)
	ctx compute.ComputeContext
}

// Dense.new creates a new dense layer.
// Initializes weight with Xavier/He uniform initialization and bias with zeros.
pub fn Dense.new(in_features int, out_features int, mut ctx compute.ComputeContext) &Dense {
	// Xavier uniform init for weights: bound = sqrt(6 / (fan_in + fan_out))
	scale := math.sqrt(6.0 / f64(in_features + out_features))
	mut w_data := []f64{len: out_features * in_features}
	// Use deterministic but non-zero init pattern
	mut seed := 12345
	for i := 0; i < w_data.len; i++ {
		// Simple LCG for reproducible initialization
		seed = seed * 1103515245 + 12345
		w_data[i] = (f64(seed % 0x7fffffff) / f64(0x7fffffff) * 2.0 - 1.0) * scale
	}
	b_data := []f64{len: out_features}

	mut t_w := &Tensor{
		data: w_data
		shape: [out_features, in_features]
		requires_grad: true
	}
	mut t_b := &Tensor{
		data: b_data
		shape: [out_features]
		requires_grad: true
	}

	return &Dense{
		in_features:  in_features
		out_features: out_features
		w: t_w
		b: t_b
		ctx: ctx
	}
}

// forward computes y = x @ W^T + b using GPU GEMM.
// Input: x with shape (batch, in_features)
// Output: y with shape (batch, out_features)
pub fn (d &Dense) forward(x &Tensor, mut ctx compute.ComputeContext) &Tensor {
	batch := x.shape[0]

	// y = x @ W^T, but compute.gemm does C = A @ B row-major
	// y[i][j] = sum_k x[i][k] * W^T[k][j] = sum_k x[i][k] * W[j][k]
	// So B must be W^T flat. Build W^T flat from W (out_features, in_features) row-major.
	// W^T[i][j] = W[j][i], so W^T flat: W^T[row*in_features + col] = W[col*out_features + row]
	mut w_t_flat := []f64{len: d.out_features * d.in_features}
	for j := 0; j < d.out_features; j++ {
		for i := 0; i < d.in_features; i++ {
			w_t_flat[j * d.in_features + i] = d.w.data[i * d.out_features + j]
		}
	}

	// GEMM: C = A @ B with A=x (batch, in_features), B=W^T (in_features, out_features)
	// => C (batch, out_features)
	y_data := compute.gemm(mut ctx, x.data, w_t_flat, batch, d.out_features, d.in_features) or {
		panic('Dense.forward gemm failed: ${err}')
	}

	// Add bias: y = y + b (broadcast along batch)
	mut y_mut := y_data.clone()
	for b_idx := 0; b_idx < batch; b_idx++ {
		for i := 0; i < d.out_features; i++ {
			y_mut[b_idx * d.out_features + i] += d.b.data[i]
		}
	}

	mut result := &Tensor{
		data: y_mut
		shape: [batch, d.out_features]
		requires_grad: true
	}

	// Attach gradient function for backprop
	result.grad_fn = &GemmGrad{inputs: [x, d.w, d.b], a: x, b: d.w}

	return result
}

// params returns all trainable parameters of this layer.
pub fn (d &Dense) params() []&Tensor {
	return [d.w, d.b]
}

// weight returns the weight tensor.
pub fn (d &Dense) weight() &Tensor {
	return d.w
}

// bias returns the bias tensor.
pub fn (d &Dense) bias() &Tensor {
	return d.b
}