module main

import time
import vsl.blas

const n = 512
const warmup_count = 3
const iteration_count = 31

fn main() {
	mut a := []f32{len: n * n}
	mut b := []f32{len: n * n}
	for i in 0 .. n * n {
		a[i] = f32((i * 17) % 101) / 101.0
		b[i] = f32((i * 13) % 97) / 97.0
	}
	mut c := []f32{len: n * n}
	for _ in 0 .. warmup_count {
		blas.sgemm(.no_trans, .no_trans, n, n, n, 1, a, n, b, n, 0, mut c, n)
	}
	mut samples := []f64{cap: iteration_count}
	for _ in 0 .. iteration_count {
		started := time.sys_mono_now()
		blas.sgemm(.no_trans, .no_trans, n, n, n, 1, a, n, b, n, 0, mut c, n)
		samples << f64(time.sys_mono_now() - started) / 1_000_000.0
	}
	samples.sort()
	backend := $if vsl_blas_cblas {
		'OpenBLAS CBLAS'
	} $else $if vsl_blas_generic_cblas {
		'generic system CBLAS'
	} $else {
		'pure-V SIMD'
	}
	mut checksum := 0.0
	for value in c {
		checksum += f64(value)
	}
	println('VSL ${backend} f32 SGEMM ${n}x${n} median=${samples[iteration_count / 2]:.3f} ms checksum=${checksum:.6f}')
}
