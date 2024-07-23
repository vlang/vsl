module main

import vsl.poly

fn main() {
  // Polynomial coefficients for p(x) = 2x^3 -4x^2 + 3x - 5
	coef := [2.0, -4.0, 3.0, -5.0]

  // For the polynomial p(x) = a_n x^n + a_{n-1} x^{n-1} + ... + a_1 x + a_0
	// The companion matrix C will be:
	// [ 0    0    0   -a_0/a_n ]
	// [ 1    0    0   -a_1/a_n ]
	// [ 0    1    0   -a_2/a_n ]
	// [ 0    0    1   -a_3/a_n ]
	comp_matrix := poly.companion_matrix(coef)
	println("Companion matrix:")
	for row in comp_matrix {
		println(row)
	}

	// Balancing matrix if needed
  balanced_matrix := poly.balance_companion_matrix(comp_matrix)
  println("Balanced companion matrix:")
	for row in balanced_matrix {
		println(row)
	}
}
