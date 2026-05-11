// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module la

import vsl.compute

// gemm_vulkan computes C = A * B using Vulkan GPU compute.
// All matrices are f64, row-major (VSL Matrix format).
//
// Returns a new Matrix[f64] with the result.
// Falls back to error if Vulkan device initialization fails.
//
// Example:
// ```v
// import vsl.la
// a := la.matrix_raw(2, 3, [1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
// b := la.matrix_raw(3, 2, [7.0, 8.0, 9.0, 10.0, 11.0, 12.0])
// c := la.gemm_vulkan(a, b)!
// ```
pub fn gemm_vulkan(a &Matrix[f64], b &Matrix[f64]) !&Matrix[f64] {
	m := a.m
	n := b.n
	c_data := compute.gemm_gpu(a.data, a.m, a.n, b.data, b.m, b.n)!
	return Matrix.raw[f64](m, n, c_data)
}
