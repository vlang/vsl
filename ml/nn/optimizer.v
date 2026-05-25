// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
//
// ml/nn/optimizer.v — SGD and Adam optimizers

module nn

import math

// Optimizer is the base interface for all optimizers.
pub interface Optimizer {
	step(model []&Tensor)
	zero_grad(model []&Tensor)
}

// SGD implements stochastic gradient descent with momentum and L2 regularization.
pub struct SGD {
pub:
	lr           f64
	momentum     f64
	weight_decay f64
mut:
	velocities   map[string][]f64
}

pub fn SGD.new(lr f64) &SGD {
	return &SGD{
		lr: lr
		momentum: 0.0
		weight_decay: 0.0
		velocities: map[string][]f64{}
	}
}

// step performs one optimization step.
pub fn (mut o SGD) step(mut model []&Tensor) {
	for i := 0; i < model.len; i++ {
		mut t := model[i]
		if isnil(t.grad) || isnil(t.grad.data) {
			continue
		}
		// Compute update: grad + weight_decay * param
		mut update := t.grad.data.clone()
		if o.weight_decay > 0.0 {
			for j := 0; j < t.data.len; j++ {
				update[j] += o.weight_decay * t.data[j]
			}
		}
		// Apply momentum
		if o.momentum > 0.0 {
			key := '${t}'
			if key in o.velocities {
				vel := o.velocities[key]
				for j := 0; j < update.len; j++ {
					update[j] = o.momentum * vel[j] + update[j]
				}
				o.velocities[key] = update
			} else {
				o.velocities[key] = update
			}
		}
		// Apply learning rate
		mut data_clone := t.data.clone()
		for j := 0; j < data_clone.len; j++ {
			data_clone[j] -= o.lr * update[j]
		}
		t.data = data_clone
	}
}

// zero_grad clears gradients for all parameters.
pub fn (mut o SGD) zero_grad(mut model []&Tensor) {
	for i := 0; i < model.len; i++ {
		mut t := model[i]
		if !isnil(t.grad) {
			t.grad.data = []f64{}
		}
	}
}

// Adam implements the Adam optimizer (Adaptive Moment Estimation).
pub struct Adam {
pub:
	lr           f64
	beta1        f64
	beta2        f64
	epsilon      f64
	weight_decay f64
mut:
	t     int
	m_map map[string][]f64
	v_map map[string][]f64
}

pub fn Adam.new(lr f64) &Adam {
	return &Adam{
		lr: lr
		beta1: 0.9
		beta2: 0.999
		epsilon: 1e-8
		weight_decay: 0.0
		t: 0
		m_map: map[string][]f64{}
		v_map: map[string][]f64{}
	}
}

// step performs one Adam optimization step.
pub fn (mut o Adam) step(mut model []&Tensor) {
	o.t++
	for i := 0; i < model.len; i++ {
		mut t := model[i]
		if isnil(t.grad) || isnil(t.grad.data) {
			continue
		}
		key := '${t}'
		grad := t.grad.data

		// Get or initialize m and v
		mut m := if key in o.m_map { o.m_map[key] } else { []f64{len: grad.len} }
		mut v := if key in o.v_map { o.v_map[key] } else { []f64{len: grad.len} }

		// Apply weight decay (AdamW style)
		mut grad_with_decay := grad.clone()
		if o.weight_decay > 0.0 {
			for j := 0; j < t.data.len; j++ {
				grad_with_decay[j] += o.weight_decay * t.data[j]
			}
		}

		// Update biased first moment: m = beta1 * m + (1-beta1) * g
		for j := 0; j < grad_with_decay.len; j++ {
			m[j] = o.beta1 * m[j] + (1.0 - o.beta1) * grad_with_decay[j]
		}
		// Update biased second moment: v = beta2 * v + (1-beta2) * g^2
		for j := 0; j < grad_with_decay.len; j++ {
			v[j] = o.beta2 * v[j] + (1.0 - o.beta2) * grad_with_decay[j] * grad_with_decay[j]
		}

		// Compute bias-corrected first moment
		mut m_hat := []f64{len: m.len}
		mt := math.pow(o.beta1, f64(o.t))
		for j := 0; j < m.len; j++ {
			m_hat[j] = m[j] / (1.0 - mt)
		}
		// Compute bias-corrected second moment
		mut v_hat := []f64{len: v.len}
		vt := math.pow(o.beta2, f64(o.t))
		for j := 0; j < v.len; j++ {
			v_hat[j] = v[j] / (1.0 - vt)
		}

		// Apply update: theta = theta - lr * m_hat / (sqrt(v_hat) + epsilon)
		mut data_clone := t.data.clone()
		for j := 0; j < data_clone.len; j++ {
			denom := math.sqrt(v_hat[j]) + o.epsilon
			data_clone[j] -= o.lr * m_hat[j] / denom
		}
		t.data = data_clone

		o.m_map[key] = m
		o.v_map[key] = v
	}
}

// zero_grad clears gradients for all parameters.
pub fn (mut o Adam) zero_grad(mut model []&Tensor) {
	for i := 0; i < model.len; i++ {
		mut t := model[i]
		if !isnil(t.grad) {
			t.grad.data = []f64{}
		}
	}
}