// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
//
// ml/nn/loss.v — Loss functions

module nn

import math

// mse_loss computes mean squared error: L = (1/N) * sum((y_pred - y_true)^2)
pub fn mse_loss(y_pred &Tensor, y_true &Tensor) f64 {
	if y_pred.data.len != y_true.data.len {
		panic('mse_loss: prediction and target must have same size')
	}
	mut sum_sq := 0.0
	for i := 0; i < y_pred.data.len; i++ {
		diff := y_pred.data[i] - y_true.data[i]
		sum_sq += diff * diff
	}
	return sum_sq / f64(y_pred.data.len)
}

// mse_loss_grad computes gradient of MSE with respect to y_pred.
pub fn mse_loss_grad(y_pred &Tensor, y_true &Tensor) []f64 {
	n := y_pred.data.len
	mut grad := []f64{len: n}
	for i := 0; i < n; i++ {
		grad[i] = 2.0 * (y_pred.data[i] - y_true.data[i]) / f64(n)
	}
	return grad
}

// cross_entropy_loss computes cross-entropy loss for multi-class classification.
pub fn cross_entropy_loss(y_pred &Tensor, y_true []int) f64 {
	n := y_pred.data.len
	axis_len := if y_pred.shape.len > 1 { y_pred.shape[y_pred.shape.len - 1] } else { n }
	batch := n / axis_len

	mut loss := 0.0
	for b := 0; b < batch; b++ {
		class_idx := y_true[b % y_true.len]
		prob := y_pred.data[b * axis_len + class_idx]
		if prob <= 0.0 {
			loss += 1e9
		} else {
			loss += -math.log(prob)
		}
	}
	return loss / f64(batch)
}

// cross_entropy_grad computes gradient of cross-entropy w.r.t. softmax inputs.
pub fn cross_entropy_grad(y_pred &Tensor, y_true []int) []f64 {
	n := y_pred.data.len
	axis_len := if y_pred.shape.len > 1 { y_pred.shape[y_pred.shape.len - 1] } else { n }
	batch := n / axis_len

	mut grad := []f64{len: n}
	for b := 0; b < batch; b++ {
		class_idx := y_true[b % y_true.len]
		for c := 0; c < axis_len; c++ {
			idx := b * axis_len + c
			if c == class_idx {
				grad[idx] = y_pred.data[idx] - 1.0
			} else {
				grad[idx] = y_pred.data[idx]
			}
		}
	}
	return grad
}

// bce_loss computes binary cross-entropy loss.
pub fn bce_loss(y_pred &Tensor, y_true &Tensor) f64 {
	if y_pred.data.len != y_true.data.len {
		panic('bce_loss: prediction and target must have same size')
	}
	mut loss := 0.0
	for i := 0; i < y_pred.data.len; i++ {
		p := math.max(1e-9, math.min(1.0 - 1e-9, y_pred.data[i]))
		t := y_true.data[i]
		loss += t * math.log(p) + (1.0 - t) * math.log(1.0 - p)
	}
	return -loss / f64(y_pred.data.len)
}