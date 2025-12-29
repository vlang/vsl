module main

import benchmark
import vsl.benchmarks.util as benchmark_util
import vsl.lapack
import math

fn main() {
	benchmark_util.print_header('LAPACK Performance Benchmarks (Pure V)')

	// Benchmark configuration
	config := benchmark_util.BenchmarkConfig{
		sizes:       [100, 200, 500, 1000]
		iterations:  10
		warmup_runs: 3
	}

	// Linear system solvers
	benchmark_linear_systems(config)

	// Matrix factorizations
	benchmark_factorizations(config)

	// Eigenvalue problems
	benchmark_eigenvalue(config)
}

fn benchmark_linear_systems(config benchmark_util.BenchmarkConfig) {
	benchmark_util.print_header('Linear System Solvers')
	benchmark_util.print_table_header()

	for size in config.sizes {
		n := size

		// dgesv - solve general linear system
		a := benchmark_util.random_matrix_colmajor(n, n)
		b := benchmark_util.random_vector(n)
		mut ipiv := []int{len: n}

		mut bench := benchmark.new_benchmark()
		for _ in 0 .. config.warmup_runs {
			mut a_warmup := benchmark_util.random_matrix_colmajor(n, n)
			mut b_warmup := benchmark_util.random_vector(n)
			mut ipiv_warmup := []int{len: n}
			lapack.dgesv(n, 1, mut a_warmup, n, mut ipiv_warmup, mut b_warmup, n)
		}
		bench.step()
		for _ in 0 .. config.iterations {
			mut a_copy := a.clone()
			mut b_copy := b.clone()
			mut ipiv_copy := ipiv.clone()
			bench.step()
			lapack.dgesv(n, 1, mut a_copy, n, mut ipiv_copy, mut b_copy, n)
			bench.stop()
		}
		mut avg_time := f64(bench.total_duration()) / f64(config.iterations)
		benchmark_util.print_result('dgesv', '${n}x${n}', avg_time, '')

		// dgetrf - LU factorization
		a_lu := benchmark_util.random_matrix_colmajor(n, n)
		mut ipiv_lu := []int{len: n}

		bench = benchmark.new_benchmark()
		for _ in 0 .. config.warmup_runs {
			mut a_warmup := benchmark_util.random_matrix_colmajor(n, n)
			mut ipiv_warmup := []int{len: n}
			lapack.dgetrf(n, n, mut a_warmup, n, mut ipiv_warmup)
		}
		bench.step()
		for _ in 0 .. config.iterations {
			mut a_copy := a_lu.clone()
			mut ipiv_copy := ipiv_lu.clone()
			bench.step()
			lapack.dgetrf(n, n, mut a_copy, n, mut ipiv_copy)
			bench.stop()
		}
		avg_time = f64(bench.total_duration()) / f64(config.iterations)
		benchmark_util.print_result('dgetrf', '${n}x${n}', avg_time, '')

		// dpotrf - Cholesky factorization (positive definite)
		a_chol := benchmark_util.random_positive_definite(n)

		bench = benchmark.new_benchmark()
		for _ in 0 .. config.warmup_runs {
			mut a_warmup := benchmark_util.random_positive_definite(n)
			lapack.dpotrf(.lower, n, mut a_warmup, n)
		}
		bench.step()
		for _ in 0 .. config.iterations {
			mut a_copy := a_chol.clone()
			bench.step()
			lapack.dpotrf(.lower, n, mut a_copy, n)
			bench.stop()
		}
		avg_time = f64(bench.total_duration()) / f64(config.iterations)
		benchmark_util.print_result('dpotrf', '${n}x${n}', avg_time, '')
	}
}

fn benchmark_factorizations(config benchmark_util.BenchmarkConfig) {
	benchmark_util.print_header('Matrix Factorizations')
	benchmark_util.print_table_header()

	for size in config.sizes {
		m := size
		n := size

		// dgeqrf - QR factorization
		a_qr := benchmark_util.random_matrix_colmajor(m, n)
		mut tau := []f64{len: math.min(m, n)}

		mut bench := benchmark.new_benchmark()
		for _ in 0 .. config.warmup_runs {
			mut a_warmup := benchmark_util.random_matrix_colmajor(m, n)
			mut tau_warmup := []f64{len: math.min(m, n)}
			lapack.dgeqrf(m, n, mut a_warmup, m, mut tau_warmup)
		}
		bench.step()
		for _ in 0 .. config.iterations {
			mut a_copy := a_qr.clone()
			mut tau_copy := tau.clone()
			bench.step()
			lapack.dgeqrf(m, n, mut a_copy, m, mut tau_copy)
			bench.stop()
		}
		mut avg_time := f64(bench.total_duration()) / f64(config.iterations)
		benchmark_util.print_result('dgeqrf', '${m}x${n}', avg_time, '')
	}
}

fn benchmark_eigenvalue(config benchmark_util.BenchmarkConfig) {
	benchmark_util.print_header('Eigenvalue Problems')
	benchmark_util.print_table_header()

	// Use smaller sizes for eigenvalue problems (more expensive)
	eigen_sizes := [50, 100, 200, 500]

	for size in eigen_sizes {
		n := size

		// dsyev - symmetric eigenvalue decomposition
		// Use public API that works with both pure V and LAPACKE backends
		a_sym := benchmark_util.random_symmetric(n)

		mut bench := benchmark.new_benchmark()
		for _ in 0 .. config.warmup_runs {
			mut a_warmup := benchmark_util.random_symmetric(n)
			mut w_warmup := []f64{len: n}
			lapack.dsyev(.ev_compute, .upper, n, mut a_warmup, n, mut w_warmup)
		}
		bench.step()
		for _ in 0 .. config.iterations {
			mut a_copy := a_sym.clone()
			mut w_copy := []f64{len: n}
			bench.step()
			lapack.dsyev(.ev_compute, .upper, n, mut a_copy, n, mut w_copy)
			bench.stop()
		}
		mut avg_time := f64(bench.total_duration()) / f64(config.iterations)
		benchmark_util.print_result('dsyev', '${n}x${n}', avg_time, '')
	}
}
