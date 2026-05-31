// VSL GEMM benchmark (vsl.la). Run: v run vsl/benchmarks/vs_numpy/matmul_bench.v
module main

import time
import vsl.la as vsl_la
import vsl.benchmarks.util as bu

fn main() {
	bu.print_header('VSL matmul benchmark (vsl.la GEMM, f64)')
	config := bu.BenchmarkConfig{
		sizes:       [128, 256, 512, 1024]
		iterations:  5
		warmup_runs: 2
	}
	bu.print_vs_numpy_table_header()
	for n in config.sizes {
		bench_matmul(n, config)
	}
	println('\nNumPy baseline: see benchmarks/vs_numpy/README.md')
}

fn bench_matmul(n int, config bu.BenchmarkConfig) {
	mut a := vsl_la.Matrix.new[f64](n, n)
	mut b := vsl_la.Matrix.new[f64](n, n)
	mut c := vsl_la.Matrix.new[f64](n, n)
	for i in 0 .. n {
		for j in 0 .. n {
			a.set(i, j, f64((i + j) % 7) * 0.01)
			b.set(i, j, f64((i * j) % 5) * 0.02)
		}
	}

	for _ in 0 .. config.warmup_runs {
		vsl_la.matrix_matrix_mul(mut c, 1.0, a, b)
	}

	mut samples := []f64{len: config.iterations}
	for i in 0 .. config.iterations {
		t0 := time.ticks()
		vsl_la.matrix_matrix_mul(mut c, 1.0, a, b)
		samples[i] = f64(time.ticks() - t0)
	}
	avg := bu.mean_time_ms(mut samples)
	gflops := bu.gflops_gemm_ms(n, n, n, avg)
	bu.print_vs_numpy_row('gemm', '${n}x${n}', avg, '${gflops}')
}
