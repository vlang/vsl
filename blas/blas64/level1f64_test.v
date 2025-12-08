module blas64

import vsl.float.float64
import math

// ====================
// LEVEL 1 BLAS TESTS
// ====================

fn test_ddot() {
	// Test case 1: Basic dot product
	x1 := [1.0, 2.0, 3.0]
	y1 := [4.0, 5.0, 6.0]
	result1 := ddot(3, x1, 1, y1, 1)
	expected1 := 32.0 // 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
	assert float64.tolerance(result1, expected1, test_tol), 'DDOT test 1 failed: expected ${expected1}, got ${result1}'

	// Test case 2: Zero vector
	x2 := [0.0, 0.0, 0.0]
	y2 := [1.0, 2.0, 3.0]
	result2 := ddot(3, x2, 1, y2, 1)
	expected2 := 0.0
	assert float64.tolerance(result2, expected2, test_tol), 'DDOT test 2 failed: expected ${expected2}, got ${result2}'

	// Test case 3: Stride test
	x3 := [1.0, 100.0, 2.0, 200.0, 3.0, 300.0]
	y3 := [4.0, 400.0, 5.0, 500.0, 6.0, 600.0]
	result3 := ddot(3, x3, 2, y3, 2)
	expected3 := 32.0 // Same as test 1, using stride 2
	assert float64.tolerance(result3, expected3, test_tol), 'DDOT test 3 failed: expected ${expected3}, got ${result3}'
}

fn test_dnrm2() {
	// Test case 1: Basic norm
	x1 := [3.0, 4.0]
	result1 := dnrm2(2, x1, 1)
	expected1 := 5.0 // sqrt(3^2 + 4^2) = sqrt(9 + 16) = sqrt(25) = 5
	assert float64.tolerance(result1, expected1, test_tol), 'DNRM2 test 1 failed: expected ${expected1}, got ${result1}'

	// Test case 2: Zero vector
	x2 := [0.0, 0.0, 0.0]
	result2 := dnrm2(3, x2, 1)
	expected2 := 0.0
	assert float64.tolerance(result2, expected2, test_tol), 'DNRM2 test 2 failed: expected ${expected2}, got ${result2}'

	// Test case 3: Larger vector
	x3 := [1.0, 2.0, 3.0, 4.0, 5.0]
	result3 := dnrm2(5, x3, 1)
	expected3 := math.sqrt(55.0) // sqrt(1 + 4 + 9 + 16 + 25) = sqrt(55)
	assert float64.tolerance(result3, expected3, test_tol), 'DNRM2 test 3 failed: expected ${expected3}, got ${result3}'
}

fn test_dasum() {
	// Test case 1: Basic sum
	x1 := [1.0, -2.0, 3.0, -4.0]
	result1 := dasum(4, x1, 1)
	expected1 := 10.0 // |1| + |-2| + |3| + |-4| = 1 + 2 + 3 + 4 = 10
	assert float64.tolerance(result1, expected1, test_tol), 'DASUM test 1 failed: expected ${expected1}, got ${result1}'

	// Test case 2: All positive
	x2 := [1.0, 2.0, 3.0, 4.0]
	result2 := dasum(4, x2, 1)
	expected2 := 10.0
	assert float64.tolerance(result2, expected2, test_tol), 'DASUM test 2 failed: expected ${expected2}, got ${result2}'

	// Test case 3: Stride test
	x3 := [1.0, 100.0, -2.0, 200.0, 3.0, 300.0]
	result3 := dasum(3, x3, 2)
	expected3 := 6.0 // |1| + |-2| + |3| = 1 + 2 + 3 = 6
	assert float64.tolerance(result3, expected3, test_tol), 'DASUM test 3 failed: expected ${expected3}, got ${result3}'
}

fn test_idamax() {
	// Test case 1: Basic test
	x1 := [1.0, -5.0, 3.0, 2.0]
	result1 := idamax(4, x1, 1)
	expected1 := 1 // Index of -5.0 (largest absolute value)
	assert result1 == expected1, 'IDAMAX test 1 failed: expected ${expected1}, got ${result1}'

	// Test case 2: Last element is max
	x2 := [1.0, 2.0, 3.0, 6.0]
	result2 := idamax(4, x2, 1)
	expected2 := 3 // Index of 6.0
	assert result2 == expected2, 'IDAMAX test 2 failed: expected ${expected2}, got ${result2}'

	// Test case 3: Stride test
	x3 := [1.0, 100.0, 8.0, 200.0, 3.0, 300.0]
	result3 := idamax(3, x3, 2)
	expected3 := 1 // Index of 8.0 (among elements [1.0, 8.0, 3.0])
	assert result3 == expected3, 'IDAMAX test 3 failed: expected ${expected3}, got ${result3}'
}

fn test_dscal() {
	// Test case 1: Basic scaling
	mut x1 := [1.0, 2.0, 3.0, 4.0]
	dscal(4, 2.0, mut x1, 1)
	expected1 := [2.0, 4.0, 6.0, 8.0]
	assert float64.arrays_tolerance(x1, expected1, test_tol), 'DSCAL test 1 failed: expected ${expected1}, got ${x1}'

	// Test case 2: Zero scaling
	mut x2 := [1.0, 2.0, 3.0, 4.0]
	dscal(4, 0.0, mut x2, 1)
	expected2 := [0.0, 0.0, 0.0, 0.0]
	assert float64.arrays_tolerance(x2, expected2, test_tol), 'DSCAL test 2 failed: expected ${expected2}, got ${x2}'

	// Test case 3: Negative scaling
	mut x3 := [1.0, 2.0, 3.0, 4.0]
	dscal(4, -1.0, mut x3, 1)
	expected3 := [-1.0, -2.0, -3.0, -4.0]
	assert float64.arrays_tolerance(x3, expected3, test_tol), 'DSCAL test 3 failed: expected ${expected3}, got ${x3}'
}

fn test_dcopy() {
	// Test case 1: Basic copy
	x1 := [1.0, 2.0, 3.0, 4.0]
	mut y1 := [0.0, 0.0, 0.0, 0.0]
	dcopy(4, x1, 1, mut y1, 1)
	assert float64.arrays_tolerance(y1, x1, test_tol), 'DCOPY test 1 failed: expected ${x1}, got ${y1}'

	// Test case 2: Stride copy
	x2 := [1.0, 100.0, 2.0, 200.0, 3.0, 300.0]
	mut y2 := [0.0, 0.0, 0.0]
	dcopy(3, x2, 2, mut y2, 1)
	expected2 := [1.0, 2.0, 3.0]
	assert float64.arrays_tolerance(y2, expected2, test_tol), 'DCOPY test 2 failed: expected ${expected2}, got ${y2}'
}

fn test_daxpy() {
	// Test case 1: Basic AXPY operation
	x1 := [1.0, 2.0, 3.0]
	mut y1 := [4.0, 5.0, 6.0]
	daxpy(3, 2.0, x1, 1, mut y1, 1)
	expected1 := [6.0, 9.0, 12.0] // y = 2*x + y = 2*[1,2,3] + [4,5,6] = [2,4,6] + [4,5,6] = [6,9,12]
	assert float64.arrays_tolerance(y1, expected1, test_tol), 'DAXPY test 1 failed: expected ${expected1}, got ${y1}'

	// Test case 2: Zero alpha
	x2 := [1.0, 2.0, 3.0]
	mut y2 := [4.0, 5.0, 6.0]
	daxpy(3, 0.0, x2, 1, mut y2, 1)
	expected2 := [4.0, 5.0, 6.0] // y unchanged
	assert float64.arrays_tolerance(y2, expected2, test_tol), 'DAXPY test 2 failed: expected ${expected2}, got ${y2}'

	// Test case 3: Negative alpha
	x3 := [1.0, 2.0, 3.0]
	mut y3 := [4.0, 5.0, 6.0]
	daxpy(3, -1.0, x3, 1, mut y3, 1)
	expected3 := [3.0, 3.0, 3.0] // y = -1*x + y = -[1,2,3] + [4,5,6] = [-1,-2,-3] + [4,5,6] = [3,3,3]
	assert float64.arrays_tolerance(y3, expected3, test_tol), 'DAXPY test 3 failed: expected ${expected3}, got ${y3}'
}

fn test_dswap() {
	// Test case 1: Basic swap
	mut x1 := [1.0, 2.0, 3.0]
	mut y1 := [4.0, 5.0, 6.0]
	x1_orig := x1.clone()
	y1_orig := y1.clone()
	dswap(3, mut x1, 1, mut y1, 1)
	assert float64.arrays_tolerance(x1, y1_orig, test_tol), 'DSWAP test 1 failed: x should equal original y, got ${x1}'
	assert float64.arrays_tolerance(y1, x1_orig, test_tol), 'DSWAP test 1 failed: y should equal original x, got ${y1}'

	// Test case 2: Stride swap
	mut x2 := [1.0, 100.0, 2.0, 200.0, 3.0, 300.0]
	mut y2 := [4.0, 400.0, 5.0, 500.0, 6.0, 600.0]
	dswap(3, mut x2, 2, mut y2, 2)
	expected_x2 := [4.0, 100.0, 5.0, 200.0, 6.0, 300.0]
	expected_y2 := [1.0, 400.0, 2.0, 500.0, 3.0, 600.0]
	assert float64.arrays_tolerance(x2, expected_x2, test_tol), 'DSWAP test 2 failed: expected x=${expected_x2}, got ${x2}'
	assert float64.arrays_tolerance(y2, expected_y2, test_tol), 'DSWAP test 2 failed: expected y=${expected_y2}, got ${y2}'
}

fn test_drotg() {
	// Test case 1: Basic rotation parameters
	a := 3.0
	b := 4.0
	c, s, r, z := drotg(a, b)

	// Expected: r = sqrt(a^2 + b^2) = sqrt(9 + 16) = 5
	expected_r := 5.0
	assert float64.tolerance(r, expected_r, test_tol), 'DROTG test 1 failed: expected r=${expected_r}, got ${r}'

	// c = a/r = 3/5 = 0.6, s = b/r = 4/5 = 0.8
	expected_c := 0.6
	expected_s := 0.8
	assert float64.tolerance(c, expected_c, test_tol), 'DROTG test 1 failed: expected c=${expected_c}, got ${c}'
	assert float64.tolerance(s, expected_s, test_tol), 'DROTG test 1 failed: expected s=${expected_s}, got ${s}'

	// Test case 2: Zero b
	a2 := 5.0
	b2 := 0.0
	c2, s2, r2, z2 := drotg(a2, b2)
	expected_r2 := 5.0
	expected_c2 := 1.0
	expected_s2 := 0.0
	assert float64.tolerance(r2, expected_r2, test_tol), 'DROTG test 2 failed: expected r=${expected_r2}, got ${r2}'
	assert float64.tolerance(c2, expected_c2, test_tol), 'DROTG test 2 failed: expected c=${expected_c2}, got ${c2}'
	assert float64.tolerance(s2, expected_s2, test_tol), 'DROTG test 2 failed: expected s=${expected_s2}, got ${s2}'
}

fn test_drot() {
	// Test case 1: Basic rotation
	mut x1 := [1.0, 0.0]
	mut y1 := [0.0, 1.0]
	c := math.cos(math.pi / 4) // 45 degrees
	s := math.sin(math.pi / 4)
	drot(2, mut x1, 1, mut y1, 1, c, s)

	expected_val := 1.0 / math.sqrt(2) // approximately 0.7071
	expected_x1 := [expected_val, expected_val]
	expected_y1 := [-expected_val, expected_val]

	assert float64.tolerance(x1[0], expected_x1[0], test_tol), 'DROT test 1 failed: expected x[0]=${expected_x1[0]}, got ${x1[0]}'
	assert float64.tolerance(x1[1], expected_x1[1], test_tol), 'DROT test 1 failed: expected x[1]=${expected_x1[1]}, got ${x1[1]}'
	assert float64.tolerance(y1[0], expected_y1[0], test_tol), 'DROT test 1 failed: expected y[0]=${expected_y1[0]}, got ${y1[0]}'
	assert float64.tolerance(y1[1], expected_y1[1], test_tol), 'DROT test 1 failed: expected y[1]=${expected_y1[1]}, got ${y1[1]}'
}
