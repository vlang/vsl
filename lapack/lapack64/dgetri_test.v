module lapack64

fn test_dgetri_basic() {
	// Test with a simple 3x3 matrix
	mut a := [
		3.0, -1.0, 2.0,
		1.0,  2.0, 3.0,
		2.0, -2.0, -1.0,
	]
	
	mut ipiv := []int{len: 3}
	
	// First do LU factorization
	ok := dgetrf(3, 3, mut a, 3, mut ipiv)
	if !ok {
		println('dgetrf failed')
		return
	}
	
	println('After LU factorization:')
	for i in 0..3 {
		for j in 0..3 {
			print('${a[i*3 + j]:8.4f} ')
		}
		println('')
	}
	println('ipiv: ${ipiv}')
	
	// Now compute the inverse
	mut work := []f64{len: 9}
	ok_inv := dgetri(3, mut a, 3, ipiv, mut work, work.len)
	
	println('dgetri ok: ${ok_inv}')
	
	if ok_inv {
		println('Inverse matrix:')
		for i in 0..3 {
			for j in 0..3 {
				print('${a[i*3 + j]:8.4f} ')
			}
			println('')
		}
	}
	
	assert ok_inv == true, 'dgetri should succeed'
}

fn test_dgetri_simple() {
	// Test with identity matrix (easy case)
	mut a := [
		1.0, 0.0, 0.0,
		0.0, 1.0, 0.0,
		0.0, 0.0, 1.0,
	]
	
	mut ipiv := []int{len: 3}
	
	ok := dgetrf(3, 3, mut a, 3, mut ipiv)
	assert ok == true, 'dgetrf should succeed for identity'
	
	mut work := []f64{len: 9}
	ok_inv := dgetri(3, mut a, 3, ipiv, mut work, work.len)
	assert ok_inv == true, 'dgetri should succeed for identity'
	
	// Result should still be identity
	expected := [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
	for i in 0..9 {
		assert abs(a[i] - expected[i]) < 1e-10, 'identity inverse should be identity'
	}
}

fn abs(x f64) f64 {
	return if x < 0 { -x } else { x }
}
