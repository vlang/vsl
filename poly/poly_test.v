module poly

fn test_eval() {
	x := 4
	coef := [4.0, 5, 2]
	assert eval(coef, 4) == 56
}

fn test_eval_derivs() {
	coef := [4.0, 3.0, 2.0]
	x := 1.0
	lenres := 3
	assert eval_derivs(coef, x, lenres) == [9.0, 7.0, 4.0]
}

fn test_solve_quadratic() {
	a := 1.0
	b := -3.0
	c := 2.0
	roots := solve_quadratic(a, b, c)
	assert roots == [1.0, 2.0]
}

fn test_swap() {
	mut a := 101.0
	mut b := 202.0
	a, b = swap_(a, b)
	assert a == 202.0 && b == 101.0
}

fn test_sorted_3_() {
	a := 5.0
	b := 7.0
	c := -8.0
	x, y, z := sorted_3_(a, b, c)
	assert x == -8.0 && y == 5.0 && z == 7.0
}

fn test_companion_matrix() {
	coef := [2.0, -4.0, 3.0, -5.0]
	assert companion_matrix(coef) == [
		[0.0, 0.0, 0.4],
		[1.0, 0.0, -0.8],
		[0.0, 1.0, 0.6],
	]
}

fn test_balance_companion_matrix() {
	coef := [2.0, -4.0, 3.0, -5.0]
	matrix := companion_matrix(coef)
	assert balance_companion_matrix(matrix) == [
		[0.0, 0.0, 0.8],
		[0.5, 0.0, -0.8],
		[0.0, 1.0, 0.6],
	]
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
	a := [0.0, 0.0, 1.0, 1.0]
	b := [-2.0, 1.0, 1]
	mut quotient, mut remainder := divide(a, b)
	assert quotient == [0.0, 1.0]
	assert remainder == [0.0, 2.0]

	c := [5.0, -11.0, -7.0, 4.0]
	d := [5.0, 4.0]
	quotient, remainder = divide(c, d)
	assert quotient == [1.0, -3.0, 1]
	assert remainder == []
}
