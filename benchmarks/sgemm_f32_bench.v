module main

import time
import vsl.blas

fn main() {
	n := 512
	mut a := []f32{len: n * n}
	mut b := []f32{len: n * n}
	for i in 0 .. n * n {
		a[i] = f32((i * 17) % 101) / 101.0
		b[i] = f32((i * 13) % 97) / 97.0
	}
	for _ in 0 .. 3 {
		mut c := []f32{len: n * n}
		blas.sgemm(.no_trans, .no_trans, n, n, n, 1, a, n, b, n, 0, mut c, n)
	}
	mut total_ns := i64(0)
	mut checksum := f32(0)
	iterations := 7
	for _ in 0 .. iterations {
		mut c := []f32{len: n * n}
		started := time.sys_mono_now()
		blas.sgemm(.no_trans, .no_trans, n, n, n, 1, a, n, b, n, 0, mut c, n)
		total_ns += time.sys_mono_now() - started
		checksum = c[n * n / 2]
	}
	mean_ms := f64(total_ns) / f64(iterations) / 1_000_000.0
	println('pure-V f32 SGEMM 512x512 mean=${mean_ms:.3f} ms checksum=${checksum:.6f}')
}
