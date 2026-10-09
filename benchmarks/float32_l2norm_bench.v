module main

import math
import time
import vsl.float.float32

const vector_size = 1_048_576
const iterations = 40

// scalar_l2_norm is the scaled scalar implementation used before SIMD.
fn scalar_l2_norm(x []f32) f32 {
	mut scale := f32(0)
	mut sum_squares := f32(1)
	for value in x {
		if value == 0 {
			continue
		}
		abs_value := math.abs(value)
		if math.is_nan(f64(abs_value)) {
			return f32(math.nan())
		}
		if scale < abs_value {
			ratio := scale / abs_value
			sum_squares = 1 + sum_squares * ratio * ratio
			scale = abs_value
		} else {
			ratio := abs_value / scale
			sum_squares += ratio * ratio
		}
	}
	if math.is_inf(f64(scale), 1) {
		return f32(math.inf(1))
	}
	return scale * f32(math.sqrt(f64(sum_squares)))
}

fn main() {
	mut values := []f32{len: vector_size}
	mut reference_sum := 0.0
	for i in 0 .. vector_size {
		values[i] = f32((i % 127) - 63) * 0.125
		reference_sum += f64(values[i]) * f64(values[i])
	}
	reference := math.sqrt(reference_sum)
	for _ in 0 .. 3 {
		_ = scalar_l2_norm(values)
		_ = float32.l2_norm_unitary(values)
	}
	mut scalar_checksum := f32(0)
	mut started := time.sys_mono_now()
	for _ in 0 .. iterations {
		scalar_checksum += scalar_l2_norm(values)
	}
	scalar_ns := time.sys_mono_now() - started
	mut simd_checksum := f32(0)
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		simd_checksum += float32.l2_norm_unitary(values)
	}
	simd_ns := time.sys_mono_now() - started
	scalar_value := scalar_l2_norm(values)
	simd_value := float32.l2_norm_unitary(values)
	println('vector length: ${vector_size}, iterations: ${iterations}')
	println('scalar stable norm: ${f64(scalar_ns) / iterations / 1e6:.3f} ms')
	println('SIMD norm:          ${f64(simd_ns) / iterations / 1e6:.3f} ms')
	println('speedup:            ${f64(scalar_ns) / f64(simd_ns):.2f}x')
	println('error vs f64 reference: scalar=${f64(scalar_value) - reference:.6f}, SIMD=${f64(simd_value) - reference:.6f}')
	println('checksums: scalar=${scalar_checksum:.3f}, SIMD=${simd_checksum:.3f}')
}
