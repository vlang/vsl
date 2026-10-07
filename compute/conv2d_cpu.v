// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

// conv2d_cpu_f64 computes unpadded NCHW convolution using row-major buffers.
@[direct_array_access]
fn conv2d_cpu_f64(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	if batch < 0 || in_h <= 0 || in_w <= 0 || in_ch <= 0 || out_ch <= 0 || k_h <= 0 || k_w <= 0 {
		return error('conv2d: batch must be non-negative and dimensions must be positive')
	}
	if stride_h <= 0 || stride_w <= 0 {
		return error('conv2d: strides must be positive')
	}
	if k_h > in_h || k_w > in_w {
		return error('conv2d: kernel dimensions must not exceed input dimensions')
	}
	expected_input_len := batch * in_ch * in_h * in_w
	if input.len != expected_input_len {
		return error('conv2d: expected input len=${expected_input_len}, got ${input.len}')
	}
	expected_kernel_len := out_ch * in_ch * k_h * k_w
	if kernel.len != expected_kernel_len {
		return error('conv2d: expected kernel len=${expected_kernel_len}, got ${kernel.len}')
	}
	out_h := (in_h - k_h) / stride_h + 1
	out_w := (in_w - k_w) / stride_w + 1
	mut output := []f64{len: batch * out_ch * out_h * out_w}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for oh in 0 .. out_h {
				for ow in 0 .. out_w {
					mut sum := 0.0
					for ic in 0 .. in_ch {
						for kh in 0 .. k_h {
							for kw in 0 .. k_w {
								ih := oh * stride_h + kh
								iw := ow * stride_w + kw
								input_index := ((b * in_ch + ic) * in_h + ih) * in_w + iw
								kernel_index := ((oc * in_ch + ic) * k_h + kh) * k_w + kw
								sum += input[input_index] * kernel[kernel_index]
							}
						}
					}
					output_index := ((b * out_ch + oc) * out_h + oh) * out_w + ow
					output[output_index] = sum
				}
			}
		}
	}
	return output
}
