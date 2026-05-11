module compute

// conv2d.v — GPU-accelerated Conv2D via im2col + GEMM on OpenCL.
//
// Input:   [N, C_in, H, W] — NCHW format, row-major flat
// Filters: [C_out, C_in, KH, KW] — row-major flat
// Output:  [N, C_out, OH, OW] — row-major flat
//
// Algorithm: im2col transforms input patches into a matrix, then GEMM.
// im2col output: [C_in*KH*KW, N*OH*OW] column-major for GEMM compatibility.

import vsl.vcl

const im2col_kernel_source = '
// im2col: extract input patches into columns.
// Input NCHW row-major: x[n*C*H*W + c*H*W + h*W + w]
// Output col-major: col[ki + (n*OH*OW + oh*OW + ow) * (C*KH*KW)]
// where ki = c*KH*KW + kh*KW + kw
__kernel void im2col(
    __global const double* x,
    __global double* col,
    const int N,
    const int C,
    const int H,
    const int W,
    const int KH,
    const int KW,
    const int OH,
    const int OW,
    const int stride_h,
    const int stride_w,
    const int pad_h,
    const int pad_w
) {
    // Thread covers one output spatial location and one kernel element
    int ki  = get_global_id(0); // C*KH*KW
    int out = get_global_id(1); // N*OH*OW

    int k_total = C * KH * KW;
    int out_total = N * OH * OW;
    if (ki >= k_total || out >= out_total) return;

    int n  = out / (OH * OW);
    int rem = out % (OH * OW);
    int oh = rem / OW;
    int ow = rem % OW;

    int c  = ki / (KH * KW);
    int kr = ki % (KH * KW);
    int kh = kr / KW;
    int kw = kr % KW;

    int ih = oh * stride_h - pad_h + kh;
    int iw = ow * stride_w - pad_w + kw;

    double val = 0.0;
    if (ih >= 0 && ih < H && iw >= 0 && iw < W) {
        val = x[n * C * H * W + c * H * W + ih * W + iw];
    }
    // column-major output: row=ki, col=out
    col[ki + out * k_total] = val;
}
'

// conv2d_vcl computes 2D convolution via im2col + GEMM on the OpenCL device.
// x_data: NCHW flat row-major input.
// w_data: [C_out, C_in, KH, KW] flat row-major filters.
// Returns NCHW flat row-major output.
pub fn conv2d_vcl(mut dev vcl.Device, x_data []f64, w_data []f64, n int, c_in int, h int, w int, c_out int, kh int, kw int, stride_h int, stride_w int, pad_h int, pad_w int) ![]f64 {
	oh := (h + 2 * pad_h - kh) / stride_h + 1
	ow := (w + 2 * pad_w - kw) / stride_w + 1
	k_total := c_in * kh * kw
	out_total := n * oh * ow

	dev.add_program(im2col_kernel_source)!

	// im2col
	mut x_vec := dev.vector[f64](x_data.len)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut col_vec := dev.vector[f64](k_total * out_total)!

	im2col_k := dev.kernel('im2col')!
	err_im := <-im2col_k.global(k_total, out_total).local(local_size_2d, local_size_2d).run(x_vec,
		col_vec, n, c_in, h, w, kh, kw, oh, ow, stride_h, stride_w, pad_h, pad_w)
	if err_im !is none {
		return err_im
	}

	// Read col result for GEMM
	mut col_data := []f64{len: k_total * out_total}
	col_data = col_vec.data()!

	// Reshape w: [C_out x (C_in*KH*KW)] — already row-major; for col-major GEMM we need
	// w_col_major: column index = k_total index, row = c_out index
	// Convert w from row-major to col-major [c_out x k_total]
	mut w_col := []f64{len: c_out * k_total}
	for r in 0 .. c_out {
		for c in 0 .. k_total {
			w_col[r + c * c_out] = w_data[r * k_total + c]
		}
	}

	// GEMM: C_out x out_total = w_col [c_out x k_total] * col [k_total x out_total]
	// col_data is already column-major [k_total x out_total]
	result_flat := gemm_vcl(mut dev, w_col, col_data, c_out, out_total, k_total)!

	// result_flat is column-major [c_out x out_total]; reorder to NCHW
	// output[n, c_out, oh, ow] = result[c_out + (n*OH*OW + oh*OW + ow)*c_out]
	mut output := []f64{len: n * c_out * oh * ow}
	for ni in 0 .. n {
		for co in 0 .. c_out {
			for ohi in 0 .. oh {
				for owi in 0 .. ow {
					out_spatial := ni * oh * ow + ohi * ow + owi
					// col-major result: row=co, col=out_spatial -> co + out_spatial*c_out
					val := result_flat[co + out_spatial * c_out]
					// NCHW: ni*c_out*oh*ow + co*oh*ow + ohi*ow + owi
					output[ni * c_out * oh * ow + co * oh * ow + ohi * ow + owi] = val
				}
			}
		}
	}
	return output
}
