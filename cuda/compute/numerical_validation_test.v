module compute

import os
import math
import vsl.cuda

const f64_tol = 1e-10

fn test_gemm_cuda_matches_cpu_reference() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	if isnil(dev.cublas) {
		return
	}
	m := 2
	n := 2
	k := 3
	a := [f64(1), 2, 3, 4, 5, 6]
	b := [f64(7), 8, 9, 10, 11, 12]
	cpu := cpu_gemm_row_major(a, b, m, n, k)
	gpu := gemm_cuda(dev, a, b, m, n, k)!
	assert gpu.len == cpu.len
	for i in 0 .. gpu.len {
		assert math.abs(gpu[i] - cpu[i]) < f64_tol, 'gemm mismatch at ${i}'
	}
}

fn test_relu_cuda_matches_cpu_reference() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	if isnil(dev.cudnn) {
		return
	}
	x := [f64(-1), 2, -3, 4]
	cpu := relu_cpu_f64(x)
	gpu := relu_cuda(dev, x)!
	for i in 0 .. cpu.len {
		assert math.abs(gpu[i] - cpu[i]) < f64_tol
	}
}

fn test_mul_vec_cuda_matches_cpu_reference() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	if isnil(dev.cublas) {
		return
	}
	a := [f64(1), 2, 3, 4]
	b := [f64(5), 6, 7, 8]
	cpu := mul_vec_cpu_f64(a, b)
	gpu := mul_vec_cuda(dev, a, b)!
	for i in 0 .. cpu.len {
		assert math.abs(gpu[i] - cpu[i]) < f64_tol
	}
}

fn test_layernorm_cuda_matches_cpu_reference() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	if isnil(dev.cudnn) {
		return
	}
	x := [1.0, 2.0, 3.0, 4.0]
	gamma := [1.0, 1.0, 1.0, 1.0]
	beta := [0.0, 0.0, 0.0, 0.0]
	cpu := layernorm_cpu_f64(x, gamma, beta)!
	gpu := layernorm_cuda(dev, x, gamma, beta)!
	for i in 0 .. cpu.len {
		assert math.abs(gpu[i] - cpu[i]) < 1e-5, 'layernorm mismatch at ${i}'
	}
}

fn test_conv2d_cuda_matches_cpu_same_pad() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	if isnil(dev.cudnn) {
		return
	}
	input := [f64(1), 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	kernel := [f64(1), 0, 0, 0, 0, 1, 0, 0, 0]
	gpu := conv2d_cuda(dev, input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1) or {
		return
	}
	cpu := conv2d_cpu_same_pad_f64(input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1)!
	for i in 0 .. gpu.len {
		assert math.abs(gpu[i] - cpu[i]) < 1e-5, 'conv2d mismatch at ${i}'
	}
}

fn cpu_gemm_row_major(a []f64, b []f64, m int, n int, k int) []f64 {
	mut c := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			mut sum := 0.0
			for p in 0 .. k {
				sum += a[i * k + p] * b[p * n + j]
			}
			c[i * n + j] = sum
		}
	}
	return c
}

fn conv2d_cpu_same_pad_f64(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	pad_h := (k_h - 1) / 2
	pad_w := (k_w - 1) / 2
	out_h := (in_h + 2 * pad_h - k_h) / stride_h + 1
	out_w := (in_w + 2 * pad_w - k_w) / stride_w + 1
	out_size := batch * out_ch * out_h * out_w
	mut out := []f64{len: out_size}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for oh in 0 .. out_h {
				for ow in 0 .. out_w {
					mut sum := 0.0
					for ic in 0 .. in_ch {
						for krow in 0 .. k_h {
							for kcol in 0 .. k_w {
								ih := oh * stride_h + krow - pad_h
								iw := ow * stride_w + kcol - pad_w
								if ih < 0 || ih >= in_h || iw < 0 || iw >= in_w {
									continue
								}
								in_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
								k_idx := ((oc * in_ch + ic) * k_h + krow) * k_w + kcol
								sum += input[in_idx] * kernel[k_idx]
							}
						}
					}
					out_idx := ((b * out_ch + oc) * out_h + oh) * out_w + ow
					out[out_idx] = sum
				}
			}
		}
	}
	return out
}
