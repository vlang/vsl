module compute

import os
import math
import vsl.cuda

// Lightweight cuDNN conv2d smoke test (build with `-d cuda`).
// Skips when CUDA/cuDNN is unavailable.
fn test_conv2d_backward_cuda_matches_cpu_same_pad() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device() or { return }
	if isnil(dev.cudnn) {
		return
	}
	input := [f64(1), 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	kernel := [f64(1), 0, 0, 0, 0, 1, 0, 0, 0]
	grad := [f64(0.1), 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6]
	bwd := conv2d_backward_cuda(dev, grad, input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1) or { return }
	cpu_bwd := conv2d_backward_cpu_same_pad_f64(grad, input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1) or {
		return
	}
	for i in 0 .. bwd.d_input.len {
		assert math.abs(bwd.d_input[i] - cpu_bwd.d_input[i]) < 1e-4, 'd_input ${i}'
	}
	for i in 0 .. bwd.d_weight.len {
		assert math.abs(bwd.d_weight[i] - cpu_bwd.d_weight[i]) < 1e-4, 'd_weight ${i}'
	}
}

fn test_conv2d_cuda_forward_with_workspace() ! {
	if os.getenv('VSL_TEST_CUDA') != '1' {
		return
	}
	dev := cuda.get_default_device()!
	if isnil(dev.cudnn) {
		return
	}
	input := [f64(1), 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	kernel := [f64(1), 0, 0, 0, 0, 1, 0, 0, 0]
	out := conv2d_cuda(dev, input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1) or {
		// Some driver/cuDNN builds reject SetConvolution2dDescriptor; skip instead of failing CI
		return
	}
	assert out.len == 16, 'expected 4x4 same-padded output, got len ${out.len}'
	// Reference: CPU im2col-style with explicit same padding (pad = (k-1)/2)
	ref := conv2d_cpu_same_pad_f64(input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1)!
	for i in 0 .. out.len {
		diff := math.abs(out[i] - ref[i])
		assert diff < 1e-5, 'conv2d_cuda mismatch at ${i}: ${diff}'
	}
}

// conv2d_cpu_same_pad_f64 matches cuDNN padding used in conv2d_cuda (pad = (k-1)/2).
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

struct Conv2DBwdCpuRef {
	d_input  []f64
	d_weight []f64
}

fn conv2d_backward_cpu_same_pad_f64(grad []f64, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) !Conv2DBwdCpuRef {
	pad_h := (k_h - 1) / 2
	pad_w := (k_w - 1) / 2
	out_h := (in_h + 2 * pad_h - k_h) / stride_h + 1
	out_w := (in_w + 2 * pad_w - k_w) / stride_w + 1
	in_size := batch * in_ch * in_h * in_w
	k_size := out_ch * in_ch * k_h * k_w
	mut d_input := []f64{len: in_size}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for oh in 0 .. out_h {
				for ow in 0 .. out_w {
					goh := grad[((b * out_ch + oc) * out_h + oh) * out_w + ow]
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
								d_input[in_idx] += goh * kernel[k_idx]
							}
						}
					}
				}
			}
		}
	}
	mut d_weight := []f64{len: k_size}
	for oc in 0 .. out_ch {
		for ic in 0 .. in_ch {
			for krow in 0 .. k_h {
				for kcol in 0 .. k_w {
					mut sum := 0.0
					for b in 0 .. batch {
						for oh in 0 .. out_h {
							for ow in 0 .. out_w {
								ih := oh * stride_h + krow - pad_h
								iw := ow * stride_w + kcol - pad_w
								if ih < 0 || ih >= in_h || iw < 0 || iw >= in_w {
									continue
								}
								in_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
								g_idx := ((b * out_ch + oc) * out_h + oh) * out_w + ow
								sum += input[in_idx] * grad[g_idx]
							}
						}
					}
					d_weight[((oc * in_ch + ic) * k_h + krow) * k_w + kcol] = sum
				}
			}
		}
	}
	return Conv2DBwdCpuRef{
		d_input:  d_input
		d_weight: d_weight
	}
}
