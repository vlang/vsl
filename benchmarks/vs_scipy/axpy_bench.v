module main

import math
import time
import vsl.blas

const vector_size = 1_048_576
const warmup_count = 3
const iteration_count = 31
const alpha = 1.5

fn main() {
	backend := $if vsl_blas_cblas {
		'OpenBLAS'
	} $else {
		'pure-V'
	}
	mut x := []f64{len: vector_size}
	mut initial_y := []f64{len: vector_size}
	for i in 0 .. vector_size {
		x[i] = f64(i % 127 - 63) / 256.0
		initial_y[i] = f64(i % 97 - 48) / 128.0
	}
	for _ in 0 .. warmup_count {
		mut output := initial_y.clone()
		blas.daxpy(vector_size, alpha, x, 1, mut output, 1)
	}
	mut samples := []f64{cap: iteration_count}
	mut output := initial_y.clone()
	for _ in 0 .. iteration_count {
		output = initial_y.clone()
		started := time.sys_mono_now()
		blas.daxpy(vector_size, alpha, x, 1, mut output, 1)
		samples << f64(time.sys_mono_now() - started) / 1_000_000.0
	}
	samples.sort()
	mut checksum := 0.0
	mut max_error := 0.0
	for i in 0 .. vector_size {
		checksum += output[i]
		absolute_error := math.abs(output[i] - (alpha * x[i] + initial_y[i]))
		if absolute_error > max_error {
			max_error = absolute_error
		}
	}
	println('VSL AXPY | ${backend} | f64 | n=${vector_size} | median ${samples[iteration_count / 2]:.3} ms')
	println('checksum ${checksum:.12} | max absolute error ${max_error:.3e}')
}
