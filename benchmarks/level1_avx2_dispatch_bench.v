module main

import math
import time
import vsl.blas
import vsl.float.float32
import vsl.float.float64

const vector_size = 1_048_576
const iteration_count = 31

fn main() {
	mut x32 := []f32{len: vector_size}
	mut y32 := []f32{len: vector_size}
	mut x64 := []f64{len: vector_size}
	mut y64 := []f64{len: vector_size}
	for i in 0 .. vector_size {
		x32[i] = f32(i % 97) * 0.001
		y32[i] = f32(i % 89) * 0.002
		x64[i] = f64(x32[i])
		y64[i] = f64(y32[i])
	}

	for _ in 0 .. 3 {
		float32.dot_unitary(x32, y32)
		blas.sdot(vector_size, x32, 1, y32, 1)
		float64.dot_unitary(x64, y64)
		blas.ddot(vector_size, x64, 1, y64, 1)
	}

	mut pure_x32 := x32.clone()
	mut dispatched_x32 := x32.clone()
	mut pure_sdot_checksum := f32(0)
	mut started := time.sys_mono_now()
	for i in 0 .. iteration_count {
		pure_x32[i] = x32[i] + f32(i) * 0.00001
		pure_sdot_checksum += float32.dot_unitary(pure_x32, y32)
	}
	pure_sdot_ns := time.sys_mono_now() - started

	mut dispatched_sdot_checksum := f32(0)
	started = time.sys_mono_now()
	for i in 0 .. iteration_count {
		dispatched_x32[i] = x32[i] + f32(i) * 0.00001
		dispatched_sdot_checksum += blas.sdot(vector_size, dispatched_x32, 1, y32, 1)
	}
	dispatched_sdot_ns := time.sys_mono_now() - started

	mut pure_x64 := x64.clone()
	mut dispatched_x64 := x64.clone()
	mut pure_ddot_checksum := 0.0
	started = time.sys_mono_now()
	for i in 0 .. iteration_count {
		pure_x64[i] = x64[i] + f64(i) * 0.00001
		pure_ddot_checksum += float64.dot_unitary(pure_x64, y64)
	}
	pure_ddot_ns := time.sys_mono_now() - started

	mut dispatched_ddot_checksum := 0.0
	started = time.sys_mono_now()
	for i in 0 .. iteration_count {
		dispatched_x64[i] = x64[i] + f64(i) * 0.00001
		dispatched_ddot_checksum += blas.ddot(vector_size, dispatched_x64, 1, y64, 1)
	}
	dispatched_ddot_ns := time.sys_mono_now() - started

	if math.abs(f64(pure_sdot_checksum - dispatched_sdot_checksum)) > 0.01 {
		panic('sdot checksum mismatch: pure=${pure_sdot_checksum}, dispatched=${dispatched_sdot_checksum}')
	}
	if math.abs(pure_ddot_checksum - dispatched_ddot_checksum) > 1e-7 {
		panic('ddot checksum mismatch: pure=${pure_ddot_checksum}, dispatched=${dispatched_ddot_checksum}')
	}

	println('vector length: ${vector_size}, iterations: ${iteration_count}')
	println('sdot pure-V SIMD: ${f64(pure_sdot_ns) / iteration_count / 1e6:.3f} ms')
	println('sdot dispatch:    ${f64(dispatched_sdot_ns) / iteration_count / 1e6:.3f} ms')
	println('sdot speedup:     ${f64(pure_sdot_ns) / f64(dispatched_sdot_ns):.2f}x')
	println('ddot pure-V SIMD: ${f64(pure_ddot_ns) / iteration_count / 1e6:.3f} ms')
	println('ddot dispatch:    ${f64(dispatched_ddot_ns) / iteration_count / 1e6:.3f} ms')
	println('ddot speedup:     ${f64(pure_ddot_ns) / f64(dispatched_ddot_ns):.2f}x')
	println('checksums: sdot=${dispatched_sdot_checksum:.6f}, ddot=${dispatched_ddot_checksum:.6f}')
}
