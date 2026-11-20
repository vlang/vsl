module main

import vsl.la

fn main() {
	mut entries := la.Triplet.new[f64](3, 2, 3)
	entries.put(0, 0, 2.0)!
	entries.put(1, 1, 3.0)!
	entries.put(2, 0, 4.0)!

	matrix := entries.to_csr()!
	result := matrix.rmatvec([1.0, 2.0, 3.0])!
	assert result == [14.0, 6.0]
	println(result)
}
