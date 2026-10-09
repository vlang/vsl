module main

import time
import vsl.float.float32

const vector_size = 1_048_576
const iterations = 40

@[direct_array_access]
fn scalar_dot(x []f32, y []f32) f32 {
	mut sum := f32(0)
	for i in 0 .. x.len {
		sum += x[i] * y[i]
	}
	return sum
}

fn main() {
	mut x := []f32{len: vector_size}
	mut y := []f32{len: vector_size}
	mut reference_f64 := f64(0)
	for i in 0 .. vector_size {
		x[i] = f32(i % 97) * 0.001
		y[i] = f32(i % 89) * 0.002
		reference_f64 += f64(x[i]) * f64(y[i])
	}
	for _ in 0 .. 3 {
		scalar_dot(x, y)
		float32.dot_unitary(x, y)
	}
	mut scalar_checksum := f32(0)
	mut started := time.sys_mono_now()
	for _ in 0 .. iterations {
		scalar_checksum += scalar_dot(x, y)
	}
	scalar_ns := time.sys_mono_now() - started
	mut simd_checksum := f32(0)
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		simd_checksum += float32.dot_unitary(x, y)
	}
	simd_ns := time.sys_mono_now() - started
	scalar_result := scalar_dot(x, y)
	simd_result := float32.dot_unitary(x, y)
	println('vector length: ${vector_size}, iterations: ${iterations}')
	println('scalar dot: ${f64(scalar_ns) / iterations / 1e6:.3f} ms')
	println('SIMD dot:   ${f64(simd_ns) / iterations / 1e6:.3f} ms')
	println('speedup:    ${f64(scalar_ns) / f64(simd_ns):.2f}x')
	println('error vs f64 reference: scalar=${f64(scalar_result) - reference_f64:.6f}, SIMD=${f64(simd_result) - reference_f64:.6f}')
	println('checksums: scalar=${scalar_checksum:.3f}, SIMD=${simd_checksum:.3f}')
}
