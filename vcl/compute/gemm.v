module compute

// gemm.v — GPU-accelerated GEMM (General Matrix Multiply) via OpenCL.
//
// Computes C = A * B where all matrices are column-major.
// A: [m x k], B: [k x n], C: [m x n]
// Column-major layout: element (i,j) of matrix [rows x cols] is at index i + j*rows.

import vsl.vcl

const gemm_kernel_source = '
__kernel void gemm(
    __global const double* A,
    __global const double* B,
    __global double* C,
    const int m,
    const int n,
    const int k
) {
    int row = get_global_id(0); // row index of C
    int col = get_global_id(1); // col index of C
    if (row >= m || col >= n) return;
    double sum = 0.0;
    for (int i = 0; i < k; i++) {
        // column-major: A[row + i*m], B[i + col*k]
        sum += A[row + i * m] * B[i + col * k];
    }
    C[row + col * m] = sum;
}
'

const gemm_f32_kernel_source = '
__kernel void gemm_f32(
    __global const float* A,
    __global const float* B,
    __global float* C,
    const int m,
    const int n,
    const int k
) {
    int row = get_global_id(0);
    int col = get_global_id(1);
    if (row >= m || col >= n) return;
    float sum = 0.0f;
    for (int i = 0; i < k; i++) {
        sum += A[row + i * m] * B[i + col * k];
    }
    C[row + col * m] = sum;
}
'

// gemm_vcl computes C = A * B on the OpenCL device (column-major, f64).
// a_data and b_data are flat column-major arrays; returns flat column-major result.
pub fn gemm_vcl(mut dev vcl.Device, a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	dev.add_program(gemm_kernel_source)!

	mut a_vec := dev.vector[f64](a_data.len)!
	err_a := <-a_vec.load(a_data)
	if err_a !is none {
		return err_a
	}
	mut b_vec := dev.vector[f64](b_data.len)!
	err_b := <-b_vec.load(b_data)
	if err_b !is none {
		return err_b
	}
	mut c_vec := dev.vector[f64](m * n)!

	kernel := dev.kernel('gemm')!
	err_k := <-kernel.global(m, n).local(local_size_2d, local_size_2d).run(a_vec, b_vec,
		c_vec, m, n, k)
	if err_k !is none {
		return err_k
	}

	mut out := []f64{len: m * n}
	out = c_vec.data()!
	return out
}

// gemm_vcl_f32 computes C = A * B on the OpenCL device (column-major, f32).
pub fn gemm_vcl_f32(mut dev vcl.Device, a_data []f32, b_data []f32, m int, n int, k int) ![]f32 {
	dev.add_program(gemm_f32_kernel_source)!

	mut a_vec := dev.vector[f32](a_data.len)!
	err_a := <-a_vec.load(a_data)
	if err_a !is none {
		return err_a
	}
	mut b_vec := dev.vector[f32](b_data.len)!
	err_b := <-b_vec.load(b_data)
	if err_b !is none {
		return err_b
	}
	mut c_vec := dev.vector[f32](m * n)!

	kernel := dev.kernel('gemm_f32')!
	err_k := <-kernel.global(m, n).local(local_size_2d, local_size_2d).run(a_vec, b_vec,
		c_vec, m, n, k)
	if err_k !is none {
		return err_k
	}

	mut out := []f32{len: m * n}
	out = c_vec.data()!
	return out
}
