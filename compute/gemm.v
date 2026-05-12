// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// gemm_gpu is a compatibility wrapper around compute.gemm for Vulkan contexts.
pub fn gemm_gpu(ctx &ComputeContext, a_data []f64, a_m int, a_n int, b_data []f64, b_m int, b_n int) ![]f64 {
	if a_n != b_m {
		return error('compute.gemm_gpu: dimension mismatch: A(${a_m}x${a_n}) * B(${b_m}x${b_n})')
	}
	return gemm(ctx, a_data, b_data, a_m, b_n, a_n)
}
