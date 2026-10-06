module main

import vsl.poly

fn main() {
	quadratic_roots := poly.solve_quadratic(1.0, -3.0, 2.0)
	cubic_roots := poly.solve_cubic(-6.0, 11.0, -6.0)
	println('roots of x^2 - 3x + 2: ${quadratic_roots}')
	println('roots of x^3 - 6x^2 + 11x - 6: ${cubic_roots}')
}
