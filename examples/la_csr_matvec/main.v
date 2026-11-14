module main

import vsl.la

fn main() {
	mut entries := la.Triplet.new[f64](3, 3, 3)
	entries.put(0, 0, 2.0)!
	entries.put(1, 0, 3.0)!
	entries.put(2, 2, 4.0)!

	matrix := entries.to_csr()!
	result := matrix.matvec([1.0, 2.0, 3.0])!
	assert result == [2.0, 3.0, 12.0]
	println(result)
}
