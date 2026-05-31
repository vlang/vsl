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

	// CUBLAS_SIDE_LEFT = 0: diag(A) * B, A and B are n×1 columns, lda/ldb/ldc >= n.
	status := C.cublasDdgmm(dev.cublas, 0, n, 1, &f64(d_a.ptr), n, &f64(d_b.ptr), n, &f64(d_c.ptr),
		n)
	if status != cuda.cublas_status_success {
		return error('mul_vec_cuda_impl: cublasDdgmm: ${cuda.cublas_error(status)}')
	}

	mut out := []f64{len: n}
	d_c.download[f64](mut out)!
	return out
}

// layernorm_cuda_impl: cudnnLayerNormForward not linked on all cuDNN builds.
pub fn layernorm_cuda_impl(dev &cuda.CudaDevice, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	_ := dev
	return error('layernorm_cuda_impl: cudnnLayerNormForward unavailable')
}
