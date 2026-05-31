// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
// This example demonstrates basic usage of the CUDA compute backend.
// Currently uses CPU fallback since cuBLAS/cuDNN bindings are pending (issue #238).
//
// Run with: v -d cuda run cuda/examples/relu_example.v
import vsl.compute

fn main() {
	println('=== CUDA Backend ReLU Example ===')
	println('')

	// Create input data: [1.0, -2.0, 3.0, -4.0, 5.0, -6.0]
	x := [1.0, -2.0, 3.0, -4.0, 5.0, -6.0]
	println('Input:  ${x}')

	// Use CUDA backend via the compute dispatch layer
	ctx := compute.new_context(.cuda)
	result := compute.relu(ctx, x)!
	println('Output: ${result}')
	println('')
	println('Note: cuBLAS/cuDNN bindings pending — using CPU fallback.')
}
