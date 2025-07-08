module blas64

import vsl.float.float64
import math

// ====================
// LEVEL 3 BLAS TESTS
// ====================

fn test_dgemm() {
	// Test case 1: Basic matrix multiplication C = A * B
	// A = [[1, 2], [3, 4]], B = [[5, 6], [7, 8]]
	// Result: C = [[19, 22], [43, 50]]
	a1 := [1.0, 2.0, 3.0, 4.0] // row-major order
	b1 := [5.0, 6.0, 7.0, 8.0]
	mut c1 := [0.0, 0.0, 0.0, 0.0]

	dgemm(.no_trans, .no_trans, 2, 2, 2, 1.0, a1, 2, b1, 2, 0.0, mut c1, 2)
	expected1 := [19.0, 22.0, 43.0, 50.0] // [[1*5+2*7, 1*6+2*8], [3*5+4*7, 3*6+4*8]] = [[19, 22], [43, 50]]
	assert float64.arrays_tolerance(c1, expected1, test_tol), 'DGEMM no_trans test failed: expected ${expected1}, got ${c1}'

	// Test case 2: Transpose A, C = A^T * B
	// A = [[1, 3], [2, 4]] (stored as [1, 3, 2, 4])
	// A^T = [[1, 2], [3, 4]]
	a2 := [1.0, 3.0, 2.0, 4.0] // different storage to get A^T = previous A
	b2 := [5.0, 6.0, 7.0, 8.0]
	mut c2 := [0.0, 0.0, 0.0, 0.0]

	dgemm(.trans, .no_trans, 2, 2, 2, 1.0, a2, 2, b2, 2, 0.0, mut c2, 2)
	expected2 := [19.0, 22.0, 43.0, 50.0] // Same result since A2^T = A1
	assert float64.arrays_tolerance(c2, expected2, test_tol), 'DGEMM trans_a test failed: expected ${expected2}, got ${c2}'

	// Test case 3: Alpha and beta scaling, C = alpha * A * B + beta * C
	a3 := [1.0, 1.0, 1.0, 1.0] // A = [[1, 1], [1, 1]]
	b3 := [1.0, 1.0, 1.0, 1.0] // B = [[1, 1], [1, 1]]
	mut c3 := [1.0, 1.0, 1.0, 1.0] // C = [[1, 1], [1, 1]] initially

	dgemm(.no_trans, .no_trans, 2, 2, 2, 2.0, a3, 2, b3, 2, 3.0, mut c3, 2)
	expected3 := [7.0, 7.0, 7.0, 7.0] // 2*[[2,2],[2,2]] + 3*[[1,1],[1,1]] = [[4,4],[4,4]] + [[3,3],[3,3]] = [[7,7],[7,7]]
	assert float64.arrays_tolerance(c3, expected3, test_tol), 'DGEMM alpha/beta test failed: expected ${expected3}, got ${c3}'
}

fn test_dsyrk() {
	// Test case 1: Symmetric rank-k update, C = A * A^T
	// A = [[1, 2], [3, 4]]
	// A * A^T = [[1*1+2*2, 1*3+2*4], [3*1+4*2, 3*3+4*4]] = [[5, 11], [11, 25]]
	a1 := [1.0, 2.0, 3.0, 4.0] // row-major order
	mut c1 := [0.0, 0.0, 0.0, 0.0]

	dsyrk(.upper, .no_trans, 2, 2, 1.0, a1, 2, 0.0, mut c1, 2)
	// Only upper triangle is computed and stored for symmetric matrices
	assert float64.tolerance(c1[0], 5.0, test_tol), 'DSYRK test failed: c[0,0] expected 5.0, got ${c1[0]}'
	assert float64.tolerance(c1[1], 11.0, test_tol), 'DSYRK test failed: c[0,1] expected 11.0, got ${c1[1]}'
	assert float64.tolerance(c1[3], 25.0, test_tol), 'DSYRK test failed: c[1,1] expected 25.0, got ${c1[3]}'

	// Test case 2: Transpose case, C = A^T * A
	// A = [[1, 3], [2, 4]]
	// A^T * A = [[1*1+2*2, 1*3+2*4], [3*1+4*2, 3*3+4*4]] = [[5, 11], [11, 25]]
	a2 := [1.0, 3.0, 2.0, 4.0] // different storage
	mut c2 := [0.0, 0.0, 0.0, 0.0]

	dsyrk(.upper, .trans, 2, 2, 1.0, a2, 2, 0.0, mut c2, 2)
	assert float64.tolerance(c2[0], 5.0, test_tol), 'DSYRK trans test failed: c[0,0] expected 5.0, got ${c2[0]}'
	assert float64.tolerance(c2[1], 11.0, test_tol), 'DSYRK trans test failed: c[0,1] expected 11.0, got ${c2[1]}'
	assert float64.tolerance(c2[3], 25.0, test_tol), 'DSYRK trans test failed: c[1,1] expected 25.0, got ${c2[3]}'
}

// Helper function to unflatten back to 2D array (for verification)
fn unflatten(s []f64, m int, n int) [][]f64 {
	mut a := [][]f64{len: m, init: []f64{len: n}}
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = s[i * n + j]
		}
	}
	return a
}
