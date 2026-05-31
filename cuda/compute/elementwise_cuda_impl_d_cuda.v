// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.cuda

// mul_vec_cuda_impl: y[i] = a[i] * b[i] using cuBLAS ddgmm (vectors as n×1 columns).
pub fn mul_vec_cuda_impl(dev &cuda.CudaDevice, a_data []f64, b_data []f64) ![]f64 {
	n := a_data.len
	mut d_a := gpu_buf_new[f64](n)!
	defer { d_a.release() }
	mut d_b := gpu_buf_new[f64](n)!
	defer { d_b.release() }
	mut d_c := gpu_buf_new[f64](n)!
	defer { d_c.release() }

	d_a.upload[f64](a_data)!
	d_b.upload[f64](b_data)!

	status :=
		C.cublasDdgmm(dev.cublas, 1, 1, n, &f64(d_a.ptr), 1, &f64(d_b.ptr), 1, &f64(d_c.ptr), 1)
	if status != cuda.cublas_status_success {
		return error('mul_vec_cuda_impl: cublasDdgmm: ${cuda.cublas_error(status)}')
	}

	mut out := []f64{len: n}
	d_c.download[f64](mut out)!
	return out
}

// layernorm_cuda_impl: GPU via elementwise_layernorm_cuda_impl_d_cudnn_layernorm_cuda.v
pub fn layernorm_cuda_impl(dev &cuda.CudaDevice, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	_ := dev
	return error('layernorm_cuda_impl: build with -d cudnn_layernorm when cuDNN exports cudnnLayerNormForward')
}
