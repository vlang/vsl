module compute

// broadcast.v — GPU-accelerated broadcast operations via OpenCL.
import vsl.vcl

const broadcast_kernel_source = '
__kernel void add_scalar(
    __global const double* x,
    __global double* y,
    const double scalar,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    y[i] = x[i] + scalar;
}

__kernel void mul_scalar(
    __global const double* x,
    __global double* y,
    const double scalar,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    y[i] = x[i] * scalar;
}

__kernel void add_vec(
    __global const double* a,
    __global const double* b,
    __global double* c,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    c[i] = a[i] + b[i];
}

__kernel void mul_vec(
    __global const double* a,
    __global const double* b,
    __global double* c,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    c[i] = a[i] * b[i];
}

// broadcast_bias: add bias vector (len=cols) to each row of matrix [rows x cols] (col-major)
__kernel void broadcast_bias(
    __global const double* mat,
    __global const double* bias,
    __global double* out,
    const int rows,
    const int cols
) {
    int row = get_global_id(0);
    int col = get_global_id(1);
    if (row >= rows || col >= cols) return;
    // column-major: index = row + col*rows
    int idx = row + col * rows;
    out[idx] = mat[idx] + bias[col];
}
'

// add_scalar_vcl adds a scalar to every element.
pub fn add_scalar_vcl(mut dev vcl.Device, x_data []f64, scalar f64) ![]f64 {
	dev.add_program(broadcast_kernel_source)!
	n := x_data.len
	mut x_vec := dev.vector[f64](n)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut y_vec := dev.vector[f64](n)!
	kernel := dev.kernel('add_scalar')!
	err_k := <-kernel.global(n).local(local_size_1d).run(x_vec, y_vec, scalar, n)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: n}
	out = y_vec.data()!
	return out
}

// mul_scalar_vcl multiplies every element by a scalar.
pub fn mul_scalar_vcl(mut dev vcl.Device, x_data []f64, scalar f64) ![]f64 {
	dev.add_program(broadcast_kernel_source)!
	n := x_data.len
	mut x_vec := dev.vector[f64](n)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut y_vec := dev.vector[f64](n)!
	kernel := dev.kernel('mul_scalar')!
	err_k := <-kernel.global(n).local(local_size_1d).run(x_vec, y_vec, scalar, n)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: n}
	out = y_vec.data()!
	return out
}

// add_vec_vcl adds two vectors element-wise.
pub fn add_vec_vcl(mut dev vcl.Device, a_data []f64, b_data []f64) ![]f64 {
	dev.add_program(broadcast_kernel_source)!
	n := a_data.len
	mut a_vec := dev.vector[f64](n)!
	err_a := <-a_vec.load(a_data)
	if err_a !is none {
		return err_a
	}
	mut b_vec := dev.vector[f64](n)!
	err_b := <-b_vec.load(b_data)
	if err_b !is none {
		return err_b
	}
	mut c_vec := dev.vector[f64](n)!
	kernel := dev.kernel('add_vec')!
	err_k := <-kernel.global(n).local(local_size_1d).run(a_vec, b_vec, c_vec, n)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: n}
	out = c_vec.data()!
	return out
}

// mul_vec_vcl multiplies two vectors element-wise.
pub fn mul_vec_vcl(mut dev vcl.Device, a_data []f64, b_data []f64) ![]f64 {
	dev.add_program(broadcast_kernel_source)!
	n := a_data.len
	mut a_vec := dev.vector[f64](n)!
	err_a := <-a_vec.load(a_data)
	if err_a !is none {
		return err_a
	}
	mut b_vec := dev.vector[f64](n)!
	err_b := <-b_vec.load(b_data)
	if err_b !is none {
		return err_b
	}
	mut c_vec := dev.vector[f64](n)!
	kernel := dev.kernel('mul_vec')!
	err_k := <-kernel.global(n).local(local_size_1d).run(a_vec, b_vec, c_vec, n)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: n}
	out = c_vec.data()!
	return out
}

// broadcast_bias_vcl adds a bias vector (len=cols) to each row of a column-major matrix.
pub fn broadcast_bias_vcl(mut dev vcl.Device, mat_data []f64, bias_data []f64, rows int, cols int) ![]f64 {
	dev.add_program(broadcast_kernel_source)!
	mut mat_vec := dev.vector[f64](mat_data.len)!
	err_m := <-mat_vec.load(mat_data)
	if err_m !is none {
		return err_m
	}
	mut bias_vec := dev.vector[f64](bias_data.len)!
	err_b := <-bias_vec.load(bias_data)
	if err_b !is none {
		return err_b
	}
	mut out_vec := dev.vector[f64](rows * cols)!
	kernel := dev.kernel('broadcast_bias')!
	err_k := <-kernel.global(rows, cols).local(local_size_2d, local_size_2d).run(mat_vec, bias_vec,
		out_vec, rows, cols)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: rows * cols}
	out = out_vec.data()!
	return out
}
