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
	mut simd_checksum := 0.0
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		simd_checksum += float64.dot_unitary(x, y)
	}
	simd_ns := time.sys_mono_now() - started
	println('vector length: ${vector_size}, iterations: ${iterations}')
	println('scalar dot: ${f64(scalar_ns) / iterations / 1e6:.3f} ms')
	println('SIMD dot:   ${f64(simd_ns) / iterations / 1e6:.3f} ms')
	println('speedup:    ${f64(scalar_ns) / f64(simd_ns):.2f}x')
	println('checksums: scalar=${scalar_checksum:.6f}, SIMD=${simd_checksum:.6f}')
}
