module compute

// layernorm.v — GPU-accelerated Layer Normalization via OpenCL.
//
// Normalizes each row: y = (x - mean) / sqrt(var + eps) * gamma + beta
// Input: flat column-major matrix [rows x cols] (normalize across cols per row).

import vsl.vcl

const layernorm_kernel_source = '
__kernel void layernorm(
    __global const double* x,
    __global const double* gamma,
    __global const double* beta,
    __global double* y,
    const int rows,
    const int cols,
    const double eps
) {
    int row = get_global_id(0);
    if (row >= rows) return;

    // Compute mean
    double mean = 0.0;
    for (int col = 0; col < cols; col++) {
        mean += x[row + col * rows];
    }
    mean /= (double)cols;

    // Compute variance
    double var = 0.0;
    for (int col = 0; col < cols; col++) {
        double diff = x[row + col * rows] - mean;
        var += diff * diff;
    }
    var /= (double)cols;
    double inv_std = 1.0 / sqrt(var + eps);

    // Normalize + scale + bias
    for (int col = 0; col < cols; col++) {
        int idx = row + col * rows;
        y[idx] = (x[idx] - mean) * inv_std * gamma[col] + beta[col];
    }
}
'

// layernorm_vcl computes layer normalization row-wise on the OpenCL device.
// gamma and beta are per-column scale and bias (len = cols).
pub fn layernorm_vcl(mut dev vcl.Device, x_data []f64, gamma_data []f64, beta_data []f64, rows int, cols int, eps f64) ![]f64 {
	dev.add_program(layernorm_kernel_source)!

	mut x_vec := dev.vector[f64](x_data.len)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut g_vec := dev.vector[f64](gamma_data.len)!
	err_g := <-g_vec.load(gamma_data)
	if err_g !is none {
		return err_g
	}
	mut b_vec := dev.vector[f64](beta_data.len)!
	err_b := <-b_vec.load(beta_data)
	if err_b !is none {
		return err_b
	}
	mut y_vec := dev.vector[f64](rows * cols)!

	kernel := dev.kernel('layernorm')!
	err_k := <-kernel.global(rows).local(local_size_1d).run(x_vec, g_vec, b_vec, y_vec,
		rows, cols, eps)
	if err_k !is none {
		return err_k
	}

	mut out := []f64{len: rows * cols}
	out = y_vec.data()!
	return out
}
