// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
// Test all CUDA GPU operations
// Run with: v -d cuda -cc gcc run cuda/examples/cuda_ops_test.v

import vsl.compute

fn main() {
	println('=== CUDA Backend Full Test ===')
	println('')

	// Test GEMM
	test_gemm()
	// Test element-wise ops
	test_elementwise()
	// Test softmax
	test_softmax()
	// Test add_scalar
	test_add_scalar()

	println('')
	println('=== All CUDA tests passed ===')
}

fn test_gemm() {
	println('-- GEMM --')
	a := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] // 2x3
	b := [7.0, 8.0, 9.0, 10.0, 11.0, 12.0] // 3x2
	ctx := compute.new_context(.cuda)
	c := compute.gemm(ctx, a, b, 2, 2, 3)!
	println('GEMM: ${c}')
	assert c[0] == 58.0 && c[1] == 64.0 && c[2] == 139.0 && c[3] == 154.0, 'GEMM failed'
	println('GEMM: OK')
}

fn test_elementwise() {
	println('-- Element-wise ops --')
	ctx := compute.new_context(.cuda)

	// Test relu
	x := [-1.0, 2.0, -3.0, 4.0]
	r := compute.relu(ctx, x)!
	println('relu ${x} -> ${r}')
	assert r[0] == 0.0 && r[1] == 2.0 && r[2] == 0.0 && r[3] == 4.0, 'relu failed'
	println('relu: OK')

	// Test sigmoid
	s := compute.sigmoid(ctx, x)!
	println('sigmoid ${x} -> ${s}')
	assert s[0] < 0.27 && s[0] > 0.26 && s[1] > 0.88 && s[1] < 0.89, 'sigmoid failed'
	println('sigmoid: OK')

	// Test tanh
	t := compute.tanh(ctx, x)!
	println('tanh ${x} -> ${t}')
	assert t[0] < -0.76 && t[1] > 0.96 && t[2] < -0.99 && t[3] > 0.99, 'tanh failed'
	println('tanh: OK')

	// Test add_scalar
	add := compute.add_scalar(ctx, x, 10.0)!
	println('add_scalar ${x} + 10 -> ${add}')
	assert add[0] == 9.0 && add[1] == 12.0 && add[2] == 7.0 && add[3] == 14.0, 'add_scalar failed'
	println('add_scalar: OK')

	// Test mul_scalar
	mul := compute.mul_scalar(ctx, x, 2.0)!
	println('mul_scalar ${x} * 2 -> ${mul}')
	assert mul[0] == -2.0 && mul[1] == 4.0 && mul[2] == -6.0 && mul[3] == 8.0, 'mul_scalar failed'
	println('mul_scalar: OK')
}

fn test_softmax() {
	println('-- Softmax --')
	ctx := compute.new_context(.cuda)
	x := [1.0, 2.0, 3.0, 4.0]
	s := compute.softmax(ctx, x)!
	println('softmax ${x} -> ${s}')
	// Check sum ~= 1.0
	sum := s[0] + s[1] + s[2] + s[3]
	assert sum > 0.99 && sum < 1.01, 'softmax sum not 1: ${sum}'
	// Check ordering
	assert s[3] > s[2] && s[2] > s[1] && s[1] > s[0], 'softmax ordering wrong'
	println('softmax: OK (sum=${sum:.4f})')
}

fn test_add_scalar() {
	println('-- add_scalar --')
	ctx := compute.new_context(.cuda)
	x := [1.0, 2.0, 3.0, 4.0]
	r := compute.add_scalar(ctx, x, 5.0)!
	println('add_scalar ${x} + 5 -> ${r}')
	assert r[0] == 6.0 && r[1] == 7.0 && r[2] == 8.0 && r[3] == 9.0, 'add_scalar failed'
	println('add_scalar: OK')
}