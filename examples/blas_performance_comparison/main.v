module main

import benchmark
import vsl.blas
import rand

fn main() {
	println('=== BLAS Performance Comparison Example ===\n')
	println('This example demonstrates performance characteristics of pure V BLAS')
	println('Run with -d vsl_blas_cblas to compare with C backend\n')

	// Test different problem sizes
	sizes := [100, 500, 1000]
	iterations := 5

	println('${'Operation':-20} | ${'Size':-15} | ${'Time (avg)':-20} | ${'GFLOPS':-15}')
	println('${'-'.repeat(20)}-+-${'-'.repeat(15)}-+-${'-'.repeat(20)}-+-${'-'.repeat(15)}')

	for size in sizes {
		// Level 1: Dot product
		x := random_vector(size)
		y := random_vector(size)

		mut b := benchmark.new_benchmark()
		for _ in 0 .. iterations {
			b.step()
			blas.ddot(size, x, 1, y, 1)
			b.stop()
		}
		mut avg_time := f64(b.total_duration()) / f64(iterations)
		println('${'ddot':-20} | ${'n=${size}':-15} | ${format_time(avg_time):-20} | ${'':-15}')

		// Level 2: Matrix-vector multiply
		m := size
		n := size
		a := random_matrix(m, n)
		a_flat := flatten_matrix(a)
		x_vec := random_vector(n)
		mut y_vec := random_vector(m)

		b = benchmark.new_benchmark()
		for _ in 0 .. iterations {
			y_vec = random_vector(m)
			b.step()
			blas.dgemv(.no_trans, m, n, 1.0, a_flat, n, x_vec, 1, 0.0, mut y_vec, 1)
			b.stop()
		}
		avg_time = f64(b.total_duration()) / f64(iterations)
		mut gflops := calculate_gflops_gemv(m, n, avg_time)
		println('${'dgemv':-20} | ${'${m}x${n}':-15} | ${format_time(avg_time):-20} | ${'${gflops:.2f}':-15}')

		// Level 3: Matrix-matrix multiply
		k := size
		a_mat := random_matrix(m, k)
		b_mat := random_matrix(k, n)
		a_flat_mat := flatten_matrix(a_mat)
		b_flat_mat := flatten_matrix(b_mat)
		mut c_flat_mat := []f64{len: m * n}

		b = benchmark.new_benchmark()
		for _ in 0 .. iterations {
			b.step()
			blas.dgemm(.no_trans, .no_trans, m, n, k, 1.0, a_flat_mat, k, b_flat_mat,
				n, 0.0, mut c_flat_mat, n)
			b.stop()
		}
		avg_time = f64(b.total_duration()) / f64(iterations)
		gflops = calculate_gflops_gemm(m, n, k, avg_time)
		println('${'dgemm':-20} | ${'${m}x${n}x${k}':-15} | ${format_time(avg_time):-20} | ${'${gflops:.2f}':-15}')
	}

	println('\n${'='.repeat(75)}')
	println('Performance Notes:')
	println('  - Pure V backend provides competitive performance')
	println('  - Use C backend (-d vsl_blas_cblas) for maximum performance when available')
	println('  - Results may vary based on hardware and compiler optimizations')
	println('${'='.repeat(75)}')
}

fn random_vector(n int) []f64 {
	mut v := []f64{len: n}
	for i in 0 .. n {
		v[i] = rand.f64_in_range(-1.0, 1.0) or { 0.0 }
	}
	return v
}

fn random_matrix(m int, n int) [][]f64 {
	mut mat := [][]f64{len: m}
	for i in 0 .. m {
		mat[i] = random_vector(n)
	}
	return mat
}

fn flatten_matrix(a [][]f64) []f64 {
	if a.len == 0 {
		return []
	}
	m := a.len
	n := a[0].len
	mut result := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			result[i * n + j] = a[i][j]
		}
	}
	return result
}

fn format_time(ns f64) string {
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

fn calculate_gflops_gemv(m int, n int, time_ns f64) f64 {
	ops := f64(2 * m * n)
	time_s := time_ns / 1e9
	return ops / time_s / 1e9
}

fn calculate_gflops_gemm(m int, n int, k int, time_ns f64) f64 {
	ops := f64(2 * m * n * k)
	time_s := time_ns / 1e9
	return ops / time_s / 1e9
}
