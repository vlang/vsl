module la

import vsl.vulkan
import vsl.compute

// gemm_vulkan computes C = A * B on GPU using Vulkan.
// dev must be an initialised vulkan.Device (from vulkan.new_device()).
pub fn gemm_vulkan(dev &vulkan.Device, a &Matrix[f64], b &Matrix[f64]) !&Matrix[f64] {
	ctx := compute.new_vulkan_context(dev)
	m := a.m
	n := b.n
	c_data := compute.gemm_gpu(ctx, a.data, a.m, a.n, b.data, b.m, b.n)!
	return Matrix.raw[f64](m, n, c_data)
}
