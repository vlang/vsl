// f32 dot with widened accumulation benchmark. Compile with -prod first.
module main

import time
import vsl.float.float32

const element_count = 1_048_576
const warmup_count = 3
const iteration_count = 9

fn main() {
	mut x := []f32{len: element_count}
	mut y := []f32{len: element_count}
	mut reference_f64 := 0.0
	for i in 0 .. element_count {
		x[i] = f32((i % 997) - 498) * f32(1.0 / 512.0)
		y[i] = f32((i % 991) - 495) * f32(1.0 / 1024.0)
		reference_f64 += f64(x[i] * y[i])
	}

	for _ in 0 .. warmup_count {
		float32.dot_unitary(x, y)
	}
	mut samples := []f64{len: iteration_count}
	mut checksum := f32(0)
	for i in 0 .. iteration_count {
		start := time.sys_mono_now()
		checksum = float32.dot_unitary(x, y)
		samples[i] = f64(time.sys_mono_now() - start) / 1_000_000.0
	}
	samples.sort()
	println('elements=${element_count} median_ms=${samples[samples.len / 2]:.3f} f32_dot=${checksum:.9f} f64_reference=${reference_f64:.12f} rounded_f32_reference=${f32(reference_f64):.9f}')
}
