module compute

import vsl.vulkan

// Backend selects which compute backend to use.
pub enum Backend {
	vulkan
	vcl
	cpu
}

// ComputeContext holds a backend-specific device and associated state.
// Use new_vulkan_context() to construct.
@[heap]
pub struct ComputeContext {
mut:
	backend       Backend
	vulkan_device &vulkan.Device
	// future: vcl_device &vcl.Device
	// future: cpu_backend  CPUBackend
}

// new_vulkan_context creates a compute context from an existing vulkan.Device.
pub fn new_vulkan_context(dev &vulkan.Device) &ComputeContext {
	return &ComputeContext{
		backend:       .vulkan
		vulkan_device: dev
	}
}
