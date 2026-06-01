module compute

import vsl.vulkan

// Conv2DBwdFlat holds flat NCHW gradients for input and filter.
pub struct Conv2DBwdFlat {
pub:
	d_input  []f64
	d_weight []f64
}

// conv2d_backward_cpu_nchw computes Conv2D gradients on CPU (groups=1, dilation=1).
pub fn conv2d_backward_cpu_nchw(grad_out []f64, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int, pad_h int, pad_w int) !Conv2DBwdFlat {
	oh := (in_h + 2 * pad_h - k_h) / stride_h + 1
	ow := (in_w + 2 * pad_w - k_w) / stride_w + 1
	mut d_input := []f64{len: input.len}
	mut d_weight := []f64{len: kernel.len}

	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for ohi in 0 .. oh {
				for owi in 0 .. ow {
					g := grad_out[((b * out_ch + oc) * oh + ohi) * ow + owi]
					for ic in 0 .. in_ch {
						for kr in 0 .. k_h {
							for kc in 0 .. k_w {
								ih := ohi * stride_h - pad_h + kr
								iw := owi * stride_w - pad_w + kc
								if ih >= 0 && ih < in_h && iw >= 0 && iw < in_w {
									in_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
									k_idx := ((oc * in_ch + ic) * k_h + kr) * k_w + kc
									d_input[in_idx] += g * kernel[k_idx]
									d_weight[k_idx] += g * input[in_idx]
								}
							}
						}
					}
				}
			}
		}
	}
	return Conv2DBwdFlat{
		d_input:  d_input
		d_weight: d_weight
	}
}

// conv2d_backward_vulkan: GPU GEMM for d_weight; d_input on CPU (col2im via reference backward).
pub fn conv2d_backward_vulkan(dev &vulkan.Device, grad_out []f64, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int, pad_h int, pad_w int) !Conv2DBwdFlat {
	oh := (in_h + 2 * pad_h - k_h) / stride_h + 1
	ow := (in_w + 2 * pad_w - k_w) / stride_w + 1
	k_total := in_ch * k_h * k_w
	out_total := batch * oh * ow

	col := im2col_f32(dev, input, batch, in_ch, in_h, in_w, k_h, k_w, oh, ow, pad_h, pad_w,
		stride_h, stride_w)!

	mut grad_row := []f64{len: out_ch * out_total}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for ohi in 0 .. oh {
				for owi in 0 .. ow {
					spatial := b * oh * ow + ohi * ow + owi
					grad_row[oc * out_total + spatial] = grad_out[((b * out_ch + oc) * oh + ohi) * ow +
						owi]
				}
			}
		}
	}

	mut col_f64 := []f64{len: col.len}
	for i, v in col {
		col_f64[i] = f64(v)
	}
	// d_weight = grad_row [out_ch x out_total] * col [out_total x k_total]
	d_weight_row := gemm_vulkan(dev, grad_row, col_f64, out_ch, k_total, out_total)!

	cpu := conv2d_backward_cpu_nchw(grad_out, input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h,
		k_w, stride_h, stride_w, pad_h, pad_w)!
	return Conv2DBwdFlat{
		d_input:  cpu.d_input
		d_weight: d_weight_row
	}
}

// im2col_cpu_nchw returns [out_total x k_total] row-major f32 (spatial major, t = ic*kh*kw+kh*kw+kw).
pub fn im2col_cpu_nchw(input []f64, batch int, in_ch int, in_h int, in_w int, k_h int, k_w int, oh int, ow int, pad_h int, pad_w int, stride_h int, stride_w int) []f32 {
	k_total := in_ch * k_h * k_w
	out_total := batch * oh * ow
	mut col := []f32{len: k_total * out_total}
	for spatial in 0 .. out_total {
		b := spatial / (oh * ow)
		rem := spatial % (oh * ow)
		ohi := rem / ow
		owi := rem % ow
		for t in 0 .. k_total {
			ic := t / (k_h * k_w)
			kr := t % (k_h * k_w)
			kh := kr / k_w
			kw := kr % k_w
			ih := ohi * stride_h - pad_h + kh
			iw := owi * stride_w - pad_w + kw
			mut val := f32(0)
			if ih >= 0 && ih < in_h && iw >= 0 && iw < in_w {
				in_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
				val = f32(input[in_idx])
			}
			col[spatial * k_total + t] = val
		}
	}
	return col
}

// im2col_f32 returns host column matrix [out_total x k_total] row-major f32 values.
fn im2col_f32(dev &vulkan.Device, input []f64, batch int, in_ch int, in_h int, in_w int, k_h int, k_w int, oh int, ow int, pad_h int, pad_w int, stride_h int, stride_w int) ![]f32 {
	k_total := in_ch * k_h * k_w
	out_total := batch * oh * ow
	col_elems := k_total * out_total

	mut in_f32 := []f32{len: input.len}
	for i, v in input {
		in_f32[i] = f32(v)
	}
	in_bytes := f32_bytes(in_f32)

	mut src_buf := dev.buffer(vulkan.DeviceSize(in_bytes.len))!
	defer { src_buf.release() }
	mut col_buf := dev.buffer(vulkan.DeviceSize(u64(col_elems) * 4))!
	defer { col_buf.release() }

	src_buf.load(in_bytes)!
	vulkan.im2col(dev, col_buf, src_buf, u32(batch), u32(in_ch), u32(in_h), u32(in_w), u32(k_h),
		u32(k_w), u32(oh), u32(ow), u32(pad_h), u32(pad_w), u32(stride_h), u32(stride_w), 1, 1)!

	mut col_raw := []u8{len: col_elems * 4}
	col_raw = col_buf.store(mut col_raw)!
	mut col := []f32{len: col_elems}
	unsafe { C.memcpy(col.data, col_raw.data, col_elems * 4) }
	return col
}

fn f32_bytes(data []f32) []u8 {
	mut bytes := []u8{len: data.len * 4}
	unsafe { C.memcpy(bytes.data, data.data, data.len * 4) }
	return bytes
}
