module compute

import vsl.cuda

pub fn mul_vec_cuda_impl(dev &cuda.CudaDevice, a_data []f64, b_data []f64) ![]f64 {
	return error('mul_vec_cuda_impl: build with -d cuda')
}

pub fn layernorm_cuda_impl(dev &cuda.CudaDevice, x_data []f64, gamma []f64, beta []f64) ![]f64 {
	return error('layernorm_cuda_impl: build with -d cuda')
}
