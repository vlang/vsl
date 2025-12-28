module util

import rand
import math

// Benchmark configuration
pub struct BenchmarkConfig {
pub:
	sizes       []int
	iterations  int = 10
	warmup_runs int = 3
}

// Generate random vector
pub fn random_vector(n int) []f64 {
	mut v := []f64{len: n}
	for i in 0 .. n {
		v[i] = rand.f64_in_range(-1.0, 1.0) or { 0.0 }
	}
	return v
}

// Generate random matrix (row-major)
pub fn random_matrix(m int, n int) [][]f64 {
	mut mat := [][]f64{len: m}
	for i in 0 .. m {
		mat[i] = random_vector(n)
	}
	return mat
}

// Generate random matrix flattened (column-major for LAPACK)
pub fn random_matrix_colmajor(m int, n int) []f64 {
	mut mat := []f64{len: m * n}
	for i in 0 .. m * n {
		mat[i] = rand.f64_in_range(-1.0, 1.0) or { 0.0 }
	}
	return mat
}

// Generate positive definite matrix (for Cholesky)
pub fn random_positive_definite(n int) []f64 {
	// Generate A = L * L^T where L is lower triangular
	mut l := random_matrix_colmajor(n, n)
	// Make lower triangular
	for i in 0 .. n {
		for j in i + 1 .. n {
			l[i * n + j] = 0.0
		}
		// Ensure diagonal is positive
		l[i * n + i] = math.abs(l[i * n + i]) + 1.0
	}
	// Compute A = L * L^T (simplified)
	mut a := []f64{len: n * n}
	for i in 0 .. n {
		for j in 0 .. n {
			mut sum := 0.0
			for k in 0 .. math.min(i, j) + 1 {
				sum += l[i * n + k] * l[j * n + k]
			}
			a[i * n + j] = sum
		}
	}
	return a
}

// Generate symmetric matrix
pub fn random_symmetric(n int) []f64 {
	mut a := random_matrix_colmajor(n, n)
	// Make symmetric
	for i in 0 .. n {
		for j in i + 1 .. n {
			a[j * n + i] = a[i * n + j]
		}
	}
	return a
}

// Format time in appropriate units
pub fn format_time(ns f64) string {
	if ns < 1000 {
		return '${ns:.2f} ns'
	} else if ns < 1000000 {
		return '${ns / 1000:.2f} μs'
	} else if ns < 1000000000 {
		return '${ns / 1000000:.2f} ms'
	} else {
		return '${ns / 1000000000:.2f} s'
	}
}

// Calculate GFLOPS for matrix multiplication
pub fn calculate_gflops_gemm(m int, n int, k int, time_ns f64) f64 {
	ops := f64(2 * m * n * k) // 2*m*n*k floating point operations
	time_s := time_ns / 1e9
	return ops / time_s / 1e9
}

// Calculate GFLOPS for matrix-vector multiplication
pub fn calculate_gflops_gemv(m int, n int, time_ns f64) f64 {
	ops := f64(2 * m * n) // 2*m*n floating point operations
	time_s := time_ns / 1e9
	return ops / time_s / 1e9
}

// Print benchmark header
pub fn print_header(title string) {
	println('\n${'='.repeat(80)}')
	println('  ${title}')
	println('${'='.repeat(80)}')
}

// Print benchmark result row
pub fn print_result(operation string, size string, time_ns f64, extra string) {
	time_str := format_time(time_ns)
	println('${operation:-30} | ${size:-15} | ${time_str:-15} | ${extra}')
}

// Print table header
pub fn print_table_header() {
	println('${'Operation':-30} | ${'Size':-15} | ${'Time':-15} | ${'Extra Info':-20}')
	println('${'-'.repeat(30)}-+-${'-'.repeat(15)}-+-${'-'.repeat(15)}-+-${'-'.repeat(20)}')
}
