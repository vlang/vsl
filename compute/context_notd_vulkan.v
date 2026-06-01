module compute

import vsl.vulkan

// Stub when not built with `-d vulkan`.
pub fn (ctx &ComputeContext) resolve_vulkan_device() !&vulkan.Device {
	_ = ctx
	return error(@FN + ': compile with -d vulkan')
}
