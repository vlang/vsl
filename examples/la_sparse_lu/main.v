module main

import vsl.la

fn main() {
	mut entries := la.Triplet.new[f64](3, 3, 7)
	entries.put(0, 1, 2.0)!
	entries.put(0, 2, 1.0)!
	entries.put(1, 0, 1.0)!
	entries.put(1, 1, -2.0)!
	entries.put(1, 2, -3.0)!
	entries.put(2, 0, 2.0)!
	entries.put(2, 1, 3.0)!
	entries.put(2, 2, 1.0)!

	matrix := entries.to_csr()!
	factor := matrix.factorize_lu()!
	first_solution := factor.solve([3.0, 0.0, 7.0])!
	println('first solution: ${first_solution}')

	second_solution := [2.0, -1.0, 3.0]
	second_rhs := matrix.matvec(second_solution)!
	println('reused factor solution: ${factor.solve(second_rhs)!}')
}
