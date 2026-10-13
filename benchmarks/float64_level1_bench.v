module main

import time
import vsl.float.float64

const vector_size = 1_048_576
const iterations = 40

@[direct_array_access]
fn scalar_dot(x []f64, y []f64) f64 {
	mut sum := 0.0
	for i in 0 .. x.len {
		sum += x[i] * y[i]
	}
	return sum
}

fn main() {
	mut x := []f64{len: vector_size}
	mut y := []f64{len: vector_size}
	for i in 0 .. vector_size {
		x[i] = f64(i % 97) * 0.001
		y[i] = f64(i % 89) * 0.002
	}
	for _ in 0 .. 3 {
		scalar_dot(x, y)
		float64.dot_unitary(x, y)
	}
	mut scalar_checksum := 0.0
	mut started := time.sys_mono_now()
	for _ in 0 .. iterations {
		scalar_checksum += scalar_dot(x, y)
	}
	scalar_ns := time.sys_mono_now() - started
	mut dot_checksum := 0.0
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		dot_checksum += float64.dot_unitary(x, y)
	}
	dot_ns := time.sys_mono_now() - started
	println('vector length: ${vector_size}, iterations: ${iterations}')
	println('scalar dot: ${f64(scalar_ns) / iterations / 1e6:.3f} ms')
	println('dot_unitary: ${f64(dot_ns) / iterations / 1e6:.3f} ms')
	println('speedup:     ${f64(scalar_ns) / f64(dot_ns):.2f}x')
	println('checksums: scalar=${scalar_checksum:.6f}, dot_unitary=${dot_checksum:.6f}')

	mut axpy_y := y.clone()
	mut axpy_checksum := 0.0
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		float64.axpy_unitary(1.5, x, mut axpy_y)
		axpy_checksum += axpy_y[vector_size - 1]
	}
	axpy_ns := time.sys_mono_now() - started
	println('axpy_unitary: ${f64(axpy_ns) / iterations / 1e6:.3f} ms (checksum ${axpy_checksum:.6f})')

	mut scal_x := x.clone()
	mut scal_checksum := 0.0
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		float64.scal_unitary(1.0001, mut scal_x)
		scal_checksum += scal_x[vector_size - 1]
	}
	scal_ns := time.sys_mono_now() - started
	println('scal_unitary: ${f64(scal_ns) / iterations / 1e6:.3f} ms (checksum ${scal_checksum:.6f})')
}
