module main

import vsl.poly

fn main() {
	// represent the polynomial 2 * x^2 + 5 * x + 4
	// with x = 4, result is 2 * 4^2 + 5 * 4 + 4 = 56
	coef := [4.0, 5, 2]
	result := poly.eval(coef, 4)
	println('Evalutated value: ${result}')
}
