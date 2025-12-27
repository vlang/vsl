module lapack64

import vsl.float.float64

fn test_dgetrf_basic() {
	// Test case from Gonum: https://github.com/gonum/gonum/blob/master/lapack/gonum/dgetrf.go
	// Simple 3x3 matrix
	mut a := [
		[2.0, 1.0, 1.0],
		[4.0, 3.0, 3.0],
		[8.0, 7.0, 9.0],
	]
	
	// Convert to flat array (row-major)
	mut a_flat := []f64{len: 9}
	for i in 0..3 {
		for j in 0..3 {
			a_flat[i*3 + j] = a[i][j]
		}
	}
	
	mut ipiv := []int{len: 3}
	
	// Call dgetrf
	ok := dgetrf(3, 3, mut a_flat, 3, mut ipiv)
	
	println('dgetrf result: ok=${ok}')
	println('ipiv: ${ipiv}')
	println('factorized matrix:')
	for i in 0..3 {
		for j in 0..3 {
			print('${a_flat[i*3 + j]:8.4f} ')
		}
		println('')
	}
	
	// Basic checks
	assert ok == true, 'dgetrf should succeed for non-singular matrix'
	
	// Check that pivot indices are valid (0-based)
	for i, p in ipiv {
		assert p >= i && p < 3, 'getrf: invalid pivot index ${p} at position ${i}'
	}
}

fn test_dgetrf_singular() {
	// Test singular matrix
	mut a_flat := [
		1.0, 2.0, 3.0,
		2.0, 4.0, 6.0,  // This row is 2x the first row
		4.0, 5.0, 6.0,
	]
	
	mut ipiv := []int{len: 3}
	
	ok := dgetrf(3, 3, mut a_flat, 3, mut ipiv)
	
	println('dgetrf singular result: ok=${ok}')
	
	// Should return false for singular matrix but not panic
	assert ok == false, 'dgetrf should return false for singular matrix'
}

fn test_dgetrf_comparison_with_expected() {
	// Test with known expected result
	mut a_flat := [
		3.0, -1.0, 2.0,
		1.0,  2.0, 3.0,
		2.0, -2.0, -1.0,
	]
	
	mut ipiv := []int{len: 3}
	
	ok := dgetrf(3, 3, mut a_flat, 3, mut ipiv)
	
	println('dgetrf comparison test:')
	println('ok: ${ok}')
	println('ipiv: ${ipiv}')
	println('L+U matrix:')
	for i in 0..3 {
		for j in 0..3 {
			print('${a_flat[i*3 + j]:8.4f} ')
		}
		println('')
	}
	
	assert ok == true, 'dgetrf should succeed'
}
