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

fn test_gemm_i8_i64_cuda_matches_cpu_reference() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	a := [i8(-128), 3, 5, 2, -7, 11]
	b := [i8(7), -8, -10, 11, 12, 5]
	cpu := cpu_gemm_i8_i64(a, b, 2, 2, 3)
	gpu := gemm_i8_i64_cuda(dev, a, b, 2, 2, 3)!
	assert gpu == cpu, 'INT8 GEMM mismatch: got ${gpu}, want ${cpu}'
}

fn test_gemm_i8_i64_cuda_reuses_preuploaded_b() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	a := [i8(-128), 3, 5, 2, -7, 11]
	b := [i8(7), -8, -10, 11, 12, 5]
	mut device_b := upload_i8_matrix_cuda(dev, b, 3, 2)!
	defer {
		device_b.release() or { panic(err) }
	}
	expected := cpu_gemm_i8_i64(a, b, 2, 2, 3)
	for _ in 0 .. 2 {
		got := gemm_i8_i64_cuda_with_b(dev, a, 2, 2, 3, device_b)!
		assert got == expected, 'preuploaded INT8 GEMM mismatch: got ${got}, want ${expected}'
	}
	if _ := gemm_i8_i64_cuda_with_b(dev, a, 2, 3, 3, device_b) {
		assert false, 'expected mismatched device matrix shape to fail'
	}
	other_device := &cuda.CudaDevice{
		device_id: dev.device_id + 1
	}
	if _ := gemm_i8_i64_cuda_with_b(other_device, a, 2, 2, 3, device_b) {
		assert false, 'expected mismatched CUDA device to fail'
	}
	device_b.release()!
	device_b.release()!
	if _ := gemm_i8_i64_cuda_with_b(dev, a, 2, 2, 3, device_b) {
		assert false, 'expected use after release to fail'
	}
}

fn test_gemm_i8_i64_cuda_splits_reductions_without_overflow() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	k := 131072
	a := []i8{len: 4 * k, init: -128}
	b := []i8{len: 4 * k, init: -128}
	got := gemm_i8_i64_cuda(dev, a, b, 4, 4, k)!
	for value in got {
		assert value == i64(k) * 16384
	}
}

fn test_gemm_i8_i64_cuda_handles_empty_shapes_without_device_access() ! {
	dev := &cuda.CudaDevice{}
	assert gemm_i8_i64_cuda(dev, [], [], 2, 3, 0)! == []i64{len: 6}
	assert gemm_i8_i64_cuda(dev, [], []i8{len: 12}, 0, 3, 4)! == []i64{}
	if _ := upload_i8_matrix_cuda(dev, [], 2, 2) {
		assert false, 'expected mismatched uploaded matrix length to fail before device access'
	}
	if _ := gemm_i8_i64_cuda(dev, [], [], -1, 1, 1) {
		assert false, 'expected negative dimensions to fail'
	}
	if _ := gemm_i8_i64_cuda(dev, [i8(1)], [], 1, 1, 2) {
		assert false, 'expected mismatched input length to fail'
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

fn test_layernorm_cuda_reports_and_uses_cpu_fallback_without_gpu_kernel() ! {
	dev := &cuda.CudaDevice{}
	assert !layernorm_cuda_gpu_available(dev)
	backend := new_cuda_backend_with_device(dev)
	assert !backend.supports('layernorm')

	x := [1.0, 2.0, 3.0, 4.0]
	gamma := [1.0, 0.5, 2.0, -1.0]
	beta := [0.0, 1.0, -1.0, 2.0]
	assert layernorm_cuda(dev, x, gamma, beta)! == layernorm_cpu_f64(x, gamma, beta)!
}

fn test_layernorm_cuda_rejects_invalid_shapes_before_fallback() {
	dev := &cuda.CudaDevice{}
	if _ := layernorm_cuda(dev, [], [], []) {
		assert false, 'expected empty input to fail'
	}
	if _ := layernorm_cuda(dev, [1.0, 2.0], [1.0], [0.0, 0.0]) {
		assert false, 'expected affine parameter mismatch to fail'
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
	gpu := conv2d_cuda(dev, input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1) or { return }
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

fn cpu_gemm_i8_i64(a []i8, b []i8, m int, n int, k int) []i64 {
	mut c := []i64{len: m * n}
	for row in 0 .. m {
		for col in 0 .. n {
			mut sum := i64(0)
			for inner in 0 .. k {
				sum += i64(a[row * k + inner]) * i64(b[inner * n + col])
			}
			c[row * n + col] = sum
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
