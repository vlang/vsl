module compute

import math

fn gemm_cpu_f64(a_data []f64, b_data []f64, m int, n int, k int) []f64 {
	mut out := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			mut sum := f64(0.0)
			for t in 0 .. k {
				sum += a_data[i * k + t] * b_data[t * n + j]
			}
			out[i * n + j] = sum
		}
	}
	return out
}

fn gemv_cpu_f64(a_data []f64, x_data []f64, m int, n int) []f64 {
	mut out := []f64{len: m}
	for i in 0 .. m {
		mut sum := f64(0.0)
		for j in 0 .. n {
			sum += a_data[i * n + j] * x_data[j]
		}
		out[i] = sum
	}
	return out
}

fn relu_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = if v > 0.0 { v } else { 0.0 }
	}
	return out
}

fn sigmoid_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = 1.0 / (1.0 + math.exp(-v))
	}
	return out
}

fn add_vec_cpu_f64(a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('add_vec_cpu_f64: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] + b_data[i]
	}
	return out
}

fn mul_vec_cpu_f64(a_data []f64, b_data []f64) ![]f64 {
	if a_data.len != b_data.len {
		return error('mul_vec_cpu_f64: length mismatch ${a_data.len} vs ${b_data.len}')
	}
	mut out := []f64{len: a_data.len}
	for i in 0 .. a_data.len {
		out[i] = a_data[i] * b_data[i]
	}
	return out
}

fn add_scalar_cpu_f64(x_data []f64, s f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = v + s
	}
	return out
}

fn mul_scalar_cpu_f64(x_data []f64, s f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = v * s
	}
	return out
}

fn tanh_cpu_f64(x_data []f64) []f64 {
	mut out := []f64{len: x_data.len}
	for i, v in x_data {
		out[i] = math.tanh(v)
	}
	return out
}
