module compute

import math
import vsl.vulkan

fn test_conv2d_vulkan_matches_nchw_reference_with_padding_and_strides() {
	mut dev := vulkan.new_device() or { return }
	defer {
		dev.release() or {}
	}

	batch := 2
	in_ch := 2
	in_h := 4
	in_w := 5
	out_ch := 3
	k_h := 2
	k_w := 2
	stride_h := 2
	stride_w := 1
	pad_h := 0
	pad_w := 1
	oh := (in_h + 2 * pad_h - k_h) / stride_h + 1
	ow := (in_w + 2 * pad_w - k_w) / stride_w + 1
	input := []f64{len: batch * in_ch * in_h * in_w, init: f64(index % 13 - 6) / 7}
	kernel := []f64{len: out_ch * in_ch * k_h * k_w, init: f64(index % 9 - 4) / 5}

	actual := conv2d_vulkan(dev, input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h, k_w,
		stride_h, stride_w, pad_h, pad_w) or { panic(err) }
	assert actual.len == batch * out_ch * oh * ow

	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for oh_i in 0 .. oh {
				for ow_i in 0 .. ow {
					mut expected := 0.0
					for ic in 0 .. in_ch {
						for kh in 0 .. k_h {
							for kw in 0 .. k_w {
								ih := oh_i * stride_h - pad_h + kh
								iw := ow_i * stride_w - pad_w + kw
								if ih >= 0 && ih < in_h && iw >= 0 && iw < in_w {
									input_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
									kernel_idx := ((oc * in_ch + ic) * k_h + kh) * k_w + kw
									expected += input[input_idx] * kernel[kernel_idx]
								}
							}
						}
					}
					output_idx := ((b * out_ch + oc) * oh + oh_i) * ow + ow_i
					assert math.abs(actual[output_idx] - expected) < 1e-3
				}
			}
		}
	}
}
