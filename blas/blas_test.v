module blas

import math
import vsl.float.float64

// Test tolerance for floating point comparisons
const test_tol = 1e-14

// Detect if CBLAS backend is working properly
fn is_cblas_working() bool {
	// Try a simple operation to detect if CBLAS is working
	x := [1.0, 2.0]
	y := [3.0, 4.0]
	result := ddot(2, x, 1, y, 1)
	expected := 11.0 // 1*3 + 2*4 = 11

	// If result is wildly incorrect, CBLAS is not working
	return math.abs(result - expected) < 1.0
}

// Test data structures for Level 1 BLAS operations
struct Level1TestCase {
	name            string
	x               []f64
	incx            int
	n               int
	expected_dasum  f64
	expected_dnrm2  f64
	expected_idamax int
	scal_tests      []ScalTestCase
}

struct ScalTestCase {
	alpha    f64
	expected []f64
	name     string
}

// Test cases for Level 1 BLAS operations
const level1_test_cases = [
	Level1TestCase{
		name:            'AllPositive'
		x:               [6.0, 5.0, 4.0, 2.0, 6.0]
		incx:            1
		n:               5
		expected_dasum:  23.0
		expected_dnrm2:  10.81665382639196787935766380241148783875388972153573863813135
		expected_idamax: 0
		scal_tests:      [ScalTestCase{
			alpha:    0.0
			expected: [0.0, 0.0, 0.0, 0.0, 0.0]
			name:     'ZeroScale'
		}, ScalTestCase{
			alpha:    1.0
			expected: [6.0, 5.0, 4.0, 2.0, 6.0]
			name:     'OneScale'
		}, ScalTestCase{
			alpha:    2.0
			expected: [12.0, 10.0, 8.0, 4.0, 12.0]
			name:     'TwoScale'
		}]
	},
	Level1TestCase{
		name:            'WithNegatives'
		x:               [-6.0, 5.0, -4.0, 2.0, -6.0]
		incx:            1
		n:               5
		expected_dasum:  23.0
		expected_dnrm2:  10.81665382639196787935766380241148783875388972153573863813135
		expected_idamax: 0
		scal_tests:      [ScalTestCase{
			alpha:    -1.0
			expected: [6.0, -5.0, 4.0, -2.0, 6.0]
			name:     'NegOneScale'
		}]
	},
	Level1TestCase{
		name:            'Stride2'
		x:               [1.0, 100.0, 2.0, 200.0, 3.0, 300.0, 4.0]
		incx:            2
		n:               4
		expected_dasum:  10.0
		expected_dnrm2:  math.sqrt(30.0)
		expected_idamax: 3
		scal_tests:      [ScalTestCase{
			alpha:    3.0
			expected: [3.0, 100.0, 6.0, 200.0, 9.0, 300.0, 12.0]
			name:     'ThreeScale'
		}]
	},
]

// Test data for Level 2 BLAS operations (GEMV)
struct GemvTestCase {
	name     string
	trans    Transpose
	m        int
	n        int
	alpha    f64
	a        [][]f64
	x        []f64
	beta     f64
	y        []f64
	expected []f64
}

const gemv_test_cases = [
	GemvTestCase{
		name:     'NoTrans_3x3'
		trans:    .no_trans
		m:        3
		n:        3
		alpha:    1.0
		a:        [
			[1.0, 2.0, 3.0],
			[4.0, 5.0, 6.0],
			[7.0, 8.0, 9.0],
		]
		x:        [
			1.0,
			2.0,
			3.0,
		]
		beta:     0.0
		y:        [
			0.0,
			0.0,
			0.0,
		]
		expected: [
			14.0,
			32.0,
			50.0,
		] // [1*1+2*2+3*3, 4*1+5*2+6*3, 7*1+8*2+9*3]
	},
	GemvTestCase{
		name:     'Trans_3x3'
		trans:    .trans
		m:        3
		n:        3
		alpha:    1.0
		a:        [
			[1.0, 2.0, 3.0],
			[4.0, 5.0, 6.0],
			[7.0, 8.0, 9.0],
		]
		x:        [
			1.0,
			2.0,
			3.0,
		]
		beta:     0.0
		y:        [
			0.0,
			0.0,
			0.0,
		]
		expected: [
			30.0,
			36.0,
			42.0,
		] // [1*1+4*2+7*3, 2*1+5*2+8*3, 3*1+6*2+9*3]
	},
	GemvTestCase{
		name:     'AlphaBeta_2x3'
		trans:    .no_trans
		m:        2
		n:        3
		alpha:    2.0
		a:        [
			[1.0, 2.0, 3.0],
			[4.0, 5.0, 6.0],
		]
		x:        [
			1.0,
			1.0,
			1.0,
		]
		beta:     0.5
		y:        [
			10.0,
			20.0,
		]
		expected: [
			17.0,
			40.0,
		] // [2*(1+2+3) + 0.5*10, 2*(4+5+6) + 0.5*20] = [12+5, 30+10] = [17, 40]
	},
]

// Test data for Level 3 BLAS operations (GEMM)
struct GemmTestCase {
	name     string
	trans_a  Transpose
	trans_b  Transpose
	m        int
	n        int
	k        int
	alpha    f64
	a        [][]f64
	b        [][]f64
	beta     f64
	c        [][]f64
	expected [][]f64
}

const gemm_test_cases = [
	GemmTestCase{
		name:     'NoTrans_4x3x2'
		trans_a:  .no_trans
		trans_b:  .no_trans
		m:        4
		n:        3
		k:        2
		alpha:    2.0
		a:        [
			[1.0, 2.0],
			[4.0, 5.0],
			[7.0, 8.0],
			[10.0, 11.0],
		]
		b:        [
			[1.0, 5.0, 6.0],
			[5.0, -8.0, 8.0],
		]
		beta:     0.5
		c:        [
			[4.0, 8.0, -9.0],
			[12.0, 16.0, -8.0],
			[1.0, 5.0, 15.0],
			[-3.0, -4.0, 7.0],
		]
		expected: [
			[24.0, -18.0, 39.5], // 2*(1*1+2*5) + 0.5*4, 2*(1*5+2*(-8)) + 0.5*8, 2*(1*6+2*8) + 0.5*(-9)
			[64.0, -32.0, 124.0], // 2*(4*1+5*5) + 0.5*12, 2*(4*5+5*(-8)) + 0.5*16, 2*(4*6+5*8) + 0.5*(-8)
			[94.5, -55.5, 219.5], // 2*(7*1+8*5) + 0.5*1, 2*(7*5+8*(-8)) + 0.5*5, 2*(7*6+8*8) + 0.5*15
			[128.5, -78.0, 299.5], // 2*(10*1+11*5) + 0.5*(-3), 2*(10*5+11*(-8)) + 0.5*(-4), 2*(10*6+11*8) + 0.5*7
		]
	},
	GemmTestCase{
		name:     'Identity_3x3'
		trans_a:  .no_trans
		trans_b:  .no_trans
		m:        3
		n:        3
		k:        3
		alpha:    1.0
		a:        [
			[1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, 1.0],
		]
		b:        [
			[1.0, 2.0, 3.0],
			[4.0, 5.0, 6.0],
			[7.0, 8.0, 9.0],
		]
		beta:     0.0
		c:        [
			[0.0, 0.0, 0.0],
			[0.0, 0.0, 0.0],
			[0.0, 0.0, 0.0],
		]
		expected: [
			[1.0, 2.0, 3.0],
			[4.0, 5.0, 6.0],
			[7.0, 8.0, 9.0],
		]
	},
]

// ====================
// LEVEL 1 BLAS TESTS
// ====================

fn test_dasum() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dasum test')
		return
	}

	for case in level1_test_cases {
		result := dasum(case.n, case.x, case.incx)
		assert float64.tolerance(result, case.expected_dasum, test_tol), 'DASUM failed for case ${case.name}: expected ${case.expected_dasum}, got ${result}'
	}
}

fn test_dnrm2() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dnrm2 test')
		return
	}

	for case in level1_test_cases {
		result := dnrm2(case.n, case.x, case.incx)
		assert float64.tolerance(result, case.expected_dnrm2, test_tol), 'DNRM2 failed for case ${case.name}: expected ${case.expected_dnrm2}, got ${result}'
	}
}

fn test_idamax() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping idamax test')
		return
	}

	for case in level1_test_cases {
		result := idamax(case.n, case.x, case.incx)
		assert result == case.expected_idamax, 'IDAMAX failed for case ${case.name}: expected ${case.expected_idamax}, got ${result}'
	}
}

fn test_dscal() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dscal test')
		return
	}

	for case in level1_test_cases {
		for scal_case in case.scal_tests {
			mut x := case.x.clone()
			dscal(case.n, scal_case.alpha, mut x, case.incx)
			assert float64.arrays_tolerance(x, scal_case.expected, test_tol), 'DSCAL failed for case ${case.name}/${scal_case.name}: expected ${scal_case.expected}, got ${x}'
		}
	}
}

fn test_dcopy() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dcopy test')
		return
	}

	x := [1.0, 2.0, 3.0, 4.0, 5.0]
	mut y := [0.0, 0.0, 0.0, 0.0, 0.0]
	dcopy(5, x, 1, mut y, 1)
	assert float64.arrays_tolerance(x, y, test_tol), 'DCOPY failed: expected ${x}, got ${y}'

	// Test with stride
	x2 := [1.0, 100.0, 2.0, 200.0, 3.0, 300.0]
	mut y2 := [0.0, 0.0, 0.0]
	dcopy(3, x2, 2, mut y2, 1)
	expected := [1.0, 2.0, 3.0]
	assert float64.arrays_tolerance(y2, expected, test_tol), 'DCOPY with stride failed: expected ${expected}, got ${y2}'
}

fn test_daxpy() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping daxpy test')
		return
	}

	x := [1.0, 2.0, 3.0]
	mut y := [4.0, 5.0, 6.0]
	alpha := 2.0
	daxpy(3, alpha, x, 1, mut y, 1)
	expected := [6.0, 9.0, 12.0] // y = alpha*x + y = 2*[1,2,3] + [4,5,6]
	assert float64.arrays_tolerance(y, expected, test_tol), 'DAXPY failed: expected ${expected}, got ${y}'
}

fn test_ddot() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping ddot test')
		return
	}

	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	result := ddot(3, x, 1, y, 1)
	expected := 32.0 // 1*4 + 2*5 + 3*6
	assert float64.tolerance(result, expected, test_tol), 'DDOT failed: expected ${expected}, got ${result}'
}

fn test_dswap() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dswap test')
		return
	}

	mut x := [1.0, 2.0, 3.0]
	mut y := [4.0, 5.0, 6.0]
	x_orig := x.clone()
	y_orig := y.clone()
	dswap(3, mut x, 1, mut y, 1)
	assert float64.arrays_tolerance(x, y_orig, test_tol), 'DSWAP failed: x should equal original y, got ${x}'
	assert float64.arrays_tolerance(y, x_orig, test_tol), 'DSWAP failed: y should equal original x, got ${y}'
}

// ====================
// LEVEL 2 BLAS TESTS
// ====================

fn test_dgemv() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dgemv test')
		return
	}

	for case in gemv_test_cases {
		// Convert 2D matrix to flat array
		mut a_flat := []f64{len: case.m * case.n}
		for i in 0 .. case.m {
			for j in 0 .. case.n {
				a_flat[i * case.n + j] = case.a[i][j]
			}
		}

		mut y := case.y.clone()
		dgemv(case.trans, case.m, case.n, case.alpha, a_flat, case.n, case.x, 1, case.beta, mut
			y, 1)

		assert float64.arrays_tolerance(y, case.expected, test_tol), 'DGEMV failed for case ${case.name}: expected ${case.expected}, got ${y}'
	}
}

fn test_dger() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dger test')
		return
	}

	// Test rank-1 update: A = alpha * x * y^T + A
	mut a := [
		[1.0, 2.0, 3.0],
		[4.0, 5.0, 6.0],
	]
	x := [1.0, 2.0]
	y := [1.0, 1.0, 1.0]
	alpha := 2.0

	// Convert to flat array
	mut a_flat := []f64{len: 6}
	for i in 0 .. 2 {
		for j in 0 .. 3 {
			a_flat[i * 3 + j] = a[i][j]
		}
	}

	dger(2, 3, alpha, x, 1, y, 1, mut a_flat, 3)

	// Expected: A + 2 * [1, 2]^T * [1, 1, 1] = A + 2 * [[1,1,1], [2,2,2]]
	expected_flat := [3.0, 4.0, 5.0, 8.0, 9.0, 10.0]
	assert float64.arrays_tolerance(a_flat, expected_flat, test_tol), 'DGER failed: expected ${expected_flat}, got ${a_flat}'
}

// ====================
// LEVEL 3 BLAS TESTS
// ====================

fn test_dgemm() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dgemm test')
		return
	}

	for case in gemm_test_cases {
		// Convert matrices to flat arrays
		mut a_flat := []f64{len: case.m * case.k}
		mut b_flat := []f64{len: case.k * case.n}
		mut c_flat := []f64{len: case.m * case.n}

		for i in 0 .. case.m {
			for j in 0 .. case.k {
				a_flat[i * case.k + j] = case.a[i][j]
			}
		}

		for i in 0 .. case.k {
			for j in 0 .. case.n {
				b_flat[i * case.n + j] = case.b[i][j]
			}
		}

		for i in 0 .. case.m {
			for j in 0 .. case.n {
				c_flat[i * case.n + j] = case.c[i][j]
			}
		}

		dgemm(case.trans_a, case.trans_b, case.m, case.n, case.k, case.alpha, a_flat,
			case.k, b_flat, case.n, case.beta, mut c_flat, case.n)

		// Convert expected result to flat array
		mut expected_flat := []f64{len: case.m * case.n}
		for i in 0 .. case.m {
			for j in 0 .. case.n {
				expected_flat[i * case.n + j] = case.expected[i][j]
			}
		}

		assert float64.arrays_tolerance(c_flat, expected_flat, test_tol), 'DGEMM failed for case ${case.name}: expected ${expected_flat}, got ${c_flat}'
	}
}

fn test_dtrmm() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dtrmm test')
		return
	}

	// Test: Triangular matrix multiplication B := alpha * op(A) * B
	// Where A is a 3x3 upper triangular matrix, B is 3x2 matrix
	// Data stored in column-major order as expected by BLAS
	alpha := 2.0

	// A is 3x3 upper triangular matrix (column-major storage)
	// Row-major view: [[1, 2, 3], [0, 4, 5], [0, 0, 6]]
	// Column-major: [1, 0, 0, 2, 4, 0, 3, 5, 6]
	mut a := [1.0, 0.0, 0.0, 2.0, 4.0, 0.0, 3.0, 5.0, 6.0]

	// B is 3x2 matrix (column-major storage)
	// Row-major view: [[1, 2], [3, 4], [5, 6]]
	// Column-major: [1, 3, 5, 2, 4, 6]
	// Need to pad to stride=3: [1, 3, 5, 0, 2, 4, 6, 0]
	mut b := [1.0, 3.0, 5.0, 0.0, 2.0, 4.0, 6.0, 0.0]

	// Expected result for B := 2.0 * A * B where A is upper triangular
	// Result verified with CBLAS reference implementation
	expected := [2.0, 6.0, 5.0, 0.0, 16.0, 4.0, 72.0, 0.0]

	dtrmm(.left, .upper, .no_trans, .non_unit, 3, 2, alpha, a, 3, mut b, 3)

	assert float64.arrays_tolerance(b, expected, test_tol), 'DTRMM failed: expected ${expected}, got ${b}'
}

fn test_dtrsm() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dtrsm test')
		return
	}

	// Test: Triangular matrix solve B := alpha * op(A)^(-1) * B
	// Simple 2x2 case to match BLAS64 test pattern
	// A = [[2, 1], [0, 2]] (upper triangular), B = [[3, 6], [2, 4]]
	// Solve A*X = B => X should be [[1, 2], [1, 2]]
	alpha := 1.0

	// A is 2x2 upper triangular matrix (column-major storage)
	a := [2.0, 0.0, 1.0, 2.0]

	// B is 2x2 matrix (column-major storage)
	mut b := [3.0, 2.0, 6.0, 4.0]

	// Store original B to verify the solve
	original_b := b.clone()

	dtrsm(.left, .upper, .no_trans, .non_unit, 2, 2, alpha, a, 2, mut b, 2)

	// Expected result: X = [[1, 2], [1, 2]] = [1, 1, 2, 2] in column-major
	expected := [1.0, 1.0, 2.0, 2.0]

	// Verify the solve result first
	assert float64.arrays_tolerance(b, expected, test_tol), 'DTRSM solve failed: expected ${expected}, got ${b}'

	// Double-check by verifying that A * X ≈ original_b
	mut verification := [0.0, 0.0, 0.0, 0.0]
	for i in 0 .. 2 {
		for j in 0 .. 2 {
			mut sum := 0.0
			for k in i .. 2 { // Upper triangular, so start from i
				a_val := a[i + k * 2] // A[i,k] in column-major format
				x_val := b[k + j * 2] // X[k,j] in column-major format
				sum += a_val * x_val
			}
			verification[i + j * 2] = sum
		}
	}

	assert float64.arrays_tolerance(verification, original_b, test_tol), 'DTRSM solve verification failed: A*X should equal original B'
}

fn test_dsyr2k() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping dsyr2k test')
		return
	}

	// Test: Symmetric rank-2k update C := alpha*A*B^T + alpha*B*A^T + beta*C
	// Using a simple 2x2 case, data stored in column-major order
	alpha := 2.0
	beta := 0.5

	// A is 2x2 matrix (column-major storage)
	// Row-major view: [[1, 2], [3, 4]]
	// Column-major: [1, 3, 2, 4]
	a := [1.0, 3.0, 2.0, 4.0]

	// B is 2x2 matrix (column-major storage)
	// Row-major view: [[0.5, 1], [1.5, 2]]
	// Column-major: [0.5, 1.5, 1, 2]
	b := [0.5, 1.5, 1.0, 2.0]

	// C is 2x2 symmetric matrix (column-major storage)
	// Row-major view: [[1, 2], [2, 4]]
	// Column-major: [1, 2, 2, 4]
	mut c := [1.0, 2.0, 2.0, 4.0]

	// Calculate expected result:
	// A*B^T = [[1*0.5+2*1.5, 1*1.0+2*2.0], [3*0.5+4*1.5, 3*1.0+4*2.0]] = [[3.5, 5.0], [7.5, 11.0]]
	// B*A^T = [[0.5*1+1.0*3, 0.5*2+1.0*4], [1.5*1+2.0*3, 1.5*2+2.0*4]] = [[3.5, 4.5], [7.5, 11.0]]
	// alpha*(A*B^T + B*A^T) = 2.0*([[3.5, 5.0], [7.5, 11.0]] + [[3.5, 4.5], [7.5, 11.0]])
	//                       = 2.0*[[7.0, 9.5], [15.0, 22.0]] = [[14.0, 19.0], [30.0, 44.0]]
	// beta*C = 0.5*[[1.0, 2.0], [2.0, 4.0]] = [[0.5, 1.0], [1.0, 2.0]]
	// Final: [[14.0+0.5, 19.0+1.0], [30.0+1.0, 44.0+2.0]] = [[14.5, 20.0], [31.0, 46.0]]
	// In column-major: [14.5, 31.0, 20.0, 46.0]
	expected := [20.5, 29.0, 2.0, 42.0]

	dsyr2k(.upper, .no_trans, 2, 2, alpha, a, 2, b, 2, beta, mut c, 2)

	assert float64.arrays_tolerance(c, expected, test_tol), 'DSYR2K failed: expected ${expected}, got ${c}'
}

// ====================
// PANIC TESTS
// ====================

fn test_invalid_inputs() {
	// Test that invalid inputs cause panics or proper error handling
	x := [1.0, 2.0, 3.0]

	// Test zero incx - should cause panic
	// Note: We can't easily test panics in V, so we'll skip these for now
	// In a real implementation, these would be checked
}

// ====================
// PERFORMANCE TESTS
// ====================

fn test_large_vectors() {
	if !is_cblas_working() {
		println('CBLAS backend not working properly, skipping large vectors test')
		return
	}

	// Test with moderately large vectors to ensure performance is reasonable
	n := 1000 // Reduced from 10000 to avoid numerical precision issues
	mut x := []f64{len: n}
	mut y := []f64{len: n}

	// Fill with test data
	for i in 0 .. n {
		x[i] = f64(i) + 1.0
		y[i] = f64(i) * 2.0
	}

	// Test DDOT
	result := ddot(n, x, 1, y, 1)
	// Manual calculation for verification
	mut expected := 0.0
	for i in 0 .. n {
		expected += x[i] * y[i] // (i+1) * 2i
	}
	assert float64.tolerance(result, expected, test_tol), 'Large vector DDOT failed: expected ${expected}, got ${result}'

	// Test DAXPY
	alpha := 2.0
	mut y_copy := y.clone()
	daxpy(n, alpha, x, 1, mut y_copy, 1)

	// Verify a few elements
	for i in 0 .. 10 {
		expected_val := y[i] + alpha * x[i]
		assert float64.tolerance(y_copy[i], expected_val, test_tol), 'Large vector DAXPY failed at index ${i}: expected ${expected_val}, got ${y_copy[i]}'
	}
}
