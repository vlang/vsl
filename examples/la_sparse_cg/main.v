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

	mut scaled_entries := la.Triplet.new[f64](3, 3, 3)
	scaled_entries.put(0, 0, 1.0)!
	scaled_entries.put(1, 1, 100.0)!
	scaled_entries.put(2, 2, 10_000.0)!
	scaled := scaled_entries.to_csr()!.preconditioned_conjugate_gradient([2.0, 300.0, 40_000.0],
		1e-12, 10)!
	assert scaled.converged
	assert scaled.x == [2.0, 3.0, 4.0]
	println('Jacobi-preconditioned solution: ${scaled.x}')
}
