module main

import vsl.poly

fn main() {
	// Addition
	// Degree is not modified unless highest coefficients cancel each other out
	poly_1 := [1.0, 12, 3]
	poly_2 := [3.0, 2, 7]
	result_add := poly.add(poly_1, poly_2)
	println('Addition result: ${result_add}')

	// Subtraction
	// Degree is not modified unless highest coefficients cancel each other out
	result_sub := poly.subtract(poly_1, poly_2)
	println('Subtraction result: ${result_sub}')

	// Multiplication
	// with given degree n and m for poly_1 and poly_2
	// resulting polynomial will be of degree n + m
	result_mult := poly.multiply(poly_1, poly_2)
	println('Multplication result: ${result_mult}')
}
