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

fn test_matrix_scalar_arithmetic_methods() {
	a := Matrix.deep2([[f64(1), 2], [3, 4]])

	sum := a.add_scalar(2.0)
	subtracted := a.sub_scalar(1.0)
	scaled := a.scale(2.0)
	quotient := a.div_scalar(2.0)

	assert sum.get(0, 0) == 3
	assert sum.get(1, 1) == 6
	assert subtracted.get(0, 0) == 0
	assert subtracted.get(1, 1) == 3
	assert scaled.get(0, 0) == 2
	assert scaled.get(1, 1) == 8
	assert quotient.get(0, 0) == 0.5
	assert quotient.get(1, 1) == 2
	assert a.get(0, 0) == 1
	assert a.get(1, 1) == 4
}

fn test_f32_matrix_scalar_arithmetic() {
	mut a := Matrix.new[f32](1, 2)
	a.set(0, 0, 2)
	a.set(0, 1, 4)

	scaled := a.scale(f32(0.5))
	sum := a.add_scalar(f32(1))

	assert scaled.m == 1
	assert scaled.n == 2
	assert scaled.get(0, 0) == 1
	assert scaled.get(0, 1) == 2
	assert sum.get(0, 0) == 3
	assert sum.get(0, 1) == 5
}

fn test_integer_matrix_scalar_remainder_operator() {
	a := Matrix.deep2([[11, 14], [17, 20]])
	remainder := a.remainder_scalar(6)

	assert remainder.get(0, 0) == 5
	assert remainder.get(0, 1) == 2
	assert remainder.get(1, 0) == 5
	assert remainder.get(1, 1) == 2
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

fn test_f64_matrix_multiplication_operator_dispatches_large_products() {
	mut a := Matrix.new[f64](8, 8)
	mut b := Matrix.new[f64](8, 8)
	for row in 0 .. 8 {
		for column in 0 .. 8 {
			a.set(row, column, f64(row * 8 + column + 1))
		}
		b.set(row, row, 2)
	}

	product := a * b
	assert product.m == 8
	assert product.n == 8
	assert product.get(0, 0) == 2
	assert product.get(0, 7) == 16
	assert product.get(7, 0) == 114
	assert product.get(7, 7) == 128
}

fn test_f32_matrix_multiplication_operator_dispatches_large_products() {
	mut a := Matrix.new[f32](8, 8)
	mut b := Matrix.new[f32](8, 8)
	for row in 0 .. 8 {
		for column in 0 .. 8 {
			a.set(row, column, f32(row * 8 + column + 1))
		}
		b.set(row, row, 2)
	}

	product := a * b
	assert product.m == 8
	assert product.n == 8
	assert product.get(0, 0) == 2
	assert product.get(0, 7) == 16
	assert product.get(7, 0) == 114
	assert product.get(7, 7) == 128
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
