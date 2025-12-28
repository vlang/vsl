module lapack64

import math
// Note: lapack64 is pure V; no LAPACKE here.

fn test_dpotrf_basic() {
	// Test with a simple symmetric positive definite matrix
	// Original matrix (row-major view):
	// [4  2  1]
	// [2  3  1]
	// [1  1  2]

	// Pure V backend: use column-major format
	// Stored in column-major: [4, 2, 1, 2, 3, 1, 1, 1, 2]
	// Which is: column 0: [4, 2, 1], column 1: [2, 3, 1], column 2: [1, 1, 2]
	mut a := [
		4.0,
		2.0,
		1.0, // column 0
		2.0,
		3.0,
		1.0, // column 1
		1.0,
		1.0,
		2.0, // column 2
	]

	println('Original matrix (column-major):')
	for i in 0 .. 3 {
		for j in 0 .. 3 {
			// Access element [i,j] in column-major: a[i + j*3]
			print('${a[i + j * 3]:8.4f} ')
		}
		println('')
	}

	// Test upper triangular Cholesky
	// dpotrf expects column-major format for Pure V backend
	ok := dpotrf(.upper, 3, mut a, 3)

	println('Cholesky factorization (upper): ok=${ok}')
	for i in 0 .. 3 {
		for j in 0 .. 3 {
			print('${a[i + j * 3]:8.4f} ')
		}
		println('')
	}

	assert ok == true, 'dpotrf should succeed for positive definite matrix'

	// Verify the factorization by computing U^T * U
	// Pure V backend: column-major format
	// U[i,j] is at index i + j*3 (column-major)
	// U^T[i,j] = U[j,i] is at index j + i*3
	// (U^T * U)[i,j] = sum_k U^T[i,k] * U[k,j] = sum_k U[k,i] * U[k,j]
	mut reconstructed := []f64{len: 9}
	for i in 0 .. 3 {
		for j in 0 .. 3 {
			mut sum := 0.0
			// For upper triangular U, U[k,i] = 0 if k > i, U[k,j] = 0 if k > j
			// So sum from k=0 to min(i,j)
			for k in 0 .. math.min(i, j) + 1 {
				// U[k,i] is at index k + i*3 (column-major)
				// U[k,j] is at index k + j*3 (column-major)
				sum += a[k + i * 3] * a[k + j * 3]
			}
			// Store result in column-major format
			reconstructed[i + j * 3] = sum
		}
	}

	println('Reconstructed (U^T * U):')
	for i in 0 .. 3 {
		for j in 0 .. 3 {
			print('${reconstructed[i + j * 3]:8.4f} ')
		}
		println('')
	}

	// Expected original matrix in column-major format
	expected := [4.0, 2.0, 1.0, 2.0, 3.0, 1.0, 1.0, 1.0, 2.0]
	for i in 0 .. 9 {
		diff := abs(reconstructed[i] - expected[i])
		assert diff < 1e-8, 'reconstruction error at ${i}: ${diff}'
	}
}

fn test_dpotrf_identity() {
	// Test with identity matrix
	// Pure V backend: column-major format
	mut a := [
		1.0,
		0.0,
		0.0, // column 0
		0.0,
		1.0,
		0.0, // column 1
		0.0,
		0.0,
		1.0, // column 2
	]

	ok := dpotrf(.lower, 3, mut a, 3)
	assert ok == true, 'dpotrf should succeed for identity'

	// Result should still be identity (for lower triangular) in column-major format
	expected := [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
	for i in 0 .. 9 {
		assert abs(a[i] - expected[i]) < 1e-10, 'identity Cholesky should be identity'
	}
}

fn abs(x f64) f64 {
	return if x < 0 { -x } else { x }
}
