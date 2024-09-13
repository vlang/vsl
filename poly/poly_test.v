module poly

import math

fn test_eval() {
	// ans = 2
	// ans = 5 + 4 * 2 = 13
	// ans = 4 + 4 * 13 = 56
	x := 4
	cof := [4.0, 5, 2]
	assert eval(cof, 4) == 56
}

fn test_swap() {
	mut a := 101.0
	mut b := 202.0
	a, b = swap_(a, b)
	assert a == 202.0 && b == 101.0
}

fn test_sorted_3_() {
	for values in [[5.0, 7.0, -8.0], [-8.0, 5.0, 7.0], [7.0, -8.0, 5.0]] {
		x, y, z := sorted_3_(values[0], values[1], values[2])
		assert x == -8.0
		assert y == 5.0
		assert z == 7.0
	}
}

fn test_add() {
	a := [1.0, 2.0, 3.0]
	b := [6.0, 20.0, -10.0]
	result := add(a, b)
	assert result == [7.0, 22.0, -7.0]
}

fn test_subtract() {
	a := [6.0, 1532.0, -4.0]
	b := [1.0, -1.0, -5.0]
	result := subtract(a, b)
	assert result == [5.0, 1533.0, 1.0]
}

fn test_multiply() {
	// (2+3x+4x^2) * (-3x+2x^2) = (-6x -5x^2 -6x^3 + 8x^4)
	a := [2.0, 3.0, 4.0]
	b := [0.0, -3.0, 2.0]
	result := multiply(a, b)
	assert result == [0.0, -6.0, -5.0, -6.0, 8.0]
}

fn test_divide() {
	// (x^2 + 2x + 1) / (x + 1) = (x + 1)
	a := [1.0, 2.0, 1.0]
	b := [1.0, 1.0]
	quotient, remainder := divide(a, b)
	assert quotient == [1.0, 1.0]
	assert remainder == [] // Empty remainder means exact division.

	a2 := [0.0, 0.0, 1.0, 1.0]
	b2 := [-2.0, 1.0, 1]
	quotient2, remainder2 := divide(a2, b2)
	assert quotient2 == [0.0, 1.0]
	assert remainder2 == [0.0, 2.0]

	c := [5.0, -11.0, -7.0, 4.0]
	d := [5.0, 4.0]
	quotient3, remainder3 := divide(c, d)
	assert quotient3 == [1.0, -3.0, 1]
	assert remainder3 == []

	quotient4, remainder4 := divide([1.0, 2.0], [1.0, 2.0, 3.0])
	assert quotient4 == []
	assert remainder4 == [1.0, 2.0]

	quotient5, remainder5 := divide([1.0, 2.0, 1.0, 0.0], [1.0, 1.0, 0.0])
	assert quotient5 == [1.0, 1.0]
	assert remainder5 == []
}

fn test_degree() {
	assert degree([4.0, 5.0, 2.0]) == 2
	assert degree([1.0]) == 0
	assert degree([]) == -1
}

fn test_sum_odd_coeffs() {
	assert sum_odd_coeffs([4.0, 5.0, 2.0]) == 5.0
	assert sum_odd_coeffs([7.0, 456.0, 21.0, 87.0]) == 543.0
	assert sum_odd_coeffs([]) == 0.0
}

fn test_sum_even_coeffs() {
	assert sum_even_coeffs([4.0, 5.0, 2.0]) == 6.0
	assert sum_even_coeffs([7.0, 456.0, 21.0, 87.0]) == 28.0
	assert sum_even_coeffs([]) == 0.0
}

fn test_eval_derivs() {
	coeffs := [1.0, 2.0, 3.0]
	res := eval_derivs(coeffs, 2.0, 3)
	assert res.len == 3
	assert math.abs(res[0] - 17.0) < 1e-12
	assert math.abs(res[1] - 14.0) < 1e-12
	assert math.abs(res[2] - 6.0) < 1e-12
}

fn test_solve_quadratic_roots() {
	roots := solve_quadratic(1.0, -3.0, 2.0)
	assert roots.len == 2
	assert math.abs(roots[0] - 1.0) < 1e-12
	assert math.abs(roots[1] - 2.0) < 1e-12
}

fn test_solve_cubic_roots() {
	roots := solve_cubic(-6.0, 11.0, -6.0)
	assert roots.len == 3
	mut sorted := roots.clone()
	sorted.sort()
	assert math.abs(sorted[0] - 1.0) < 1e-12
	assert math.abs(sorted[1] - 2.0) < 1e-12
	assert math.abs(sorted[2] - 3.0) < 1e-12
}

fn test_companion_matrix() {
	cm := companion_matrix([2.0, -3.0, 1.0])
	assert cm.len == 2
	assert cm[0].len == 2
	assert cm[1].len == 2
	assert math.abs(cm[0][0] - 0.0) < 1e-12
	assert math.abs(cm[0][1] + 2.0) < 1e-12
	assert math.abs(cm[1][0] - 1.0) < 1e-12
	assert math.abs(cm[1][1] - 3.0) < 1e-12
}
