module compute

// softmax.v — GPU-accelerated row-wise softmax via OpenCL.
//
// Input: flat column-major matrix [rows x cols].
// Computes softmax across each row: exp(x - max) / sum(exp(x - max)).

import vsl.vcl

const softmax_kernel_source = '
__kernel void softmax(
    __global const double* x,
    __global double* y,
    const int rows,
    const int cols
) {
    int row = get_global_id(0);
    if (row >= rows) return;

    // Find row max (numerically stable) — column-major: x[row + col*rows]
    double mx = x[row];
    for (int col = 1; col < cols; col++) {
        double v = x[row + col * rows];
        if (v > mx) mx = v;
    }

    // Compute exp(x - max) and sum
    double sum = 0.0;
    for (int col = 0; col < cols; col++) {
        double e = exp(x[row + col * rows] - mx);
        y[row + col * rows] = e;
        sum += e;
    }

    // Normalize
    for (int col = 0; col < cols; col++) {
        y[row + col * rows] /= sum;
    }
}
'

// softmax_vcl computes row-wise softmax on the OpenCL device (column-major, f64).
// Input shape: [rows x cols] flat column-major. Returns same shape.
pub fn softmax_vcl(mut dev vcl.Device, x_data []f64, rows int, cols int) ![]f64 {
	dev.add_program(softmax_kernel_source)!

	mut x_vec := dev.vector[f64](x_data.len)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut y_vec := dev.vector[f64](rows * cols)!

	kernel := dev.kernel('softmax')!
	err_k := <-kernel.global(rows).local(local_size_1d).run(x_vec, y_vec, rows, cols)
	if err_k !is none {
		return err_k
	}

	mut out := []f64{len: rows * cols}
	err_out := <-y_vec.data(mut out)
	if err_out !is none {
		return err_out
	}
	return out
}
