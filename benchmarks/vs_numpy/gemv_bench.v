// VSL GEMV benchmark (vsl.blas dgemv). Run: v run vsl/benchmarks/vs_numpy/gemv_bench.v
module main

import time
import vsl.blas
import vsl.benchmarks.util as bu

fn main() {
	bu.print_header('VSL GEMV benchmark (blas.dgemv, f64)')
	config := bu.BenchmarkConfig{
		sizes:       [128, 256, 512, 1024]
		iterations:  5
		warmup_runs: 2
	}
	bu.print_vs_numpy_table_header()
	for n in config.sizes {
		bench_gemv(n, config)
	}
	println('\nNumPy baseline: see benchmarks/vs_numpy/README.md')
}

fn bench_gemv(n int, config bu.BenchmarkConfig) {
	m := n
	mut a := []f64{len: m * n}
	mut x := []f64{len: n}
	mut y := []f64{len: m}
	for i in 0 .. a.len {
		a[i] = f64((i % 11) + 1) * 0.01
	}
	for i in 0 .. x.len {
		x[i] = f64((i % 7) + 1) * 0.02
	}
	alpha := 1.0
	beta := 0.0

	for _ in 0 .. config.warmup_runs {
		y = []f64{len: m}
		blas.dgemv(.no_trans, m, n, alpha, a, n, x, 1, beta, mut y, 1)
	}

	mut samples := []f64{len: config.iterations}
	for i in 0 .. config.iterations {
		y = []f64{len: m}
		t0 := time.ticks()
		blas.dgemv(.no_trans, m, n, alpha, a, n, x, 1, beta, mut y, 1)
		samples[i] = f64(time.ticks() - t0)
	}
	avg := bu.mean_time_ms(mut samples)
	gflops := bu.gflops_gemv_ms(m, n, avg)
	bu.print_vs_numpy_row('gemv', '${m}x${n}', avg, '${gflops}')
}
