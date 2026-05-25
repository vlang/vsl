// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
//
// ml_nn_xor — XOR training example using CUDA GPU backend
//
// Trains a small MLP to learn XOR using cuBLAS/cuDNN GPU kernels.

module main

import vsl.compute
import ml.nn

fn main() {
	println('=== XOR Training on CUDA GPU (cuBLAS + cuDNN) ===')

	// Initialize CUDA context
	mut ctx := compute.new_context(.cuda)
	println('Backend: ${ctx.backend}')

	// XOR dataset: [[0,0], [0,1], [1,0], [1,1]] flattened row-major
	x_data := [f64(0), f64(0), f64(0), f64(1), f64(1), f64(0), f64(1), f64(1)]
	y_data := [f64(0), f64(1), f64(1), f64(0)]

	x_shape := [4, 2]
	y_shape := [4, 1]

	// Create tensors
	mut x_tensor := &nn.Tensor{
		data: x_data
		shape: x_shape
		requires_grad: false
	}
	mut y_tensor := &nn.Tensor{
		data: y_data
		shape: y_shape
		requires_grad: false
	}

	// Build MLP: 2 -> 8 -> 8 -> 1
	mut dense1 := nn.Dense.new(2, 8, mut ctx)
	mut dense2 := nn.Dense.new(8, 8, mut ctx)
	mut dense3 := nn.Dense.new(8, 1, mut ctx)

	// Get all parameters
	mut all_params := [dense1.w, dense1.b, dense2.w, dense2.b, dense3.w, dense3.b]

	// Create optimizer (Adam)
	mut opt := nn.Adam.new(0.05)

	// Training loop
	epochs := 2000
	println('\nTraining...')
	for epoch := 0; epoch < epochs; epoch++ {
		// Forward pass
		h1 := dense1.forward(x_tensor, mut ctx)
		h1_act := nn.relu(h1, mut ctx)
		h2 := dense2.forward(h1_act, mut ctx)
		h2_act := nn.relu(h2, mut ctx)
		h3 := dense3.forward(h2_act, mut ctx)
		y_pred := nn.sigmoid(h3, mut ctx)

		// Compute loss (MSE)
		mut loss_val := 0.0
		for i := 0; i < 4; i++ {
			diff := y_pred.data[i] - y_tensor.data[i]
			loss_val += diff * diff
		}
		loss_val /= 4.0

		// Print progress
		if epoch % 200 == 0 {
			println('Epoch ${epoch:5d} | Loss: ${loss_val:.6f}')
		}

		// Backward pass (manual gradient computation)
		mut grad_loss := []f64{len: 4}
		for i := 0; i < 4; i++ {
			grad_loss[i] = 2.0 * (y_pred.data[i] - y_tensor.data[i]) / 4.0
		}

		// Backprop through sigmoid
		mut grad_h3 := []f64{len: 4}
		for i := 0; i < 4; i++ {
			sig := y_pred.data[i]
			grad_h3[i] = grad_loss[i] * sig * (1.0 - sig)
		}

		// Backprop through dense3
		batch := 4
		out_f := 1
		in_f := 8

		mut dw3 := []f64{len: out_f * in_f}
		mut db3 := []f64{len: out_f}
		mut dh2 := []f64{len: batch * in_f}

		for b := 0; b < batch; b++ {
			for j := 0; j < out_f; j++ {
				g := grad_h3[b * out_f + j]
				db3[j] += g
				for k := 0; k < in_f; k++ {
					dw3[j * in_f + k] += g * h2_act.data[b * in_f + k]
					dh2[b * in_f + k] += g * dense3.w.data[j * in_f + k]
				}
			}
		}

		dense3.w.grad = &nn.Grad{data: dw3}
		dense3.b.grad = &nn.Grad{data: db3}

		// Backprop through ReLU (h2_act = relu(h2))
		mut grad_h2 := []f64{len: batch * in_f}
		for i := 0; i < grad_h2.len; i++ {
			if h2.data[i] > 0 {
				grad_h2[i] = dh2[i]
			}
		}

		// Backprop through dense2
		out_f2 := 8
		in_f2 := 8

		mut dw2 := []f64{len: out_f2 * in_f2}
		mut db2 := []f64{len: out_f2}
		mut dh1 := []f64{len: batch * in_f2}

		for b := 0; b < batch; b++ {
			for j := 0; j < out_f2; j++ {
				g := grad_h2[b * out_f2 + j]
				db2[j] += g
				for k := 0; k < in_f2; k++ {
					dw2[j * in_f2 + k] += g * h1_act.data[b * in_f2 + k]
					dh1[b * in_f2 + k] += g * dense2.w.data[j * in_f2 + k]
				}
			}
		}

		dense2.w.grad = &nn.Grad{data: dw2}
		dense2.b.grad = &nn.Grad{data: db2}

		// Backprop through ReLU (h1_act = relu(h1))
		mut grad_h1 := []f64{len: batch * in_f2}
		for i := 0; i < grad_h1.len; i++ {
			if h1.data[i] > 0 {
				grad_h1[i] = dh1[i]
			}
		}

		// Backprop through dense1
		out_f1 := 8
		in_f1 := 2

		mut dw1 := []f64{len: out_f1 * in_f1}
		mut db1 := []f64{len: out_f1}

		for b := 0; b < batch; b++ {
			for j := 0; j < out_f1; j++ {
				g := grad_h1[b * out_f1 + j]
				db1[j] += g
				for k := 0; k < in_f1; k++ {
					dw1[j * in_f1 + k] += g * x_tensor.data[b * in_f1 + k]
				}
			}
		}

		dense1.w.grad = &nn.Grad{data: dw1}
		dense1.b.grad = &nn.Grad{data: db1}

		// Update parameters
		opt.step(mut all_params)
		opt.zero_grad(mut all_params)
	}

	// Final evaluation
	println('\n=== Final Evaluation ===')
	h1 := dense1.forward(x_tensor, mut ctx)
	h1_act := nn.relu(h1, mut ctx)
	h2 := dense2.forward(h1_act, mut ctx)
	h2_act := nn.relu(h2, mut ctx)
	h3 := dense3.forward(h2_act, mut ctx)
	y_pred := nn.sigmoid(h3, mut ctx)

	println('Predictions after training:')
	xor_expected := [0.0, 1.0, 1.0, 0.0]
	for i := 0; i < 4; i++ {
		pred := if y_pred.data[i] > 0.5 { 1 } else { 0 }
		expected := xor_expected[i]
		println('  Input: (${f64(i / 2)}, ${f64(i % 2)}) | Pred: ${pred} | Expected: ${expected}')
	}

	// Check XOR is learned
	success := (y_pred.data[0] < 0.1) && (y_pred.data[1] > 0.9) && (y_pred.data[2] > 0.9) && (y_pred.data[3] < 0.1)
	if success {
		println('\n[X] XOR learned successfully on CUDA GPU!')
	} else {
		println('\n[X] XOR not fully converged (may need more epochs or tuning)')
	}
}