module main

import vsl.poly

fn main() {
	println('== polynomial evaluation ==')
	coeffs := [1.0, -3.0, 2.0] // P(x) = 1 - 3x + 2x^2
	x := 4.0
	p := poly.eval(coeffs, x)
	println('P(${x}) = ${p}')

	println('\n== polynomial operations ==')
	a := [1.0, 2.0, 3.0]
	b := [4.0, 5.0]
	println('a + b = ${poly.add(a, b)}')
	println('a - b = ${poly.subtract(a, b)}')
	println('a * b = ${poly.multiply(a, b)}')

	println('\n== roots ==')
	println('quadratic roots of x^2 - 3x + 2: ${poly.solve_quadratic(1.0, -3.0, 2.0)}')
	println('cubic roots of x^3 - 6x^2 + 11x - 6: ${poly.solve_cubic(-6.0, 11.0, -6.0)}')

	println('\n== metadata ==')
	println('degree(a) = ${poly.degree(a)}')
	println('sum odd coeffs(a) = ${poly.sum_odd_coeffs(a)}')
	println('sum even coeffs(a) = ${poly.sum_even_coeffs(a)}')
}
