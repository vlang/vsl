module main

import vsl.la

fn main() {
	mut entries := la.Triplet.new[f64](3, 3, 7)
	entries.put(0, 0, 4.0)!
	entries.put(0, 1, 1.0)!
	entries.put(1, 0, 1.0)!
	entries.put(1, 1, 3.0)!
	entries.put(1, 2, 1.0)!
	entries.put(2, 1, 1.0)!
	entries.put(2, 2, 2.0)!

	matrix := entries.to_csr()!
	result := matrix.conjugate_gradient([6.0, 10.0, 8.0], 1e-12, 10)!
	assert result.converged
	assert result.residual_norm < 1e-12
	assert result.x == [1.0, 2.0, 3.0]
	println('solution: ${result.x}, residual: ${result.residual_norm}')
}
