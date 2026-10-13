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

fn test_triplet_to_cc_round_trip_through_dense() {
	mut triplet := Triplet.new[f64](3, 3, 6)
	triplet.put(0, 0, 1.0)!
	triplet.put(2, 0, 2.0)!
	triplet.put(1, 1, 3.0)!
	triplet.put(1, 1, 4.0)! // repeated coordinate sums to 7
	triplet.put(0, 2, 5.0)!

	cc := triplet.to_cc()
	assert cc.to_dense().equals(triplet.to_dense())
	assert cc.to_dense().get(1, 1) == 7.0
}

fn test_cc_matrix_addition_and_subtraction_operators() {
	mut ta := Triplet.new[f64](2, 2, 3)
	ta.put(0, 0, 1.0)!
	ta.put(1, 0, 2.0)!
	ta.put(0, 1, 3.0)!
	mut tb := Triplet.new[f64](2, 2, 3)
	tb.put(0, 0, 10.0)!
	tb.put(1, 1, 4.0)!
	tb.put(0, 1, -3.0)! // cancels the (0, 1) entry in the sum

	a := ta.to_cc()
	b := tb.to_cc()
	sum := (*a) + (*b)
	difference := (*a) - (*b)

	assert sum.to_dense().get(0, 0) == 11.0
	assert sum.to_dense().get(1, 0) == 2.0
	assert sum.to_dense().get(0, 1) == 0.0
	assert sum.to_dense().get(1, 1) == 4.0
	assert difference.to_dense().get(0, 0) == -9.0
	assert difference.to_dense().get(0, 1) == 6.0
	assert difference.to_dense().get(1, 1) == -4.0
}

fn test_triplet_to_dense_ignores_entries_after_start() {
	mut triplet := Triplet.new[f64](2, 2, 4)
	triplet.put(1, 1, 7.0)!
	assert triplet.to_dense().get(1, 1) == 7.0

	triplet.start()
	assert triplet.to_dense().get(1, 1) == 0.0
}
