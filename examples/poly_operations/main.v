module main

import vsl.poly

fn main() {
	// Addition
	// Degree is not modified unless highest coefficients cancel each other out
	poly_1 := [1.0, 12, 3]
	poly_2 := [3.0, 2, 7]
	result_add := poly.add(poly_1, poly_2)
	println('Addition result: ${result_add}')

	// Substraction
	// Degree is not modified unless highest coefficients cancel each other out
	result_sub := poly.substract(poly_1, poly_2)
	println('Substraction result: ${result_sub}')

	// Multiplication
	// with given degree n and m for poly_1 and poly_2
	// resulting polynomial will be of degree n + m
	result_mult := poly.multiply(poly_1, poly_2)
	println('Multplication result: ${result_mult}')
}
