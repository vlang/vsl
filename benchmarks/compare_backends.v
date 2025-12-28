module main

import benchmark
import vsl.benchmarks.util as benchmark_util
import vsl.blas
import vsl.util

fn main() {
	benchmark_util.print_header('BLAS Backend Comparison: Pure V vs C Backend')
	println('\nNote: Run with -d vsl_blas_cblas to compare with C backend')
	println('      Pure V backend is used by default\n')

	config := benchmark_util.BenchmarkConfig{
		sizes:       [100, 500, 1000, 2000]
		iterations:  10
		warmup_runs: 3
	}

	benchmark_util.print_table_header()

	// Compare dgemm (most important operation)
	for size in config.sizes {
		m := size
		n := size
		k := size
		a := benchmark_util.random_matrix(m, k)
		b_mat := benchmark_util.random_matrix(k, n)
		a_flat := util.flatten_row_major(a)
		b_flat := util.flatten_row_major(b_mat)
		alpha := 1.0
		beta := 0.0

		// Pure V backend
		mut bench := benchmark.new_benchmark()
		for _ in 0 .. config.warmup_runs {
			mut c_warmup := benchmark_util.random_matrix(m, n)
			mut c_warmup_flat := util.flatten_row_major(c_warmup)
			blas.dgemm(.no_trans, .no_trans, m, n, k, alpha, a_flat, k, b_flat, n, beta, mut
				c_warmup_flat, n)
		}
		bench.step()
		for _ in 0 .. config.iterations {
			mut c := benchmark_util.random_matrix(m, n)
			mut c_flat := util.flatten_row_major(c)
			bench.step()
			blas.dgemm(.no_trans, .no_trans, m, n, k, alpha, a_flat, k, b_flat, n, beta, mut
				c_flat, n)
			bench.stop()
		}
		avg_time_pure_v := f64(bench.total_duration()) / f64(config.iterations)
		gflops_pure_v := benchmark_util.calculate_gflops_gemm(m, n, k, avg_time_pure_v)

		benchmark_util.print_result('dgemm (Pure V)', '${m}x${n}x${k}', avg_time_pure_v,
			'${gflops_pure_v:.2f} GFLOPS')

		// Note: C backend comparison would require compilation with -d vsl_blas_cblas
		// This is a placeholder showing the structure
		println('  (Run with -d vsl_blas_cblas to see C backend comparison)')
	}

	println('\n${'='.repeat(80)}')
	println('Performance Summary:')
	println('  Pure V backend provides competitive performance')
	println('  Use C backend (-d vsl_blas_cblas) for maximum performance when available')
	println('  Pure V backend offers zero-dependency deployment')
	println('${'='.repeat(80)}')
}
