module lapack64

import math

fn test_dpotrf_basic() {
	// Test with a simple symmetric positive definite matrix
	// Original matrix:
	// [4  2  1]
	// [2  3  1]  
	// [1  1  2]
	
	mut a := [
		4.0, 2.0, 1.0,
		2.0, 3.0, 1.0,
		1.0, 1.0, 2.0,
	]
	
	println('Original matrix:')
	for i in 0..3 {
		for j in 0..3 {
			print('${a[i*3 + j]:8.4f} ')
		}
		println('')
	}
	
	// Test upper triangular Cholesky
	ok := dpotrf(.upper, 3, mut a, 3)
	
	println('Cholesky factorization (upper): ok=${ok}')
	for i in 0..3 {
		for j in 0..3 {
			print('${a[i*3 + j]:8.4f} ')
		}
		println('')
	}
	
	assert ok == true, 'dpotrf should succeed for positive definite matrix'
	
	// Verify the factorization by computing U^T * U
	mut reconstructed := []f64{len: 9}
	for i in 0..3 {
		for j in 0..3 {
			mut sum := 0.0
			// For upper triangular U, U[k,i] = 0 if k > i, U[k,j] = 0 if k > j
			// So sum from k=0 to min(i,j)
			for k in 0..math.min(i, j)+1 {
				sum += a[k*3 + i] * a[k*3 + j]
			}
			reconstructed[i*3 + j] = sum
		}
	}
	
	println('Reconstructed (U^T * U):')
	for i in 0..3 {
		for j in 0..3 {
			print('${reconstructed[i*3 + j]:8.4f} ')
		}
		println('')
	}
	
	// Expected original matrix
	expected := [4.0, 2.0, 1.0, 2.0, 3.0, 1.0, 1.0, 1.0, 2.0]
	
	for i in 0..9 {
		diff := abs(reconstructed[i] - expected[i])
		assert diff < 1e-8, 'reconstruction error at ${i}: ${diff}'
	}
}

fn test_dpotrf_identity() {
	// Test with identity matrix
	mut a := [
		1.0, 0.0, 0.0,
		0.0, 1.0, 0.0,
		0.0, 0.0, 1.0,
	]
	
	ok := dpotrf(.lower, 3, mut a, 3)
	assert ok == true, 'dpotrf should succeed for identity'
	
	// Result should still be identity (for lower triangular)
	expected := [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
	for i in 0..9 {
		assert abs(a[i] - expected[i]) < 1e-10, 'identity Cholesky should be identity'
	}
}

fn abs(x f64) f64 {
	return if x < 0 { -x } else { x }
}
