module main

import vsl.benchmarks.util as benchmark_util
import vsl.blas
import vsl.util

fn main() {
	backend := $if vsl_blas_cblas {
		'CBLAS'
	} $else $if vsl_blas_generic_cblas {
		'generic CBLAS'
	} $else {
		'Pure V'
	}
	benchmark_util.print_header('BLAS GEMM Performance Benchmark (${backend})')
	println('\nSelected backend: ${backend}\n')

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

		mut timer := benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			mut c_warmup := benchmark_util.random_matrix(m, n)
			mut c_warmup_flat := util.flatten_row_major(c_warmup)
			blas.dgemm(.no_trans, .no_trans, m, n, k, alpha, a_flat, k, b_flat, n, beta, mut
				c_warmup_flat, n)
		}
		for _ in 0 .. config.iterations {
			mut c := benchmark_util.random_matrix(m, n)
			mut c_flat := util.flatten_row_major(c)
			started_at := timer.start()
			blas.dgemm(.no_trans, .no_trans, m, n, k, alpha, a_flat, k, b_flat, n, beta, mut
				c_flat, n)
			timer.record(started_at)
		}
		avg_time := timer.mean_ns(config.iterations)
		gflops := benchmark_util.calculate_gflops_gemm(m, n, k, avg_time)

		benchmark_util.print_result('dgemm (${backend})', '${m}x${n}x${k}', avg_time,
			'${gflops:.2f} GFLOPS')
	}

	println('\n${'='.repeat(80)}')
	println('Performance Summary:')
	println('  Selected backend: ${backend}')
	println('  Build each backend separately to compare results under identical conditions')
	println('${'='.repeat(80)}')
}
