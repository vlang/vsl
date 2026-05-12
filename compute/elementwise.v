// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.vulkan

// relu_gpu computes dst[i] = max(0, src[i]) on GPU.
// This API is kept for compatibility and requires a Vulkan context.
pub fn relu_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	if ctx.select_backend() != .vulkan {
		return error('compute.relu_gpu: requires vulkan backend context')
	}
	dev := ctx.resolve_vulkan_device()!
	vulkan.relu(dev, dst, src)!
}

// sigmoid_gpu computes dst[i] = 1/(1+exp(-src[i])) on GPU.
// This API is kept for compatibility and requires a Vulkan context.
pub fn sigmoid_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	if ctx.select_backend() != .vulkan {
		return error('compute.sigmoid_gpu: requires vulkan backend context')
	}
	dev := ctx.resolve_vulkan_device()!
	vulkan.sigmoid(dev, dst, src)!
}

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
