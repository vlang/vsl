module util

import rand
import math

// Matrix utilities for VSL examples and benchmarks

// Convert row-major matrix (V's native format) to column-major (BLAS/LAPACK format)
pub fn row_to_col_major(a [][]f64) []f64 {
	if a.len == 0 {
		return []
	}
	m := a.len
	n := a[0].len
	mut result := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			result[j * m + i] = a[i][j]
		}
	}
	return result
}

// Convert column-major matrix (BLAS/LAPACK format) to row-major (V's native format)
pub fn col_to_row_major(a []f64, m int, n int) [][]f64 {
	mut result := [][]f64{len: m}
	for i in 0 .. m {
		result[i] = []f64{len: n}
		for j in 0 .. n {
			result[i][j] = a[j * m + i]
		}
	}
	return result
}

// Flatten row-major matrix to 1D array (row-major order)
pub fn flatten_row_major(a [][]f64) []f64 {
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

// Generate random matrix (row-major)
pub fn random_matrix(m int, n int) [][]f64 {
	mut mat := [][]f64{len: m}
	for i in 0 .. m {
		mat[i] = []f64{len: n}
		for j in 0 .. n {
			mat[i][j] = rand.f64_in_range(-1.0, 1.0) or { 0.0 }
		}
	}
	return mat
}

// Generate random matrix (column-major, flattened)
pub fn random_matrix_colmajor(m int, n int) []f64 {
	mut mat := []f64{len: m * n}
	for i in 0 .. m * n {
		mat[i] = rand.f64_in_range(-1.0, 1.0) or { 0.0 }
	}
	return mat
}

// Generate random symmetric matrix (column-major, flattened)
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

// Generate random positive definite matrix (column-major, flattened)
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

// Print matrix (row-major)
pub fn print_matrix(a [][]f64, label string) {
	println('${label}:')
	for row in a {
		println('  ${row}')
	}
}

// Print matrix (column-major, flattened)
pub fn print_matrix_colmajor(a []f64, m int, n int, label string) {
	mat := col_to_row_major(a, m, n)
	print_matrix(mat, label)
}

// Check if two matrices are approximately equal
pub fn nearly_equal(a [][]f64, b [][]f64, tol f64) bool {
	if a.len != b.len {
		return false
	}
	for i in 0 .. a.len {
		if a[i].len != b[i].len {
			return false
		}
		for j in 0 .. a[i].len {
			diff := if a[i][j] > b[i][j] { a[i][j] - b[i][j] } else { b[i][j] - a[i][j] }
			if diff > tol {
				return false
			}
		}
	}
	return true
}
