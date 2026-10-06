module la

fn test_matrix_addition_and_subtraction_operators() {
	a := Matrix.deep2([[f64(1), 2], [3, 4]])
	b := Matrix.deep2([[f64(5), 6], [7, 8]])

	sum := a + b
	subtracted := (*b) - (*a)
	assert sum.get(0, 0) == 6
	assert sum.get(1, 1) == 12
	assert subtracted.get(0, 0) == 4
	assert subtracted.get(1, 1) == 4
}

fn test_matrix_multiplication_operator() {
	a := Matrix.deep2([[f64(1), 2], [3, 4]])
	b := Matrix.deep2([[f64(5), 6], [7, 8]])

	product := a * b
	assert product.m == 2
	assert product.n == 2
	assert product.get(0, 0) == 19
	assert product.get(0, 1) == 22
	assert product.get(1, 0) == 43
	assert product.get(1, 1) == 50
}

fn test_matrix_division_operator() {
	a := Matrix.deep2([[f64(2), 4], [6, 8]])
	b := Matrix.deep2([[f64(2), 2], [3, 4]])

	quotient := a / b
	assert quotient.get(0, 0) == 1
	assert quotient.get(0, 1) == 2
	assert quotient.get(1, 0) == 2
	assert quotient.get(1, 1) == 2
}

fn test_integer_matrix_remainder_operator() {
	a := Matrix.deep2([[11, 14], [17, 20]])
	b := Matrix.deep2([[3, 5], [6, 7]])

	remainder := a % b
	assert remainder.get(0, 0) == 2
	assert remainder.get(0, 1) == 4
	assert remainder.get(1, 0) == 5
	assert remainder.get(1, 1) == 6
}

fn test_integer_matrix_multiplication() {
	a := Matrix.deep2([[1, 2], [3, 4]])
	b := Matrix.deep2([[5, 6], [7, 8]])

	product := a * b
	assert product.get(0, 0) == 19
	assert product.get(0, 1) == 22
	assert product.get(1, 0) == 43
	assert product.get(1, 1) == 50
}
