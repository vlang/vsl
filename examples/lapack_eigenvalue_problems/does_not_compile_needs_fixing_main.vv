module main

import vsl.lapack
import vsl.blas
import math

fn main() {
	println('=== LAPACK Eigenvalue Problems Example ===\n')

	// Example: Symmetric eigenvalue decomposition using dsyev
	println('Example: Symmetric Eigenvalue Decomposition (dsyev)')
	println('${'-'.repeat(60)}')

	// Symmetric matrix
	a_row := [
		[4.0, 1.0, 2.0],
		[1.0, 3.0, 0.0],
		[2.0, 0.0, 5.0],
	]

	println('Original symmetric matrix A:')
	for row in a_row {
		println('  ${row}')
	}

	// Convert to column-major
	mut a_col := row_to_col_major(a_row)
	n := 3

	// Query workspace size
	mut w := []f64{len: n}
	mut work := []f64{len: 1}
	mut lwork := -1

	lapack.dsyev(.ev_compute, .upper, n, mut a_col.clone(), n, mut w, mut work, lwork)
	lwork = int(work[0])
	work = []f64{len: lwork}

	// Compute eigenvalues and eigenvectors
	lapack.dsyev(.ev_compute, .upper, n, mut a_col, n, mut w, mut work, lwork)

	println('\nEigenvalues (in ascending order):')
	for i, eigenval in w {
		println('  λ${i + 1} = ${eigenval:.6f}')
	}

	println('\nEigenvectors (columns, column-major format):')
	eigenvecs := col_to_row_major(a_col, n, n)
	for i in 0 .. n {
		println('  v${i + 1} = ${eigenvecs[i]}')
	}

	// Verify: A * v = λ * v
	println('\nVerification (A * v ≈ λ * v):')
	for i in 0 .. n {
		// Extract eigenvector
		mut v := []f64{len: n}
		for j in 0 .. n {
			v[j] = eigenvecs[j][i]
		}

		// Compute A * v
		a_flat := row_to_col_major(a_row)
		mut av := []f64{len: n}
		blas.dgemv(.no_trans, n, n, 1.0, a_flat, n, v, 1, 0.0, mut av, 1)

		// Compute λ * v
		mut lambda_v := []f64{len: n}
		blas.dscal(n, w[i], mut lambda_v, 1)
		blas.dcopy(n, v, 1, mut lambda_v, 1)
		blas.dscal(n, w[i], mut lambda_v, 1)

		println('  For eigenvalue λ${i + 1} = ${w[i]:.6f}:')
		println('    A * v${i + 1} = ${av}')
		println('    λ${i + 1} * v${i + 1} = ${lambda_v}')

		// Check if they're approximately equal
		mut max_diff := 0.0
		for j in 0 .. n {
			diff := math.abs(av[j] - lambda_v[j])
			if diff > max_diff {
				max_diff = diff
			}
		}
		println('    Max difference: ${max_diff:.2e}')
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
