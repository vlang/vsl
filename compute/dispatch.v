// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

$if vulkan ? {
	import vsl.vulkan
	import vsl.vulkan.compute as vk_compute
}

$if vcl ? {
	import vsl.vcl
	import vsl.vcl.compute as vcl_compute
}

// op_supported returns true when an operation is implemented for a backend.
pub fn op_supported(backend Backend, op string) bool {
	return match backend {
		.vulkan {
			op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'add_scalar',
				'mul_scalar', 'softmax', 'layernorm']
		}
		.vcl {
			op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec', 'add_scalar',
				'mul_scalar', 'softmax', 'layernorm', 'sum', 'mean', 'max', 'conv2d']
		}
		.cuda {
			op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec', 'add_scalar',
				'mul_scalar', 'softmax', 'layernorm']
		}
		.cpu {
			op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec', 'add_scalar',
				'mul_scalar']
		}
		.auto {
			false
		}
	}
}

// resolve_backend returns the ComputeBackend implementation for the context's backend.
// This is the bridge between the old Backend enum + device handles and the new interface.
fn (ctx &ComputeContext) resolve_backend() !ComputeBackend {
	backend := ctx.select_backend()
	$if vulkan ? {
		if backend == .vulkan {
			dev := if !isnil(ctx.vulkan_device) {
				unsafe { &vulkan.Device(ctx.vulkan_device) }
			} else {
				vulkan.new_device()!
			}
			return new_vulkan_backend(dev)
		}
	}
	$if vcl ? {
		if backend == .vcl {
			dev := if !isnil(ctx.vcl_device) {
				unsafe { &vcl.Device(ctx.vcl_device) }
			} else {
				vcl.get_default_device()!
			}
			mut d := dev
			return new_vcl_backend(mut d)
		}
	}
	$if cuda ? {
		if backend == .cuda {
			return new_cuda_backend()
		}
	}
	return new_cpu_backend()
}

// gemm computes C = A * B with row-major input/output.
pub fn gemm(ctx &ComputeContext, a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	if a_data.len != m * k {
		return error('compute.gemm: expected a_data len=${m * k}, got ${a_data.len}')
	}
	if b_data.len != k * n {
		return error('compute.gemm: expected b_data len=${k * n}, got ${b_data.len}')
	}
	be := ctx.resolve_backend()!
	return be.gemm(a_data, b_data, m, n, k)
}

// gemv computes y = A * x with row-major A.
pub fn gemv(ctx &ComputeContext, a_data []f64, x_data []f64, m int, n int) ![]f64 {
	if a_data.len != m * n {
		return error('compute.gemv: expected a_data len=${m * n}, got ${a_data.len}')
	}
	if x_data.len != n {
		return error('compute.gemv: expected x_data len=${n}, got ${x_data.len}')
	}
	be := ctx.resolve_backend()!
	return be.gemv(a_data, x_data, m, n)
}

pub fn relu(ctx &ComputeContext, x_data []f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.relu(x_data)
}

pub fn sigmoid(ctx &ComputeContext, x_data []f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.sigmoid(x_data)
}

pub fn tanh(ctx &ComputeContext, x_data []f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.tanh(x_data)
}

pub fn add_vec(ctx &ComputeContext, a_data []f64, b_data []f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.add_vec(a_data, b_data)
}

pub fn mul_vec(ctx &ComputeContext, a_data []f64, b_data []f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.mul_vec(a_data, b_data)
}

pub fn add_scalar(ctx &ComputeContext, x_data []f64, s f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.add_scalar(x_data, s)
}

pub fn mul_scalar(ctx &ComputeContext, x_data []f64, s f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.mul_scalar(x_data, s)
}

pub fn softmax(ctx &ComputeContext, x_data []f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.softmax(x_data)
}

pub fn layernorm(ctx &ComputeContext, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	be := ctx.resolve_backend()!
	return be.layernorm(x_data, gamma, beta)
}

pub fn conv2d(ctx &ComputeContext, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	be := ctx.resolve_backend()!
	return be.conv2d(input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h, k_w, stride_h, stride_w)
}