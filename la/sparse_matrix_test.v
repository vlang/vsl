module la

fn test_triplet() {
	mut a := Triplet.new[f64](4, 4, 6)

	a.put(1, 0, 1.0)!
	a.put(0, 1, 2.0)!
	a.put(3, 1, 3.0)!
	a.put(1, 2, 4.0)!
	a.put(2, 3, 5.0)!
	a.put(3, 3, 6.0)!

	mut expected_matrix := Matrix.deep2([
		[0.0, 2, 0, 0],
		[1.0, 0, 4, 0],
		[0.0, 0, 0, 5],
		[0.0, 3, 0, 6],
	])

	m := a.to_dense()

	assert expected_matrix.equals(m)
}

fn test_triplet_to_dense_ignores_entries_after_start() {
	mut triplet := Triplet.new[f64](2, 2, 4)
	triplet.put(1, 1, 7.0)!
	assert triplet.to_dense().get(1, 1) == 7.0

	triplet.start()
	assert triplet.to_dense().get(1, 1) == 0.0
}
