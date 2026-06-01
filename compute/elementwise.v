// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// relu_matrix is a compatibility wrapper around compute.relu.
pub fn relu_matrix(ctx &ComputeContext, data []f64) ![]f64 {
	return relu(ctx, data)
}

// sigmoid_matrix is a compatibility wrapper around compute.sigmoid.
pub fn sigmoid_matrix(ctx &ComputeContext, data []f64) ![]f64 {
	return sigmoid(ctx, data)
}

// gemv_gpu is a compatibility wrapper around compute.gemv.
pub fn gemv_gpu(ctx &ComputeContext, a_data []f64, m int, n int, x_data []f64) ![]f64 {
	return gemv(ctx, a_data, x_data, m, n)
}
