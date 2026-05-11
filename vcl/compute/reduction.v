module compute

// reduction.v — GPU-accelerated reduction ops (sum, mean, max along axis) via OpenCL.
//
// Input: flat column-major matrix [rows x cols].
// axis=0: reduce over rows -> output shape [cols]
// axis=1: reduce over cols -> output shape [rows]

import vsl.vcl

const reduction_kernel_source = '
// Sum along axis=0: one thread per column, sums all rows
__kernel void sum_axis0(
    __global const double* x,
    __global double* y,
    const int rows,
    const int cols
) {
    int col = get_global_id(0);
    if (col >= cols) return;
    double s = 0.0;
    for (int row = 0; row < rows; row++) {
        s += x[row + col * rows];
    }
    y[col] = s;
}

// Sum along axis=1: one thread per row, sums all cols
__kernel void sum_axis1(
    __global const double* x,
    __global double* y,
    const int rows,
    const int cols
) {
    int row = get_global_id(0);
    if (row >= rows) return;
    double s = 0.0;
    for (int col = 0; col < cols; col++) {
        s += x[row + col * rows];
    }
    y[row] = s;
}

// Mean along axis=0
__kernel void mean_axis0(
    __global const double* x,
    __global double* y,
    const int rows,
    const int cols
) {
    int col = get_global_id(0);
    if (col >= cols) return;
    double s = 0.0;
    for (int row = 0; row < rows; row++) {
        s += x[row + col * rows];
    }
    y[col] = s / (double)rows;
}

// Mean along axis=1
__kernel void mean_axis1(
    __global const double* x,
    __global double* y,
    const int rows,
    const int cols
) {
    int row = get_global_id(0);
    if (row >= rows) return;
    double s = 0.0;
    for (int col = 0; col < cols; col++) {
        s += x[row + col * rows];
    }
    y[row] = s / (double)cols;
}

// Max along axis=0
__kernel void max_axis0(
    __global const double* x,
    __global double* y,
    const int rows,
    const int cols
) {
    int col = get_global_id(0);
    if (col >= cols) return;
    double mx = x[0 + col * rows];
    for (int row = 1; row < rows; row++) {
        double v = x[row + col * rows];
        if (v > mx) mx = v;
    }
    y[col] = mx;
}

// Max along axis=1
__kernel void max_axis1(
    __global const double* x,
    __global double* y,
    const int rows,
    const int cols
) {
    int row = get_global_id(0);
    if (row >= rows) return;
    double mx = x[row];
    for (int col = 1; col < cols; col++) {
        double v = x[row + col * rows];
        if (v > mx) mx = v;
    }
    y[row] = mx;
}
'

fn reduction_run(mut dev vcl.Device, kernel_name string, x_data []f64, rows int, cols int, out_len int) ![]f64 {
	dev.add_program(reduction_kernel_source)!
	mut x_vec := dev.vector[f64](x_data.len)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut y_vec := dev.vector[f64](out_len)!
	kernel := dev.kernel(kernel_name)!
	err_k := <-kernel.global(out_len).local(local_size_1d).run(x_vec, y_vec, rows, cols)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: out_len}
	err_out := <-y_vec.data(mut out)
	if err_out !is none {
		return err_out
	}
	return out
}

// sum_vcl computes sum along axis (0=cols result, 1=rows result).
pub fn sum_vcl(mut dev vcl.Device, x_data []f64, rows int, cols int, axis int) ![]f64 {
	kernel_name := if axis == 0 { 'sum_axis0' } else { 'sum_axis1' }
	out_len := if axis == 0 { cols } else { rows }
	return reduction_run(mut dev, kernel_name, x_data, rows, cols, out_len)
}

// mean_vcl computes mean along axis.
pub fn mean_vcl(mut dev vcl.Device, x_data []f64, rows int, cols int, axis int) ![]f64 {
	kernel_name := if axis == 0 { 'mean_axis0' } else { 'mean_axis1' }
	out_len := if axis == 0 { cols } else { rows }
	return reduction_run(mut dev, kernel_name, x_data, rows, cols, out_len)
}

// max_vcl computes max along axis.
pub fn max_vcl(mut dev vcl.Device, x_data []f64, rows int, cols int, axis int) ![]f64 {
	kernel_name := if axis == 0 { 'max_axis0' } else { 'max_axis1' }
	out_len := if axis == 0 { cols } else { rows }
	return reduction_run(mut dev, kernel_name, x_data, rows, cols, out_len)
}
