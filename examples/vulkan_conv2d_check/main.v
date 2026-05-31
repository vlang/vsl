// Validate Vulkan conv2d (im2col + GEMM). Run: VSL_TEST_VULKAN=1 v -d vulkan run vsl/examples/vulkan_conv2d_check/main.v
module main

import math
import os
import vsl.vulkan
import vsl.vulkan.compute as vk_compute

fn main() {
	if os.getenv('VSL_TEST_VULKAN') != '1' {
		println('skip: set VSL_TEST_VULKAN=1')
		return
	}
	dev := vulkan.new_device() or {
		eprintln('skip: ${err}')
		return
	}
	defer { dev.release() or {} }

	input := [f64(1), 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	kernel := [f64(1), 0, 0, 0, 0, 1, 0, 0, 0]
	gpu := vk_compute.conv2d_vulkan(dev, input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1) or {
		panic(err)
	}
	cpu := conv2d_cpu_ref(input, kernel, 1, 4, 4, 1, 1, 3, 3, 1, 1)!
	for i in 0 .. gpu.len {
		assert math.abs(gpu[i] - cpu[i]) < 1e-2
	}
	println('vulkan conv2d OK')
}

fn conv2d_cpu_ref(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	oh := (in_h - k_h) / stride_h + 1
	ow := (in_w - k_w) / stride_w + 1
	mut out := []f64{len: batch * out_ch * oh * ow}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for oh_i in 0 .. oh {
				for ow_i in 0 .. ow {
					mut sum := 0.0
					for ic in 0 .. in_ch {
						for kr in 0 .. k_h {
							for kc in 0 .. k_w {
								ih := oh_i * stride_h + kr
								iw := ow_i * stride_w + kc
								in_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
								k_idx := ((oc * in_ch + ic) * k_h + kr) * k_w + kc
								sum += input[in_idx] * kernel[k_idx]
							}
						}
					}
					out[((b * out_ch + oc) * oh + oh_i) * ow + ow_i] = sum
				}
			}
		}
	}
	return out
}
