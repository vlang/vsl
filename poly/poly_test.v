module poly

fn test_eval() {
	// ans = 2
	// ans = 5 + 4 * 2 = 13
	// ans = 4 + 4 * 13 = 56
	x := 4
	cof := [4.0, 5, 2]
	assert eval(cof, 4) == 56
}

fn test_eval_derivs() {
	cof := [4.0, 3.0, 2.0]
	x := 1.0
	lenres := 3
	assert eval_derivs(cof, x, lenres) == [9.0, 7.0, 4.0]
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

fn test_add() {
	a := [6.0, 777, -3]
	b := [1.0, -755, -4]
	assert add(a, b) == [7.0, 22, -7]
}

fn test_subtract() {
	a := [6.0, 777, -3]
	b := [1.0, -755, -4]
	assert subtract(a, b) == [5.0, 1532, 1]
}

fn test_multiply() {
	a := [9.0, -1, 5]
	b := [0.0, -1, 7]
	assert multiply(a, b) == [0.0, -9, 64, -12, 35, 0]
}

fn test_division() {
	dividend := [6.0, -5.0, 1.0]
	divisor := [2.0, 1.0]
	quotient, remainder := divide(dividend, divisor)
	assert quotient == [-7.0, 1] && remainder == [20.0]
}
