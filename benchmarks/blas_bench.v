module main

import vsl.benchmarks.util as benchmark_util
import vsl.blas
import vsl.util

const level1_batch_repetitions = 100

fn main() {
	backend := $if vsl_blas_cblas {
		'CBLAS'
	} $else $if vsl_blas_generic_cblas {
		'generic CBLAS'
	} $else {
		'Pure V'
	}
	benchmark_util.print_header('BLAS Performance Benchmarks (${backend})')

	// Benchmark configuration
	config := benchmark_util.BenchmarkConfig{
		sizes:       [100, 500, 1000, 2000]
		iterations:  10
		warmup_runs: 3
	}

	// Level 1 BLAS benchmarks
	benchmark_level1(config)

	// Level 2 BLAS benchmarks
	benchmark_level2(config)

	// Level 3 BLAS benchmarks
	benchmark_level3(config)
}

fn benchmark_level1(config benchmark_util.BenchmarkConfig) {
	benchmark_util.print_header('Level 1 BLAS - Vector Operations')
	benchmark_util.print_table_header()

	for size in config.sizes {
		x := benchmark_util.random_vector(size)
		y := benchmark_util.random_vector(size)

		// ddot - dot product
		mut timer := benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			blas.ddot(size, x, 1, y, 1)
		}
		mut checksum := 0.0
		for _ in 0 .. config.iterations {
			started_at := timer.start()
			mut batch_checksum := 0.0
			for _ in 0 .. level1_batch_repetitions {
				batch_checksum += blas.ddot(size, x, 1, y, 1)
			}
			timer.record(started_at)
			checksum += batch_checksum
		}
		mut avg_time := timer.mean_ns(config.iterations * level1_batch_repetitions)
		benchmark_util.print_result('ddot', 'n=${size}', avg_time, 'checksum=${checksum}')

		// dnrm2 - Euclidean norm
		timer = benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			blas.dnrm2(size, x, 1)
		}
		checksum = 0.0
		for _ in 0 .. config.iterations {
			started_at := timer.start()
			mut batch_checksum := 0.0
			for _ in 0 .. level1_batch_repetitions {
				batch_checksum += blas.dnrm2(size, x, 1)
			}
			timer.record(started_at)
			checksum += batch_checksum
		}
		avg_time = timer.mean_ns(config.iterations * level1_batch_repetitions)
		benchmark_util.print_result('dnrm2', 'n=${size}', avg_time, 'checksum=${checksum}')

		// dasum - sum of absolute values
		timer = benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			blas.dasum(size, x, 1)
		}
		checksum = 0.0
		for _ in 0 .. config.iterations {
			started_at := timer.start()
			mut batch_checksum := 0.0
			for _ in 0 .. level1_batch_repetitions {
				batch_checksum += blas.dasum(size, x, 1)
			}
			timer.record(started_at)
			checksum += batch_checksum
		}
		avg_time = timer.mean_ns(config.iterations * level1_batch_repetitions)
		benchmark_util.print_result('dasum', 'n=${size}', avg_time, 'checksum=${checksum}')

		// daxpy - y = alpha*x + y
		mut y_copy := y.clone()
		alpha := 1.5
		timer = benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			mut y_warmup := y.clone()
			blas.daxpy(size, alpha, x, 1, mut y_warmup, 1)
		}
		for _ in 0 .. config.iterations {
			y_copy = y.clone()
			started_at := timer.start()
			blas.daxpy(size, alpha, x, 1, mut y_copy, 1)
			timer.record(started_at)
		}
		avg_time = timer.mean_ns(config.iterations)
		benchmark_util.print_result('daxpy', 'n=${size}', avg_time, '')

		// dscal - x = alpha*x
		mut x_copy := x.clone()
		timer = benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			mut x_warmup := x.clone()
			blas.dscal(size, alpha, mut x_warmup, 1)
		}
		for _ in 0 .. config.iterations {
			x_copy = x.clone()
			started_at := timer.start()
			blas.dscal(size, alpha, mut x_copy, 1)
			timer.record(started_at)
		}
		avg_time = timer.mean_ns(config.iterations)
		benchmark_util.print_result('dscal', 'n=${size}', avg_time, '')

		// idamax - index of maximum absolute value
		timer = benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			blas.idamax(size, x, 1)
		}
		checksum = 0.0
		for _ in 0 .. config.iterations {
			started_at := timer.start()
			mut batch_checksum := 0.0
			for _ in 0 .. level1_batch_repetitions {
				batch_checksum += f64(blas.idamax(size, x, 1))
			}
			timer.record(started_at)
			checksum += batch_checksum
		}
		avg_time = timer.mean_ns(config.iterations * level1_batch_repetitions)
		benchmark_util.print_result('idamax', 'n=${size}', avg_time, 'checksum=${checksum}')
	}
}

fn benchmark_level2(config benchmark_util.BenchmarkConfig) {
	benchmark_util.print_header('Level 2 BLAS - Matrix-Vector Operations')
	benchmark_util.print_table_header()

	for size in config.sizes {
		m := size
		n := size
		a := benchmark_util.random_matrix(m, n)
		a_flat := util.flatten_row_major(a)
		x := benchmark_util.random_vector(n)
		mut y := benchmark_util.random_vector(m)
		alpha := 1.0
		beta := 0.0

		// dgemv - general matrix-vector multiply
		mut timer := benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			mut y_warmup := benchmark_util.random_vector(m)
			blas.dgemv(.no_trans, m, n, alpha, a_flat, n, x, 1, beta, mut y_warmup, 1)
		}
		for _ in 0 .. config.iterations {
			y = benchmark_util.random_vector(m)
			started_at := timer.start()
			blas.dgemv(.no_trans, m, n, alpha, a_flat, n, x, 1, beta, mut y, 1)
			timer.record(started_at)
		}
		mut avg_time := timer.mean_ns(config.iterations)
		gflops := benchmark_util.calculate_gflops_gemv(m, n, avg_time)
		benchmark_util.print_result('dgemv', '${m}x${n}', avg_time, '${gflops:.2f} GFLOPS')

		// dger - rank-1 update A += alpha*x*y^T
		mut a_copy := a_flat.clone()
		y_vec := benchmark_util.random_vector(m)
		timer = benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			mut a_warmup := a_flat.clone()
			blas.dger(m, n, alpha, x, 1, y_vec, 1, mut a_warmup, n)
		}
		for _ in 0 .. config.iterations {
			a_copy = a_flat.clone()
			started_at := timer.start()
			blas.dger(m, n, alpha, x, 1, y_vec, 1, mut a_copy, n)
			timer.record(started_at)
		}
		avg_time = timer.mean_ns(config.iterations)
		benchmark_util.print_result('dger', '${m}x${n}', avg_time, '')
	}
}

fn benchmark_level3(config benchmark_util.BenchmarkConfig) {
	benchmark_util.print_header('Level 3 BLAS - Matrix-Matrix Operations')
	benchmark_util.print_table_header()

	// Use smaller sizes for Level 3 (more compute-intensive)
	level3_sizes := [100, 200, 500, 1000]

	for size in level3_sizes {
		m := size
		n := size
		k := size
		a := benchmark_util.random_matrix(m, k)
		b_mat := benchmark_util.random_matrix(k, n)
		a_flat := util.flatten_row_major(a)
		b_flat := util.flatten_row_major(b_mat)
		mut c := benchmark_util.random_matrix(m, n)
		mut c_flat := util.flatten_row_major(c)
		alpha := 1.0
		beta := 0.0

		// dgemm - general matrix-matrix multiply
		mut timer := benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			mut c_warmup := benchmark_util.random_matrix(m, n)
			mut c_warmup_flat := util.flatten_row_major(c_warmup)
			blas.dgemm(.no_trans, .no_trans, m, n, k, alpha, a_flat, k, b_flat, n, beta, mut
				c_warmup_flat, n)
		}
		for _ in 0 .. config.iterations {
			c_flat = util.flatten_row_major(benchmark_util.random_matrix(m, n))
			started_at := timer.start()
			blas.dgemm(.no_trans, .no_trans, m, n, k, alpha, a_flat, k, b_flat, n, beta, mut
				c_flat, n)
			timer.record(started_at)
		}
		mut avg_time := timer.mean_ns(config.iterations)
		gflops := benchmark_util.calculate_gflops_gemm(m, n, k, avg_time)
		benchmark_util.print_result('dgemm', '${m}x${n}x${k}', avg_time, '${gflops:.2f} GFLOPS')

		// dsyrk - symmetric rank-k update
		n_syrk := size
		k_syrk := size / 2
		a_syrk := benchmark_util.random_matrix(n_syrk, k_syrk)
		a_syrk_flat := util.flatten_row_major(a_syrk)
		mut c_syrk := benchmark_util.random_symmetric(n_syrk)
		timer = benchmark_util.BenchmarkTimer{}
		for _ in 0 .. config.warmup_runs {
			mut c_warmup := benchmark_util.random_symmetric(n_syrk)
			blas.dsyrk(.upper, .no_trans, n_syrk, k_syrk, alpha, a_syrk_flat, k_syrk, beta, mut
				c_warmup, n_syrk)
		}
		for _ in 0 .. config.iterations {
			c_syrk = benchmark_util.random_symmetric(n_syrk)
			started_at := timer.start()
			blas.dsyrk(.upper, .no_trans, n_syrk, k_syrk, alpha, a_syrk_flat, k_syrk, beta, mut
				c_syrk, n_syrk)
			timer.record(started_at)
		}
		avg_time = timer.mean_ns(config.iterations)
		benchmark_util.print_result('dsyrk', '${n_syrk}x${k_syrk}', avg_time, '')
	}
}
