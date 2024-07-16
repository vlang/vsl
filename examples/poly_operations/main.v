module main

import vsl.poly

fn main() {
	// Addition
	// Degree is not modified unless highest coefficients cancel each other out
	poly_1 := [1.0, 12, 3] // 1 + 12x + 3x^2
	poly_2 := [3.0, 2, 7] // 3 + 2x + 7x^2
	result_add := poly.add(poly_1, poly_2)
	println('Addition result: ${result_add}') // Expected: [4.0, 14.0, 10.0] (4 + 14x + 10x^2)

	// Subtraction
	// Degree is not modified unless highest coefficients cancel each other out
	result_sub := poly.subtract(poly_1, poly_2)
	println('Subtraction result: ${result_sub}') // Expected: [-2.0, 10.0, -4.0] (-2 + 10x - 4x^2)

	// Multiplication
	// with given degree n and m for poly_1 and poly_2
	// resulting polynomial will be of degree n + m
	result_mult := poly.multiply(poly_1, poly_2)
	println('Multplication result: ${result_mult}') // Expected: [3.0, 38.0, 40.0, 90.0, 21.0] (3 + 38x + 400x^2 + 90x^3 + 21x^4)

	// Division
	// Result includes the quotient and the remainder
	// To get the real remainder, divide it by the divisor.
	poly_dividend := [2.0, -4.0, -4.0, 1.0] // 2 - 4x - 4x^2 + x^3
	poly_divisor := [-2.0, 1.0] // -2 + x
	quotient, remainder := poly.divide(poly_dividend, poly_divisor)
	println('Division quotient: ${quotient}') // Expected quotient: [-8.0, -2.0, 1.0] (-8 - 2x + x^2)
	println('Division remainder: ${remainder}') // Expected remainder: [-14.0]
	// Real remainder: -14 / (-2 + x)
}
