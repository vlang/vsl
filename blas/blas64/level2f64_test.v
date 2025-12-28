module blas64

import vsl.float.float64

// ====================
// LEVEL 2 BLAS TESTS
// ====================

fn test_dgemv() {
	// Test case 1: No transpose
	a1 := [
		[1.0, 2.0, 3.0],
		[4.0, 5.0, 6.0],
	]
	x1 := [1.0, 2.0, 3.0]
	mut y1 := [0.0, 0.0]
	dgemv(.no_trans, 2, 3, 1.0, flatten(a1), 3, x1, 1, 0.0, mut y1, 1)
	expected1 := [14.0, 32.0] // [1*1+2*2+3*3, 4*1+5*2+6*3] = [14, 32]
	assert float64.arrays_tolerance(y1, expected1, test_tol), 'DGEMV no_trans test failed: expected ${expected1}, got ${y1}'

	// Test case 2: Transpose
	a2 := [
		[1.0, 2.0],
		[3.0, 4.0],
		[5.0, 6.0],
	]
	x2 := [1.0, 2.0, 3.0]
	mut y2 := [0.0, 0.0]
	dgemv(.trans, 3, 2, 1.0, flatten(a2), 2, x2, 1, 0.0, mut y2, 1)
	expected2 := [22.0, 28.0] // [1*1+3*2+5*3, 2*1+4*2+6*3] = [22, 28]
	assert float64.arrays_tolerance(y2, expected2, test_tol), 'DGEMV trans test failed: expected ${expected2}, got ${y2}'

	// Test case 3: Alpha and beta
	a3 := [
		[1.0, 2.0],
		[3.0, 4.0],
	]
	x3 := [1.0, 2.0]
	mut y3 := [1.0, 1.0]
	dgemv(.no_trans, 2, 2, 2.0, flatten(a3), 2, x3, 1, 3.0, mut y3, 1)
	expected3 := [13.0, 25.0] // 2*[1*1+2*2, 3*1+4*2] + 3*[1, 1] = 2*[5, 11] + [3, 3] = [10, 22] + [3, 3] = [13, 25]
	assert float64.arrays_tolerance(y3, expected3, test_tol), 'DGEMV alpha/beta test failed: expected ${expected3}, got ${y3}'
}

fn test_dger() {
	// Test case 1: Basic rank-1 update
	mut a1 := [
		[1.0, 2.0],
		[3.0, 4.0],
	]
	x1 := [1.0, 2.0]
	y1 := [1.0, 2.0]
	mut a1_flat := flatten(a1)
	dger(2, 2, 1.0, x1, 1, y1, 1, mut a1_flat, 2)
	// A = A + alpha * x * y^T = [[1,2],[3,4]] + 1.0 * [1,2]^T * [1,2] = [[1,2],[3,4]] + [[1,2],[2,4]] = [[2,4],[5,8]]
	expected1 := [2.0, 4.0, 5.0, 8.0]
	assert float64.arrays_tolerance(a1_flat, expected1, test_tol), 'DGER test 1 failed: expected ${expected1}, got ${a1_flat}'

	// Test case 2: Zero alpha
	mut a2 := [
		[1.0, 2.0],
		[3.0, 4.0],
	]
	x2 := [1.0, 2.0]
	y2 := [1.0, 2.0]
	mut a2_flat := flatten(a2)
	original2 := a2_flat.clone()
	dger(2, 2, 0.0, x2, 1, y2, 1, mut a2_flat, 2)
	assert float64.arrays_tolerance(a2_flat, original2, test_tol), 'DGER test 2 failed: matrix should be unchanged'
}

fn test_dtrsv() {
	// Test case 1: Upper triangular, no transpose
	// Solve: U * x = b where U is upper triangular
	// [2  1  0] [x1]   [8]
	// [0  3  2] [x2] = [11]
	// [0  0  4] [x3]   [4]
	// Solution: x3 = 4/4 = 1, x2 = (11-2*1)/3 = 3, x1 = (8-1*3)/2 = 2.5
	a1 := [
		[2.0, 1.0, 0.0],
		[0.0, 3.0, 2.0],
		[0.0, 0.0, 4.0],
	]
	mut x1 := [8.0, 11.0, 4.0]
	dtrsv(.upper, .no_trans, .non_unit, 3, flatten(a1), 3, mut x1, 1)
	expected1 := [2.5, 3.0, 1.0] // Corrected expected values
	assert float64.arrays_tolerance(x1, expected1, test_tol), 'DTRSV upper test failed: expected ${expected1}, got ${x1}'

	// Test case 2: Lower triangular, no transpose
	// Solve: L * x = b where L is lower triangular
	// [2  0  0] [x1]   [6]
	// [1  3  0] [x2] = [11]
	// [0  2  4] [x3]   [14]
	// Solution: x1 = 6/2 = 3, x2 = (11-1*3)/3 = 8/3, x3 = (14-2*8/3)/4 = (14-16/3)/4 = (42-16)/(3*4) = 26/12 = 13/6
	a2 := [
		[2.0, 0.0, 0.0],
		[1.0, 3.0, 0.0],
		[0.0, 2.0, 4.0],
	]
	mut x2 := [6.0, 11.0, 14.0]
	dtrsv(.lower, .no_trans, .non_unit, 3, flatten(a2), 3, mut x2, 1)
	expected2 := [3.0, 8.0 / 3.0, 13.0 / 6.0] // Corrected expected values
	assert float64.arrays_tolerance(x2, expected2, test_tol), 'DTRSV lower test failed: expected ${expected2}, got ${x2}'
}

fn test_dtrmv() {
	// Test case 1: Upper triangular matrix-vector multiply
	a1 := [
		[2.0, 1.0, 3.0],
		[0.0, 4.0, 2.0],
		[0.0, 0.0, 5.0],
	]
	mut x1 := [1.0, 2.0, 3.0]
	dtrmv(.upper, .no_trans, .non_unit, 3, flatten(a1), 3, mut x1, 1)
	expected1 := [13.0, 14.0, 15.0] // [2*1+1*2+3*3, 4*2+2*3, 5*3] = [13, 14, 15]
	assert float64.arrays_tolerance(x1, expected1, test_tol), 'DTRMV upper test failed: expected ${expected1}, got ${x1}'

	// Test case 2: Lower triangular matrix-vector multiply
	a2 := [
		[2.0, 0.0, 0.0],
		[1.0, 4.0, 0.0],
		[3.0, 2.0, 5.0],
	]
	mut x2 := [1.0, 2.0, 3.0]
	dtrmv(.lower, .no_trans, .non_unit, 3, flatten(a2), 3, mut x2, 1)
	expected2 := [2.0, 9.0, 22.0] // [2*1, 1*1+4*2, 3*1+2*2+5*3] = [2, 9, 22]
	assert float64.arrays_tolerance(x2, expected2, test_tol), 'DTRMV lower test failed: expected ${expected2}, got ${x2}'
}

fn test_dsymv() {
	// Test case 1: Upper symmetric matrix
	// For symmetric matrices, only the specified triangle is referenced
	a1 := [
		[1.0, 2.0, 3.0],
		[0.0, 4.0, 5.0], // Only upper triangle is used, lower is ignored
		[0.0, 0.0, 6.0],
	]
	x1 := [1.0, 2.0, 3.0]
	mut y1 := [0.0, 0.0, 0.0]
	dsymv(.upper, 3, 1.0, flatten(a1), 3, x1, 1, 0.0, mut y1, 1)
	// Using symmetry: matrix becomes [[1,2,3],[2,4,5],[3,5,6]]
	// y = A*x = [1*1+2*2+3*3, 2*1+4*2+5*3, 3*1+5*2+6*3] = [14, 25, 31]
	expected1 := [14.0, 25.0, 31.0] // Corrected expected value
	assert float64.arrays_tolerance(y1, expected1, test_tol), 'DSYMV upper test failed: expected ${expected1}, got ${y1}'

	// Test case 2: Lower symmetric matrix
	a2 := [
		[1.0, 0.0, 0.0], // Only lower triangle is used, upper is ignored
		[2.0, 4.0, 0.0],
		[3.0, 5.0, 6.0],
	]
	x2 := [1.0, 2.0, 3.0]
	mut y2 := [0.0, 0.0, 0.0]
	dsymv(.lower, 3, 1.0, flatten(a2), 3, x2, 1, 0.0, mut y2, 1)
	// Using symmetry: matrix becomes [[1,2,3],[2,4,5],[3,5,6]]
	expected2 := [14.0, 25.0, 31.0] // Same result as upper due to symmetry
	assert float64.arrays_tolerance(y2, expected2, test_tol), 'DSYMV lower test failed: expected ${expected2}, got ${y2}'
}

fn test_dgbmv() {
	// Test case 1: Simple band matrix vector multiply
	// 2x2 matrix with kl=1, ku=1 (1 sub-diagonal, 1 super-diagonal)
	// Matrix: [2  1]
	//         [1  2]
	// Band storage format (kl=1, ku=1, lda=3):
	// Row 0: [*  2  1] (entry 0 unused, diagonal at position ku, super-diagonal after)
	// Row 1: [1  2  *] (sub-diagonal at position 0, diagonal at position ku, entry 2 unused)
	a1 := [0.0, 2.0, 1.0, 1.0, 2.0, 0.0] // Band storage
	x1 := [1.0, 2.0]
	mut y1 := [0.0, 0.0]
	dgbmv(.no_trans, 2, 2, 1, 1, 1.0, a1, 3, x1, 1, 0.0, mut y1, 1)
	expected1 := [4.0, 5.0] // [2*1+1*2, 1*1+2*2] = [4, 5]
	assert float64.arrays_tolerance(y1, expected1, test_tol), 'DGBMV test failed: expected ${expected1}, got ${y1}'
}

fn test_dtbmv() {
	// Test case 1: Simple upper triangular band matrix
	// 2x2 upper triangular with k=1 super-diagonal:
	// [2  1]
	// [0  2]
	// Band storage format with k=1, lda=2 (for upper triangular band):
	// Row 0: [2  1] (diagonal at position 0, super-diagonal at position 1)
	// Row 1: [2  *] (diagonal at position 0, * is unused)
	a1 := [2.0, 1.0, 2.0, 0.0] // Band storage for upper triangular
	mut x1 := [1.0, 2.0]
	dtbmv(.upper, .no_trans, .non_unit, 2, 1, a1, 2, mut x1, 1)
	expected1 := [4.0, 4.0] // [2*1+1*2, 2*2] = [4, 4]
	assert float64.arrays_tolerance(x1, expected1, test_tol), 'DTBMV test failed: expected ${expected1}, got ${x1}'
}

fn test_dtbsv() {
	// Test case 1: Solve simple triangular band system
	// 2x2 upper triangular with k=1 super-diagonal:
	// [2  1] [x1]   [4]
	// [0  2] [x2] = [4]
	// Solution: x2 = 4/2 = 2, x1 = (4-1*2)/2 = 1
	// Band storage format with k=1, lda=2 (for upper triangular band):
	// Row 0: [2  1] (diagonal at position 0, super-diagonal at position 1)
	// Row 1: [2  *] (diagonal at position 0, * is unused)
	a1 := [2.0, 1.0, 2.0, 0.0] // Band storage
	mut x1 := [4.0, 4.0]
	dtbsv(.upper, .no_trans, .non_unit, 2, 1, a1, 2, mut x1, 1)
	expected1 := [1.0, 2.0]
	assert float64.arrays_tolerance(x1, expected1, test_tol), 'DTBSV test failed: expected ${expected1}, got ${x1}'
}
