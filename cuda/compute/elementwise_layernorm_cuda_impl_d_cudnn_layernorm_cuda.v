// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
// Build: v -d cuda -d cudnn_layernorm (requires cudnnLayerNormForward in libcudnn 9.1+).
module compute

import vsl.cuda

pub fn layernorm_cuda_impl(dev &cuda.CudaDevice, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	n := x_data.len
	if gamma.len != n || beta.len != n {
		return error('layernorm_cuda_impl: gamma/beta length mismatch')
	}
	epsilon := 1e-5

	mut norm_desc := cuda.CudnnTensorDescriptor(unsafe { nil })
	mut x_desc := cuda.CudnnTensorDescriptor(unsafe { nil })
	mut y_desc := cuda.CudnnTensorDescriptor(unsafe { nil })

	s0 := C.cudnnCreateTensorDescriptor(&norm_desc)
	if s0 != cuda.cudnn_status_success {
		return error('layernorm_cuda_impl: cudnnCreateTensorDescriptor(norm): ${cuda.cudnn_error(s0)}')
	}
	defer { C.cudnnDestroyTensorDescriptor(norm_desc) }

	s1 := C.cudnnCreateTensorDescriptor(&x_desc)
	if s1 != cuda.cudnn_status_success {
		return error('layernorm_cuda_impl: cudnnCreateTensorDescriptor(x): ${cuda.cudnn_error(s1)}')
	}
	defer { C.cudnnDestroyTensorDescriptor(x_desc) }

	s2 := C.cudnnCreateTensorDescriptor(&y_desc)
	if s2 != cuda.cudnn_status_success {
		return error('layernorm_cuda_impl: cudnnCreateTensorDescriptor(y): ${cuda.cudnn_error(s2)}')
	}
	defer { C.cudnnDestroyTensorDescriptor(y_desc) }

	stn := C.cudnnSetTensor4dDescriptor(norm_desc, cuda.cudnn_tensor_nchw, cuda.cudnn_data_type_double,
		1, 1, 1, n)
	if stn != cuda.cudnn_status_success {
		return error('layernorm_cuda_impl: cudnnSetTensor4dDescriptor(norm): ${cuda.cudnn_error(stn)}')
	}
	stx := C.cudnnSetTensor4dDescriptor(x_desc, cuda.cudnn_tensor_nchw, cuda.cudnn_data_type_double, 1,
		1, 1, n)
	if stx != cuda.cudnn_status_success {
		return error('layernorm_cuda_impl: cudnnSetTensor4dDescriptor(x): ${cuda.cudnn_error(stx)}')
	}
	sty := C.cudnnSetTensor4dDescriptor(y_desc, cuda.cudnn_tensor_nchw, cuda.cudnn_data_type_double, 1,
		1, 1, n)
	if sty != cuda.cudnn_status_success {
		return error('layernorm_cuda_impl: cudnnSetTensor4dDescriptor(y): ${cuda.cudnn_error(sty)}')
	}

	mut d_x := gpu_buf_new[f64](n)!
	defer { d_x.release() }
	mut d_gamma := gpu_buf_new[f64](n)!
	defer { d_gamma.release() }
	mut d_beta := gpu_buf_new[f64](n)!
	defer { d_beta.release() }
	mut d_y := gpu_buf_new[f64](n)!
	defer { d_y.release() }
	mut d_mean := gpu_buf_new[f64](1)!
	defer { d_mean.release() }
	mut d_inv_var := gpu_buf_new[f64](1)!
	defer { d_inv_var.release() }

	d_x.upload[f64](x_data)!
	d_gamma.upload[f64](gamma)!
	d_beta.upload[f64](beta)!

	alpha := f64(1.0)
	beta_sc := f64(0.0)
	st := C.cudnnLayerNormForward(dev.cudnn, norm_desc, &alpha, &beta_sc, x_desc, &f64(d_x.ptr),
		epsilon, &f64(d_gamma.ptr), &f64(d_beta.ptr), y_desc, &f64(d_y.ptr), &f64(d_mean.ptr),
		&f64(d_inv_var.ptr))
	if st != cuda.cudnn_status_success {
		return error('layernorm_cuda_impl: cudnnLayerNormForward: ${cuda.cudnn_error(st)}')
	}

	mut out := []f64{len: n}
	d_y.download[f64](mut out)!
	return out
}
