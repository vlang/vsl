module compute

// Backend selects which compute backend to use.
pub enum Backend {
	auto
	vulkan
	vcl
	cuda
	cpu
}

// ComputeContext carries backend preference and optional device handles.
@[heap]
pub struct ComputeContext {
pub mut:
	backend       Backend = .auto
	vulkan_device voidptr = unsafe { nil }
	vcl_device    voidptr = unsafe { nil }
	cuda_device   voidptr = unsafe { nil }
	strict        bool
}

// new_context creates a backend-agnostic compute context.
pub fn new_context(backend Backend) &ComputeContext {
	return &ComputeContext{
		backend: backend
	}
}

// new_vulkan_context creates a compute context from an existing Vulkan device.
pub fn new_vulkan_context(dev voidptr) &ComputeContext {
	return &ComputeContext{
		backend:       .vulkan
		vulkan_device: dev
	}
}

// new_vcl_context creates a compute context from an existing VCL device.
pub fn new_vcl_context(dev voidptr) &ComputeContext {
	return &ComputeContext{
		backend:    .vcl
		vcl_device: dev
	}
}

// new_cuda_context creates a compute context for CUDA backend.
pub fn new_cuda_context() &ComputeContext {
	return &ComputeContext{
		backend: .cuda
	}
}

// with_vulkan_device sets explicit Vulkan device handle.
pub fn (mut ctx ComputeContext) with_vulkan_device(dev voidptr) &ComputeContext {
	ctx.vulkan_device = dev
	return &ctx
}

// with_vcl_device sets explicit VCL device handle.
pub fn (mut ctx ComputeContext) with_vcl_device(dev voidptr) &ComputeContext {
	ctx.vcl_device = dev
	return &ctx
}

// with_cuda_device sets explicit CUDA device handle.
pub fn (mut ctx ComputeContext) with_cuda_device(dev voidptr) &ComputeContext {
	ctx.cuda_device = dev
	return &ctx
}

// with_strict toggles strict backend behavior.
// When true, operations fail if the selected backend is unavailable.
pub fn (mut ctx ComputeContext) with_strict(strict bool) &ComputeContext {
	ctx.strict = strict
	return &ctx
}

// available_backends returns the list of backends supported by this build.
pub fn available_backends() []Backend {
	mut out := []Backend{}
	$if vulkan ? {
		out << .vulkan
	}
	$if vcl ? {
		out << .vcl
	}
	$if cuda ? {
		out << .cuda
	}
	out << .cpu
	return out
}

// select_backend chooses effective backend for the operation.
fn (ctx &ComputeContext) select_backend() Backend {
	if ctx.backend != .auto {
		return ctx.backend
	}
	$if vulkan ? {
		return .vulkan
	}
	$if vcl ? {
		return .vcl
	}
	$if cuda ? {
		return .cuda
	}
	return .cpu
}
