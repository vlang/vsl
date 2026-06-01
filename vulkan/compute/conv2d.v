module compute

import vsl.vulkan

// conv2d_vulkan: NCHW forward via im2col + GEMM (no padding; stride >= 1).
// input: [batch, in_ch, in_h, in_w], kernel: [out_ch, in_ch, k_h, k_w] row-major flat.
pub fn conv2d_vulkan(dev &vulkan.Device, input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	pad_h := 0
	pad_w := 0
	oh := (in_h + 2 * pad_h - k_h) / stride_h + 1
	ow := (in_w + 2 * pad_w - k_w) / stride_w + 1
	if oh < 1 || ow < 1 {
		return error('conv2d_vulkan: invalid output shape')
	}
	k_total := in_ch * k_h * k_w
	out_total := batch * oh * ow

	mut in_f32 := []f32{len: input.len}
	for i, v in input {
		in_f32[i] = f32(v)
	}
	in_bytes := f32_bytes(in_f32)

	n := u32(batch)
	c := u32(in_ch)
	h := u32(in_h)
	w := u32(in_w)
	kh := u32(k_h)
	kw := u32(k_w)
	out_h := u32(oh)
	out_w := u32(ow)

	col_elems := k_total * out_total
	mut src_buf := dev.buffer(vulkan.DeviceSize(in_bytes.len))!
	defer { src_buf.release() }
	mut col_buf := dev.buffer(vulkan.DeviceSize(u64(col_elems) * 4))!
	defer { col_buf.release() }

	src_buf.load(in_bytes)!
	vulkan.im2col(dev, col_buf, src_buf, n, c, h, w, kh, kw, out_h, out_w, u32(pad_h), u32(pad_w),
		u32(stride_h), u32(stride_w), 1, 1)!

	mut col_raw := []u8{len: col_elems * 4}
	col_raw = col_buf.store(mut col_raw)!
	mut col := []f32{len: col_elems}
	unsafe { C.memcpy(col.data, col_raw.data, col_elems * 4) }

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

fn f32_bytes(data []f32) []u8 {
	mut bytes := []u8{len: data.len * 4}
	unsafe { C.memcpy(bytes.data, data.data, data.len * 4) }
	return bytes
}
