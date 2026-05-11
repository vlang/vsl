module compute

// gemv.v — GPU-accelerated GEMV (General Matrix-Vector Multiply) via OpenCL.
//
// Computes y = A * x where A is [m x k] column-major, x is [k], y is [m].

import vsl.vcl

const gemv_kernel_source = '
__kernel void gemv(
    __global const double* A,
    __global const double* x,
    __global double* y,
    const int m,
    const int k
) {
    int row = get_global_id(0);
    if (row >= m) return;
    double sum = 0.0;
    for (int i = 0; i < k; i++) {
        // column-major: A[row + i*m]
        sum += A[row + i * m] * x[i];
    }
    y[row] = sum;
}
'

// gemv_vcl computes y = A * x on the OpenCL device (column-major, f64).
pub fn gemv_vcl(mut dev vcl.Device, a_data []f64, x_data []f64, m int, k int) ![]f64 {
	dev.add_program(gemv_kernel_source)!

	mut a_vec := dev.vector[f64](a_data.len)!
	err_a := <-a_vec.load(a_data)
	if err_a !is none {
		return err_a
	}
	mut x_vec := dev.vector[f64](x_data.len)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut y_vec := dev.vector[f64](m)!

	kernel := dev.kernel('gemv')!
	err_k := <-kernel.global(m).local(local_size_1d).run(a_vec, x_vec, y_vec, m, k)
	if err_k !is none {
		return err_k
	}

	mut out := []f64{len: m}
	err_out := <-y_vec.data(mut out)
	if err_out !is none {
		return err_out
	}
	return out
}
