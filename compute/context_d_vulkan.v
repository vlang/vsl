module compute

import vsl.vulkan

// resolve_vulkan_device returns the Vulkan device for GPU buffer ops.
pub fn (ctx &ComputeContext) resolve_vulkan_device() !&vulkan.Device {
	if !isnil(ctx.vulkan_device) {
		return unsafe { &vulkan.Device(ctx.vulkan_device) }
	}
	return vulkan.new_device()
}
