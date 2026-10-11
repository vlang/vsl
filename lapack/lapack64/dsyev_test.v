module lapack64

import math
import vsl.blas

fn test_dsyev_dense_symmetric_eigenvalues_64() {
	n := 64
	mut a := []f64{len: n * n}
	mut trace := f64(0)
	for col in 0 .. n {
		for row in 0 .. n {
			low := math.min(row, col)
			high := math.max(row, col)
			mut value := f64((low * 13 + high * 17 + 3) % 29 - 14) / f64(4 * n)
			if row == col {
				value = f64(n) + 2.0 + f64(row) * 0.25
				trace += value
			}
			a[row + col * n] = value
		}
	}
	original := a.clone()
	mut tridiagonal := a.clone()
	mut diagonal := []f64{len: n}
	mut off_diagonal := []f64{len: n - 1}
	mut tau := []f64{len: n - 1}
	dsytd2(blas.Uplo.upper, n, mut tridiagonal, n, mut diagonal, mut off_diagonal, mut tau)
	mut reduced_trace := f64(0)
	for value in diagonal {
		reduced_trace += value
	}
	assert math.abs(reduced_trace - trace) < 1e-8, 'tridiagonal reduction did not preserve trace: ${reduced_trace} != ${trace}'
	mut eigenvalues := []f64{len: n}
	mut work := []f64{len: 3 * n - 1}
	dsyev(.ev_none, blas.Uplo.upper, n, mut a, n, mut eigenvalues, mut work, work.len)
	for i in 1 .. n {
		assert eigenvalues[i - 1] <= eigenvalues[i], 'eigenvalues must be sorted in ascending order'
	}
	mut eigenvalue_sum := f64(0)
	for value in eigenvalues {
		eigenvalue_sum += value
	}
	assert math.abs(eigenvalue_sum - trace) < 1e-8, 'eigenvalue sum does not match matrix trace'
	mut lower_matrix := original.clone()
	mut lower_eigenvalues := []f64{len: n}
	mut lower_work := []f64{len: 3 * n - 1}
	dsyev(.ev_none, blas.Uplo.lower, n, mut lower_matrix, n, mut lower_eigenvalues, mut lower_work,
		lower_work.len)
	mut lower_sum := f64(0)
	for value in lower_eigenvalues {
		lower_sum += value
	}
	assert math.abs(lower_sum - trace) < 1e-8, 'lower-triangle eigenvalue sum does not match matrix trace'
}
