module main

import vsl.blas

// Helper function to flatten 2D matrix to 1D (row-major)
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

fn main() {
	println('=== BLAS Basic Operations Example ===\n')

	// Example 1: Level 1 BLAS - Vector Operations
	println('Example 1: Level 1 BLAS - Vector Operations')
	println('${'-'.repeat(60)}')

	n := 5
	x := [1.0, 2.0, 3.0, 4.0, 5.0]
	y := [6.0, 7.0, 8.0, 9.0, 10.0]

	// Dot product
	dot := blas.ddot(n, x, 1, y, 1)
	println('Dot product (x · y): ${dot}')

	// Euclidean norm
	norm_x := blas.dnrm2(n, x, 1)
	println('Euclidean norm of x: ${norm_x:.6f}')

	// Sum of absolute values
	asum_x := blas.dasum(n, x, 1)
	println('Sum of absolute values of x: ${asum_x}')

	// Index of maximum absolute value
	imax := blas.idamax(n, x, 1)
	println('Index of maximum absolute value in x: ${imax} (value: ${x[imax]})')

	// Vector scaling: x = alpha * x
	alpha := 2.0
	mut x_scaled := x.clone()
	blas.dscal(n, alpha, mut x_scaled, 1)
	println('Scaled x (2.0 * x): ${x_scaled}')

	// Vector addition: y = alpha*x + y
	mut y_updated := y.clone()
	blas.daxpy(n, 1.5, x, 1, mut y_updated, 1)
	println('Updated y (1.5*x + y): ${y_updated}')

	println('\n')

	// Example 2: Level 2 BLAS - Matrix-Vector Operations
	println('Example 2: Level 2 BLAS - Matrix-Vector Operations')
	println('${'-'.repeat(60)}')

	m2 := 3
	n2 := 4
	a := [
		[1.0, 2.0, 3.0, 4.0],
		[5.0, 6.0, 7.0, 8.0],
		[9.0, 10.0, 11.0, 12.0],
	]
	a_flat := flatten_matrix(a)
	x_vec := [1.0, 2.0, 3.0, 4.0]
	mut y_vec := [0.0, 0.0, 0.0]

	// Matrix-vector multiplication: y = alpha*A*x + beta*y
	blas.dgemv(.no_trans, m2, n2, 1.0, a_flat, n2, x_vec, 1, 0.0, mut y_vec, 1)
	println('Matrix A:')
	for row in a {
		println('  ${row}')
	}
	println('Vector x: ${x_vec}')
	println('Result y = A*x: ${y_vec}')

	// Rank-1 update: A += alpha*x*y^T
	y_rank1 := [1.0, 2.0, 3.0]
	mut a_updated := a_flat.clone()
	blas.dger(m2, n2, 1.0, y_rank1, 1, x_vec, 1, mut a_updated, n2)
	println('\nAfter rank-1 update A += x*y^T:')
	for i in 0 .. m2 {
		row_start := i * n2
		println('  ${a_updated[row_start..row_start + n2]}')
	}

	println('\n')

	// Example 3: Level 3 BLAS - Matrix-Matrix Operations
	println('Example 3: Level 3 BLAS - Matrix-Matrix Operations')
	println('${'-'.repeat(60)}')

	// Matrix multiplication: C = alpha*A*B + beta*C
	a_mat := [
		[1.0, 2.0],
		[3.0, 4.0],
	]
	b_mat := [
		[5.0, 6.0],
		[7.0, 8.0],
	]
	mut c_mat := [
		[0.0, 0.0],
		[0.0, 0.0],
	]

	a_flat_mat := flatten_matrix(a_mat)
	b_flat_mat := flatten_matrix(b_mat)
	mut c_flat_mat := flatten_matrix(c_mat)

	blas.dgemm(.no_trans, .no_trans, 2, 2, 2, 1.0, a_flat_mat, 2, b_flat_mat, 2, 0.0, mut
		c_flat_mat, 2)

	println('Matrix A:')
	for row in a_mat {
		println('  ${row}')
	}
	println('Matrix B:')
	for row in b_mat {
		println('  ${row}')
	}
	println('Result C = A*B:')
	for i in 0 .. 2 {
		row_start := i * 2
		println('  ${c_flat_mat[row_start..row_start + 2]}')
	}

	// Symmetric rank-k update: C = alpha*A*A^T + beta*C
	n_syrk := 3
	k_syrk := 2
	a_syrk := [
		[1.0, 2.0],
		[3.0, 4.0],
		[5.0, 6.0],
	]
	mut c_syrk := [
		[1.0, 0.0, 0.0],
		[0.0, 1.0, 0.0],
		[0.0, 0.0, 1.0],
	]

	a_syrk_flat := flatten_matrix(a_syrk)
	mut c_syrk_flat := flatten_matrix(c_syrk)

	blas.dsyrk(.upper, .no_trans, n_syrk, k_syrk, 1.0, a_syrk_flat, k_syrk, 1.0, mut c_syrk_flat,
		n_syrk)

	println('\nSymmetric rank-k update C = A*A^T + C:')
	println('Matrix A (${n_syrk}x${k_syrk}):')
	for row in a_syrk {
		println('  ${row}')
	}
	println('Result C (symmetric, upper triangle):')
	for i in 0 .. n_syrk {
		row_start := i * n_syrk
		println('  ${c_syrk_flat[row_start..row_start + n_syrk]}')
	}

	println('\n=== Example Complete ===')
}
