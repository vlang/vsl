module compute

import vsl.vcl
import vsl.vcl.compute as vcl_compute
import vsl.vulkan
import vsl.vulkan.compute as vk_compute

// op_supported returns true when an operation is implemented for a backend.
pub fn op_supported(backend Backend, op string) bool {
	return match backend {
		.vulkan {
			op in ['gemm', 'gemv', 'relu', 'sigmoid']
		}
		.vcl {
			op in ['gemm', 'gemv', 'relu', 'sigmoid', 'tanh', 'add_vec', 'mul_vec', 'add_scalar',
				'mul_scalar', 'softmax', 'layernorm', 'sum', 'mean', 'max', 'conv2d']
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

fn (ctx &ComputeContext) resolve_vulkan_device() !&vulkan.Device {
	if !isnil(ctx.vulkan_device) {
		return ctx.vulkan_device
	}
	return vulkan.new_device()
}

fn (ctx &ComputeContext) resolve_vcl_device() !&vcl.Device {
	if !isnil(ctx.vcl_device) {
		return ctx.vcl_device
	}
	return vcl.get_default_device()
}

// gemm computes C = A * B with row-major input/output.
pub fn gemm(ctx &ComputeContext, a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	if a_data.len != m * k {
		return error('compute.gemm: expected a_data len=${m * k}, got ${a_data.len}')
	}
	if b_data.len != k * n {
		return error('compute.gemm: expected b_data len=${k * n}, got ${b_data.len}')
	}

	backend := ctx.select_backend()
	match backend {
		.vulkan {
			$if vulkan ? {
				dev := ctx.resolve_vulkan_device()!
				return vk_compute.gemm_vulkan(dev, a_data, b_data, m, n, k)
			} $else {
				if ctx.strict {
					return error('compute.gemm: vulkan backend not enabled')
				}
				return gemm_cpu_f64(a_data, b_data, m, n, k)
			}
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				a_col := row_to_col_major(a_data, m, k)
				b_col := row_to_col_major(b_data, k, n)
				mut d := dev
				c_col := vcl_compute.gemm_vcl(mut d, a_col, b_col, m, n, k)!
				return col_to_row_major(c_col, m, n)
			} $else {
				if ctx.strict {
					return error('compute.gemm: vcl backend not enabled')
				}
				return gemm_cpu_f64(a_data, b_data, m, n, k)
			}
		}
		.cpu {
			return gemm_cpu_f64(a_data, b_data, m, n, k)
		}
		.auto {
			return error('compute.gemm: invalid backend .auto in dispatch')
		}
	}
}

// gemv computes y = A * x with row-major A.
pub fn gemv(ctx &ComputeContext, a_data []f64, x_data []f64, m int, n int) ![]f64 {
	if a_data.len != m * n {
		return error('compute.gemv: expected a_data len=${m * n}, got ${a_data.len}')
	}
	if x_data.len != n {
		return error('compute.gemv: expected x_data len=${n}, got ${x_data.len}')
	}
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			$if vulkan ? {
				dev := ctx.resolve_vulkan_device()!
				return vk_compute.gemv_vulkan(dev, a_data, x_data, m, n)
			} $else {
				if ctx.strict {
					return error('compute.gemv: vulkan backend not enabled')
				}
				return gemv_cpu_f64(a_data, x_data, m, n)
			}
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				a_col := row_to_col_major(a_data, m, n)
				mut d := dev
				return vcl_compute.gemv_vcl(mut d, a_col, x_data, m, n)
			} $else {
				if ctx.strict {
					return error('compute.gemv: vcl backend not enabled')
				}
				return gemv_cpu_f64(a_data, x_data, m, n)
			}
		}
		.cpu {
			return gemv_cpu_f64(a_data, x_data, m, n)
		}
		.auto {
			return error('compute.gemv: invalid backend .auto in dispatch')
		}
	}
}

pub fn relu(ctx &ComputeContext, x_data []f64) ![]f64 {
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			$if vulkan ? {
				dev := ctx.resolve_vulkan_device()!
				return vk_compute.relu_vulkan(dev, x_data)
			} $else {
				if ctx.strict {
					return error('compute.relu: vulkan backend not enabled')
				}
				return relu_cpu_f64(x_data)
			}
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				mut d := dev
				return vcl_compute.relu_vcl(mut d, x_data)
			} $else {
				if ctx.strict {
					return error('compute.relu: vcl backend not enabled')
				}
				return relu_cpu_f64(x_data)
			}
		}
		.cpu {
			return relu_cpu_f64(x_data)
		}
		.auto {
			return error('compute.relu: invalid backend .auto in dispatch')
		}
	}
}

pub fn sigmoid(ctx &ComputeContext, x_data []f64) ![]f64 {
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			$if vulkan ? {
				dev := ctx.resolve_vulkan_device()!
				return vk_compute.sigmoid_vulkan(dev, x_data)
			} $else {
				if ctx.strict {
					return error('compute.sigmoid: vulkan backend not enabled')
				}
				return sigmoid_cpu_f64(x_data)
			}
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				mut d := dev
				return vcl_compute.sigmoid_vcl(mut d, x_data)
			} $else {
				if ctx.strict {
					return error('compute.sigmoid: vcl backend not enabled')
				}
				return sigmoid_cpu_f64(x_data)
			}
		}
		.cpu {
			return sigmoid_cpu_f64(x_data)
		}
		.auto {
			return error('compute.sigmoid: invalid backend .auto in dispatch')
		}
	}
}

pub fn tanh(ctx &ComputeContext, x_data []f64) ![]f64 {
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			if ctx.strict {
				return error('compute.tanh: vulkan backend not implemented yet')
			}
			return tanh_cpu_f64(x_data)
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				mut d := dev
				return vcl_compute.tanh_vcl(mut d, x_data)
			} $else {
				if ctx.strict {
					return error('compute.tanh: vcl backend not enabled')
				}
				return tanh_cpu_f64(x_data)
			}
		}
		.cpu {
			return tanh_cpu_f64(x_data)
		}
		.auto {
			return error('compute.tanh: invalid backend .auto in dispatch')
		}
	}
}

pub fn add_vec(ctx &ComputeContext, a_data []f64, b_data []f64) ![]f64 {
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			if ctx.strict {
				return error('compute.add_vec: vulkan backend not implemented yet')
			}
			return add_vec_cpu_f64(a_data, b_data)
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				mut d := dev
				return vcl_compute.add_vec_vcl(mut d, a_data, b_data)
			} $else {
				if ctx.strict {
					return error('compute.add_vec: vcl backend not enabled')
				}
				return add_vec_cpu_f64(a_data, b_data)
			}
		}
		.cpu {
			return add_vec_cpu_f64(a_data, b_data)
		}
		.auto {
			return error('compute.add_vec: invalid backend .auto in dispatch')
		}
	}
}

pub fn mul_vec(ctx &ComputeContext, a_data []f64, b_data []f64) ![]f64 {
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			if ctx.strict {
				return error('compute.mul_vec: vulkan backend not implemented yet')
			}
			return mul_vec_cpu_f64(a_data, b_data)
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				mut d := dev
				return vcl_compute.mul_vec_vcl(mut d, a_data, b_data)
			} $else {
				if ctx.strict {
					return error('compute.mul_vec: vcl backend not enabled')
				}
				return mul_vec_cpu_f64(a_data, b_data)
			}
		}
		.cpu {
			return mul_vec_cpu_f64(a_data, b_data)
		}
		.auto {
			return error('compute.mul_vec: invalid backend .auto in dispatch')
		}
	}
}

pub fn add_scalar(ctx &ComputeContext, x_data []f64, s f64) ![]f64 {
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			if ctx.strict {
				return error('compute.add_scalar: vulkan backend not implemented yet')
			}
			return add_scalar_cpu_f64(x_data, s)
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				mut d := dev
				return vcl_compute.add_scalar_vcl(mut d, x_data, s)
			} $else {
				if ctx.strict {
					return error('compute.add_scalar: vcl backend not enabled')
				}
				return add_scalar_cpu_f64(x_data, s)
			}
		}
		.cpu {
			return add_scalar_cpu_f64(x_data, s)
		}
		.auto {
			return error('compute.add_scalar: invalid backend .auto in dispatch')
		}
	}
}

pub fn mul_scalar(ctx &ComputeContext, x_data []f64, s f64) ![]f64 {
	backend := ctx.select_backend()
	match backend {
		.vulkan {
			if ctx.strict {
				return error('compute.mul_scalar: vulkan backend not implemented yet')
			}
			return mul_scalar_cpu_f64(x_data, s)
		}
		.vcl {
			$if vcl ? {
				mut dev := ctx.resolve_vcl_device()!
				mut d := dev
				return vcl_compute.mul_scalar_vcl(mut d, x_data, s)
			} $else {
				if ctx.strict {
					return error('compute.mul_scalar: vcl backend not enabled')
				}
				return mul_scalar_cpu_f64(x_data, s)
			}
		}
		.cpu {
			return mul_scalar_cpu_f64(x_data, s)
		}
		.auto {
			return error('compute.mul_scalar: invalid backend .auto in dispatch')
		}
	}
}
