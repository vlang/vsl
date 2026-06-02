module compute

// Stub when not built with `-d vulkan`.
pub fn (ctx &ComputeContext) resolve_vulkan_device() !voidptr {
	_ = ctx
	return error(@FN + ': compile with -d vulkan')
}
