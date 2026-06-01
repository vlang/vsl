module compute

import vsl.cuda

// mul_vec_cuda_impl exposes this operation as part of the public API.
pub fn mul_vec_cuda_impl(dev &cuda.CudaDevice, a_data []f64, b_data []f64) ![]f64 {
	return error('mul_vec_cuda_impl: build with -d cuda')
}

// layernorm_cuda_impl exposes this operation as part of the public API.
pub fn layernorm_cuda_impl(dev &cuda.CudaDevice, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	return error('layernorm_cuda_impl: build with -d cuda')
}
