module poly

fn test_eval() {
	// ans = 2
	// ans = 4.0 + 4 * 2 = 12
	// ans = 5 + 4 * 12 = 53
	x := 4
	cof := [4.0, 5, 2]
	assert eval(cof, 4) == 53
}

fn test_swap() {
	mut a := 101.0
	mut b := 202.0
	a, b = swap_(a, b)
	assert a == 202.0 && b == 101.0
}

fn test_add() {
	a := [1.0, 2.0, 3.0]
	b := [6.0, 20.0, -10.0]
	result := add(a, b)
	println('Add result: ${result}')
	assert result == [7.0, 22.0, -7.0]
}

fn test_subtract() {
	a := [6.0, 1532.0, -4.0]
	b := [1.0, -1.0, -5.0]
	result := subtract(a, b)
	println('Subtract result: ${result}')
	assert result == [5.0, 1533.0, 1.0]
}

fn test_multiply() {
	// (2+3x+4x^2) * (-3x+2x^2) = (-6x -5x^2 -6x^3 + 8x^4)
	a := [2.0, 3.0, 4.0]
	b := [0.0, -3.0, 2.0]
	result := multiply(a, b)
	println('Multiply result: ${result}')
	assert result == [0.0, -6.0, -5.0, -6.0, 8.0]
}

fn test_divide() {
	// (x^2 + 2x + 1) / (x + 1) = (x + 1)
	a := [1.0, 2.0, 1.0]
	b := [1.0, 1.0]
	quotient, remainder := divide(a, b)
	println('Divide quotient: ${quotient}')
	println('Divide remainder: ${remainder}')
	assert quotient == [1.0, 1.0]
	assert remainder == [] // The empty set indicates that the two polynomials divide each other exactly (without remainder).
}

fn test_degree() {
	assert degree([4.0, 5.0, 2.0]) == 2 // Degree should be 2
	assert degree([1.0]) == 0 // Degree should be 0 for a single coefficient polynomial
	assert degree([]) == -1 // Degree should be -1 for an empty coefficient array
}

fn test_sum_odd_coeffs() {
	assert sum_odd_coeffs([4.0, 5.0, 2.0]) == 5.0 // 5 is at an odd index
	assert sum_odd_coeffs([7.0, 456.0, 21.0, 87.0]) == 543.0 // 456 and 87 are at odd indices
	assert sum_odd_coeffs([]) == 0.0 // The sum should be 0 for an empty coefficient array
}

fn test_sum_even_coeffs() {
	assert sum_even_coeffs([4.0, 5.0, 2.0]) == 6.0 // 4.0 and 2 are at even indices
	assert sum_even_coeffs([7.0, 456.0, 21.0, 87.0]) == 28.0 // 7 and 21 are at even indices
	assert sum_even_coeffs([]) == 0 // The sum should be 0 for an empty coefficient array
}
