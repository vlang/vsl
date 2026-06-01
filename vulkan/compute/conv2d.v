module compute

import vsl.vulkan

// conv2d_vulkan: NCHW forward via im2col + GEMM (stride >= 1, dilation=1).
// input: [batch, in_ch, in_h, in_w], kernel: [out_ch, in_ch, k_h, k_w] row-major flat.
pub fn conv2d_vulkan(dev &vulkan.Device, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int, pad_h int, pad_w int) ![]f64 {
	oh := (in_h + 2 * pad_h - k_h) / stride_h + 1
	ow := (in_w + 2 * pad_w - k_w) / stride_w + 1
	if oh < 1 || ow < 1 {
		return error('conv2d_vulkan: invalid output shape')
	}
	k_total := in_ch * k_h * k_w
	out_total := batch * oh * ow

	col := im2col_f32(dev, input, batch, in_ch, in_h, in_w, k_h, k_w, oh, ow, pad_h, pad_w,
		stride_h, stride_w)!

	// Weight matrix [out_ch x k_total] row-major for GEMM
	mut w_row := []f64{len: out_ch * k_total}
	if kernel.len != w_row.len {
		return error('conv2d_vulkan: kernel len ${kernel.len} != ${w_row.len}')
	}
	for i, v in kernel {
		w_row[i] = v
	}

	// im2col buffer is [out_total x k_total] row-major (see vulkan.im2col); GEMM needs [k_total x out_total].
	mut col_row := []f64{len: col.len}
	for spatial in 0 .. out_total {
		for t in 0 .. k_total {
			col_row[t * out_total + spatial] = f64(col[spatial * k_total + t])
		}
	}

	gemm_out := gemm_vulkan(dev, w_row, col_row, out_ch, out_total, k_total)!

	// GEMM output row-major [out_ch x out_total] → NCHW
	mut output := []f64{len: batch * out_ch * oh * ow}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for ohi in 0 .. oh {
				for owi in 0 .. ow {
					spatial := b * oh * ow + ohi * ow + owi
					out_idx := b * out_ch * oh * ow + oc * oh * ow + ohi * ow + owi
					gemm_idx := oc * out_total + spatial
					output[out_idx] = gemm_out[gemm_idx]
				}
			}
		}
	}
	return output
}

// conv2d_cpu_nchw is the CPU reference (no padding).
pub fn conv2d_cpu_nchw(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
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
