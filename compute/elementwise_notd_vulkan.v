module compute

// Stubs when not built with `-d vulkan`.
pub fn relu_gpu(ctx &ComputeContext, dst voidptr, src voidptr) ! {
	_ = ctx
	_ = dst
	_ = src
	return error(@FN + ': compile with -d vulkan')
}

// sigmoid_gpu exposes this operation as part of the public API.
pub fn sigmoid_gpu(ctx &ComputeContext, dst voidptr, src voidptr) ! {
	_ = ctx
	_ = dst
	_ = src
	return error(@FN + ': compile with -d vulkan')
}
