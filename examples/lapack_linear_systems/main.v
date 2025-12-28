module main

import vsl.lapack

fn main() {
	println('=== LAPACK Linear System Solvers Example ===\n')

	// Example 1: Solve general linear system using dgesv
	println('Example 1: Solve General Linear System (dgesv)')
	println('${'-'.repeat(60)}')

	// System: Ax = b
	// A = [[2, 1, 0],
	//      [1, 2, 1],
	//      [0, 1, 2]]
	// b = [1, 2, 3]
	// Expected solution: x ≈ [0.5, 0, 1.5]

	a_row := [
		[2.0, 1.0, 0.0],
		[1.0, 2.0, 1.0],
		[0.0, 1.0, 2.0],
	]
	b_vec := [1.0, 2.0, 3.0]

	// Convert to column-major format (required by pure V LAPACK)
	mut a_col := row_to_col_major(a_row)
	mut b_solution := b_vec.clone()
	mut ipiv := []int{len: 3}

	info := lapack.dgesv(3, 1, mut a_col, 3, mut ipiv, mut b_solution, 3)

	if info == 0 {
		println('Matrix A:')
		for row in a_row {
			println('  ${row}')
		}
		println('Right-hand side b: ${b_vec}')
		println('Solution x: ${b_solution}')
		println('Pivot indices: ${ipiv}')
	} else {
		println('Error solving system: info = ${info}')
	}

	println('\n')

	// Example 2: LU factorization using dgetrf
	println('Example 2: LU Factorization (dgetrf)')
	println('${'-'.repeat(60)}')

	a_lu_row := [
		[4.0, 3.0],
		[6.0, 3.0],
	]

	mut a_lu_col := row_to_col_major(a_lu_row)
	mut ipiv_lu := []int{len: 2}

	ok := lapack.dgetrf(2, 2, mut a_lu_col, 2, mut ipiv_lu)

	if ok != 0 {
		println('Original matrix A:')
		for row in a_lu_row {
			println('  ${row}')
		}
		println('\nLU factorization (stored in A, column-major):')
		lu_result := col_to_row_major(a_lu_col, 2, 2)
		for row in lu_result {
			println('  ${row}')
		}
		println('Pivot indices: ${ipiv_lu}')
		println('\nNote: L has unit diagonal (not stored)')
		println('      U is stored in upper triangle')
		println('      L is stored in lower triangle')
	} else {
		println('Matrix is singular')
	}

	println('\n')

	// Example 3: Cholesky factorization using dpotrf
	println('Example 3: Cholesky Factorization (dpotrf)')
	println('${'-'.repeat(60)}')

	// Positive definite matrix: A = L * L^T
	a_chol_row := [
		[4.0, 2.0],
		[2.0, 3.0],
	]

	mut a_chol_col := row_to_col_major(a_chol_row)
	info_chol := lapack.dpotrf(.lower, 2, mut a_chol_col, 2)

	if info_chol == 0 {
		println('Original matrix A (positive definite):')
		for row in a_chol_row {
			println('  ${row}')
		}
		println('\nCholesky factor L (lower triangular, column-major):')
		l_result := col_to_row_major(a_chol_col, 2, 2)
		for row in l_result {
			println('  ${row}')
		}
		println('\nVerification: L * L^T should equal A')
	} else {
		println('Error: Matrix is not positive definite (info = ${info_chol})')
	}

	println('\n=== Example Complete ===')
}

// Convert row-major matrix to column-major
fn row_to_col_major(a [][]f64) []f64 {
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

// Convert column-major matrix to row-major
fn col_to_row_major(a []f64, m int, n int) [][]f64 {
	mut result := [][]f64{len: m}
	for i in 0 .. m {
		result[i] = []f64{len: n}
		for j in 0 .. n {
			result[i][j] = a[j * m + i]
		}
	}
	return result
}
