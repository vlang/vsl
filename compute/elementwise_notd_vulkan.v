module compute

import vsl.vulkan

// Stubs when not built with `-d vulkan`.
pub fn relu_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	_ = ctx
	_ = dst
	_ = src
	return error(@FN + ': compile with -d vulkan')
}

pub fn sigmoid_gpu(ctx &ComputeContext, dst &vulkan.GpuBuffer, src &vulkan.GpuBuffer) ! {
	_ = ctx
	_ = dst
	_ = src
	return error(@FN + ': compile with -d vulkan')
}
