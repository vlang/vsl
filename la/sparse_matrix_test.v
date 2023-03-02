module la

fn test_triplet() {
	mut a := new_triplet[f64](4, 4, 6)

	a.put(1, 0, 1.0)!
	a.put(0, 1, 2.0)!
	a.put(3, 1, 3.0)!
	a.put(1, 2, 4.0)!
	a.put(2, 3, 5.0)!
	a.put(3, 3, 6.0)!

	mut expected_matrix := matrix_deep2([
		[0.0, 2, 0, 0],
		[1.0, 0, 4, 0],
		[0.0, 0, 0, 5],
		[0.0, 3, 0, 6],
	])

	m := a.to_dense()

	assert expected_matrix.equals(m)
}
