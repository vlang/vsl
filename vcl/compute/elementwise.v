module compute

// elementwise.v — GPU-accelerated element-wise activation functions via OpenCL.
//
// All functions operate on flat f64 arrays and return flat f64 arrays.

import vsl.vcl

const elementwise_kernel_source = '
#define GELU_COEFF 0.7978845608028654

__kernel void relu(
    __global const double* x,
    __global double* y,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    y[i] = x[i] > 0.0 ? x[i] : 0.0;
}

__kernel void sigmoid(
    __global const double* x,
    __global double* y,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    y[i] = 1.0 / (1.0 + exp(-x[i]));
}

__kernel void tanh_act(
    __global const double* x,
    __global double* y,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    y[i] = tanh(x[i]);
}

__kernel void gelu(
    __global const double* x,
    __global double* y,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    double v = x[i];
    double inner = GELU_COEFF * (v + 0.044715 * v * v * v);
    y[i] = 0.5 * v * (1.0 + tanh(inner));
}

__kernel void leaky_relu(
    __global const double* x,
    __global double* y,
    const double alpha,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    y[i] = x[i] >= 0.0 ? x[i] : alpha * x[i];
}

__kernel void elu(
    __global const double* x,
    __global double* y,
    const double alpha,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;
    y[i] = x[i] >= 0.0 ? x[i] : alpha * (exp(x[i]) - 1.0);
}
'

fn run_simple_elementwise(mut dev vcl.Device, kernel_name string, x_data []f64) ![]f64 {
	dev.add_program(elementwise_kernel_source)!
	n := x_data.len
	mut x_vec := dev.vector[f64](n)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut y_vec := dev.vector[f64](n)!
	kernel := dev.kernel(kernel_name)!
	err_k := <-kernel.global(n).local(local_size_1d).run(x_vec, y_vec, n)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: n}
	out = y_vec.data()!
	return out
}

fn run_alpha_elementwise(mut dev vcl.Device, kernel_name string, x_data []f64, alpha f64) ![]f64 {
	dev.add_program(elementwise_kernel_source)!
	n := x_data.len
	mut x_vec := dev.vector[f64](n)!
	err_x := <-x_vec.load(x_data)
	if err_x !is none {
		return err_x
	}
	mut y_vec := dev.vector[f64](n)!
	kernel := dev.kernel(kernel_name)!
	err_k := <-kernel.global(n).local(local_size_1d).run(x_vec, y_vec, alpha, n)
	if err_k !is none {
		return err_k
	}
	mut out := []f64{len: n}
	out = y_vec.data()!
	return out
}

// relu_vcl applies ReLU element-wise on the OpenCL device.
pub fn relu_vcl(mut dev vcl.Device, x_data []f64) ![]f64 {
	return run_simple_elementwise(mut dev, 'relu', x_data)
}

// sigmoid_vcl applies Sigmoid element-wise on the OpenCL device.
pub fn sigmoid_vcl(mut dev vcl.Device, x_data []f64) ![]f64 {
	return run_simple_elementwise(mut dev, 'sigmoid', x_data)
}

// tanh_vcl applies Tanh element-wise on the OpenCL device.
pub fn tanh_vcl(mut dev vcl.Device, x_data []f64) ![]f64 {
	return run_simple_elementwise(mut dev, 'tanh_act', x_data)
}

// gelu_vcl applies GELU element-wise on the OpenCL device.
pub fn gelu_vcl(mut dev vcl.Device, x_data []f64) ![]f64 {
	return run_simple_elementwise(mut dev, 'gelu', x_data)
}

// leaky_relu_vcl applies LeakyReLU element-wise on the OpenCL device.
pub fn leaky_relu_vcl(mut dev vcl.Device, x_data []f64, alpha f64) ![]f64 {
	return run_alpha_elementwise(mut dev, 'leaky_relu', x_data, alpha)
}

// elu_vcl applies ELU element-wise on the OpenCL device.
pub fn elu_vcl(mut dev vcl.Device, x_data []f64, alpha f64) ![]f64 {
	return run_alpha_elementwise(mut dev, 'elu', x_data, alpha)
}
