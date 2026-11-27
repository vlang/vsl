module main

import math
import time
import vsl.blas
import vsl.float.float32
import vsl.float.float64

const rows = 512
const cols = 4096
const iterations = 11

fn max_diff_f32(a []f32, b []f32) f32 {
	mut diff := f32(0)
	for i, value in a {
		diff = math.max(diff, math.abs(value - b[i]))
	}
	return diff
}

fn max_diff_f64(a []f64, b []f64) f64 {
	mut diff := 0.0
	for i, value in a {
		diff = math.max(diff, math.abs(value - b[i]))
	}
	return diff
}

fn main() {
	lda := cols + 3
	mut a32 := []f32{len: rows * lda}
	mut x32 := []f32{len: cols}
	mut y32 := []f32{len: rows}
	mut a64 := []f64{len: rows * lda}
	mut x64 := []f64{len: cols}
	mut y64 := []f64{len: rows}
	for i in 0 .. rows {
		for j in 0 .. cols {
			a32[i * lda + j] = f32(((i + j) % 13) - 6) * 0.125
			a64[i * lda + j] = f64(a32[i * lda + j])
		}
	}
	for j in 0 .. cols {
		x32[j] = f32((j % 11) - 5) * 0.25
		x64[j] = f64(x32[j])
	}
	for i in 0 .. rows {
		y32[i] = f32(i % 5) * 0.5
		y64[i] = f64(y32[i])
	}
	mut x_t32 := []f32{len: rows}
	mut y_t32 := []f32{len: cols}
	mut x_t64 := []f64{len: rows}
	mut y_t64 := []f64{len: cols}
	for i in 0 .. rows {
		x_t32[i] = f32((i % 7) - 3) * 0.25
		x_t64[i] = f64(x_t32[i])
	}
	for j in 0 .. cols {
		y_t32[j] = f32(j % 5) * 0.5
		y_t64[j] = f64(y_t32[j])
	}

	mut pure_y32 := y32.clone()
	mut dispatched_y32 := y32.clone()
	float32.gemv_n(u32(rows), u32(cols), 0.5, a32, u32(lda), x32, 1, 0.25,
		mut pure_y32, 1)
	blas.sgemv(.no_trans, rows, cols, 0.5, a32, lda, x32, 1, 0.25, mut dispatched_y32, 1)
	mut started := time.sys_mono_now()
	for _ in 0 .. iterations {
		float32.gemv_n(u32(rows), u32(cols), 0.5, a32, u32(lda), x32, 1, 0.25,
			mut pure_y32, 1)
	}
	pure_sgemv_ns := time.sys_mono_now() - started
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		blas.sgemv(.no_trans, rows, cols, 0.5, a32, lda, x32, 1, 0.25, mut dispatched_y32, 1)
	}
	dispatched_sgemv_ns := time.sys_mono_now() - started

	mut pure_y64 := y64.clone()
	mut dispatched_y64 := y64.clone()
	float64.gemv_n(u32(rows), u32(cols), 0.5, a64, u32(lda), x64, 1, 0.25,
		mut pure_y64, 1)
	blas.dgemv(.no_trans, rows, cols, 0.5, a64, lda, x64, 1, 0.25, mut dispatched_y64, 1)
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		float64.gemv_n(u32(rows), u32(cols), 0.5, a64, u32(lda), x64, 1, 0.25,
			mut pure_y64, 1)
	}
	pure_dgemv_ns := time.sys_mono_now() - started
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		blas.dgemv(.no_trans, rows, cols, 0.5, a64, lda, x64, 1, 0.25, mut dispatched_y64, 1)
	}
	dispatched_dgemv_ns := time.sys_mono_now() - started

	mut pure_y_t32 := y_t32.clone()
	mut dispatched_y_t32 := y_t32.clone()
	float32.gemv_t(u32(rows), u32(cols), 0.5, a32, u32(lda), x_t32, 1, 0.25,
		mut pure_y_t32, 1)
	blas.sgemv(.trans, rows, cols, 0.5, a32, lda, x_t32, 1, 0.25, mut dispatched_y_t32, 1)
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		float32.gemv_t(u32(rows), u32(cols), 0.5, a32, u32(lda), x_t32, 1, 0.25,
			mut pure_y_t32, 1)
	}
	pure_sgemv_t_ns := time.sys_mono_now() - started
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		blas.sgemv(.trans, rows, cols, 0.5, a32, lda, x_t32, 1, 0.25,
			mut dispatched_y_t32, 1)
	}
	dispatched_sgemv_t_ns := time.sys_mono_now() - started

	mut pure_y_t64 := y_t64.clone()
	mut dispatched_y_t64 := y_t64.clone()
	float64.gemv_t(u32(rows), u32(cols), 0.5, a64, u32(lda), x_t64, 1, 0.25,
		mut pure_y_t64, 1)
	blas.dgemv(.trans, rows, cols, 0.5, a64, lda, x_t64, 1, 0.25, mut dispatched_y_t64, 1)
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		float64.gemv_t(u32(rows), u32(cols), 0.5, a64, u32(lda), x_t64, 1, 0.25,
			mut pure_y_t64, 1)
	}
	pure_dgemv_t_ns := time.sys_mono_now() - started
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		blas.dgemv(.trans, rows, cols, 0.5, a64, lda, x_t64, 1, 0.25,
			mut dispatched_y_t64, 1)
	}
	dispatched_dgemv_t_ns := time.sys_mono_now() - started

	if max_diff_f32(pure_y32, dispatched_y32) > 1e-5 {
		panic('sgemv result mismatch: max absolute difference ${max_diff_f32(pure_y32, dispatched_y32)}')
	}
	if max_diff_f64(pure_y64, dispatched_y64) > 1e-9 {
		panic('dgemv result mismatch: max absolute difference ${max_diff_f64(pure_y64, dispatched_y64)}')
	}
	if max_diff_f32(pure_y_t32, dispatched_y_t32) > 1e-5 {
		panic('transposed sgemv result mismatch: max absolute difference ${max_diff_f32(pure_y_t32, dispatched_y_t32)}')
	}
	if max_diff_f64(pure_y_t64, dispatched_y_t64) > 1e-9 {
		panic('transposed dgemv result mismatch: max absolute difference ${max_diff_f64(pure_y_t64, dispatched_y_t64)}')
	}

	println('matrix shape: ${rows}x${cols}, iterations: ${iterations}')
	println('sgemv pure-V SIMD: ${f64(pure_sgemv_ns) / iterations / 1e6:.3f} ms')
	println('sgemv dispatch:    ${f64(dispatched_sgemv_ns) / iterations / 1e6:.3f} ms')
	println('sgemv speedup:     ${f64(pure_sgemv_ns) / f64(dispatched_sgemv_ns):.2f}x')
	println('dgemv pure-V SIMD: ${f64(pure_dgemv_ns) / iterations / 1e6:.3f} ms')
	println('dgemv dispatch:    ${f64(dispatched_dgemv_ns) / iterations / 1e6:.3f} ms')
	println('dgemv speedup:     ${f64(pure_dgemv_ns) / f64(dispatched_dgemv_ns):.2f}x')
	println('trans sgemv pure-V: ${f64(pure_sgemv_t_ns) / iterations / 1e6:.3f} ms')
	println('trans sgemv dispatch: ${f64(dispatched_sgemv_t_ns) / iterations / 1e6:.3f} ms')
	println('trans sgemv speedup: ${f64(pure_sgemv_t_ns) / f64(dispatched_sgemv_t_ns):.2f}x')
	println('trans dgemv pure-V: ${f64(pure_dgemv_t_ns) / iterations / 1e6:.3f} ms')
	println('trans dgemv dispatch: ${f64(dispatched_dgemv_t_ns) / iterations / 1e6:.3f} ms')
	println('trans dgemv speedup: ${f64(pure_dgemv_t_ns) / f64(dispatched_dgemv_t_ns):.2f}x')
}
