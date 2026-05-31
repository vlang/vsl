// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
// This example demonstrates GEMM (matrix-matrix multiply) via the CUDA backend.
// Currently uses CPU fallback since cuBLAS bindings are pending (issue #238).
//
// Run with: v -d cuda run cuda/examples/gemm_example.v
import vsl.compute

fn main() {
	println('=== CUDA Backend GEMM Example ===')
	println('')

	// A: 2x3 row-major, B: 3x2 row-major, C = A * B: 2x2 row-major
	//
	// A = [[1, 2, 3],
	//      [4, 5, 6]]
	// B = [[7,  8],
	//      [9, 10],
	//      [11, 12]]
	//
	// C = [[1*7+2*9+3*11,  1*8+2*10+3*12 ],
	//      [4*7+5*9+6*11,  4*8+5*10+6*12 ]]
	//   = [[58,  64],
	//      [139, 154]]

	a := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] // 2x3
	b := [7.0, 8.0, 9.0, 10.0, 11.0, 12.0] // 3x2

	println('A (2x3): ${a}')
	println('B (3x2): ${b}')

	// Use CUDA backend via the compute dispatch layer
	ctx := compute.new_context(.cuda)
	c := compute.gemm(ctx, a, b, 2, 2, 3)! // m=2, n=2, k=3

	println('')
	println('C (2x2): ${c}')
	println('Expected: [58.0, 64.0, 139.0, 154.0]')
	println('')
	println('Note: cuBLAS bindings pending — using CPU fallback.')
}
