module compute

import vsl.vulkan

// relu_gpu computes dst[i] = max(0, src[i]) on GPU.
pub fn relu_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	if ctx.select_backend() != .vulkan {
		return error('compute.relu_gpu: requires vulkan backend context')
	}
	dev := ctx.resolve_vulkan_device()!
	vulkan.relu(dev, dst, src)!
}

// sigmoid_gpu computes dst[i] = 1/(1+exp(-src[i])) on GPU.
pub fn sigmoid_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	if ctx.select_backend() != .vulkan {
		return error('compute.sigmoid_gpu: requires vulkan backend context')
	}
	dev := ctx.resolve_vulkan_device()!
	vulkan.sigmoid(dev, dst, src)!
}
