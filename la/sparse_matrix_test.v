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

fn test_triplet_put_rejects_negative_indices_without_mutating() {
	mut triplet := Triplet.new[f64](2, 2, 2)

	if _ := triplet.put(-1, 0, 1.0) {
		assert false
	}
	if _ := triplet.put(0, -1, 1.0) {
		assert false
	}
	assert triplet.len() == 0
}

fn test_triplet_to_csr_sums_duplicates_and_supports_matvec() {
	mut triplet := Triplet.new[f64](4, 3, 5)
	triplet.put(0, 2, 2.0)!
	triplet.put(0, 2, -2.0)! // cancellation drops this stored entry
	triplet.put(1, 0, 3.0)!
	triplet.put(1, 0, 4.0)!
	triplet.put(3, 1, 5.0)!

	csr := triplet.to_csr()!
	rows, columns := csr.size()
	assert rows == 4
	assert columns == 3
	assert csr.nnz() == 2
	assert csr.to_dense().equals(triplet.to_dense())
	assert csr.matvec([1.0, 2.0, 3.0])! == [0.0, 7.0, 0.0, 10.0]
	assert csr.to_cc().to_dense().equals(csr.to_dense())
	assert triplet.to_cc().to_csr().to_dense().equals(csr.to_dense())

	if _ := csr.matvec([1.0, 2.0]) {
		assert false
	}
}

fn test_csr_rmatvec_handles_rectangular_matrices_and_empty_rows_and_columns() ! {
	mut triplet := Triplet.new[f64](4, 5, 6)
	triplet.put(0, 0, 0.5)!
	triplet.put(0, 0, 0.5)!
	triplet.put(0, 2, 2.0)!
	triplet.put(1, 1, 3.0)!
	triplet.put(3, 0, 4.0)!
	triplet.put(3, 2, 5.0)!

	matrix := triplet.to_csr()!
	assert matrix.rmatvec([2.0, 3.0, 4.0, 5.0])! == [22.0, 9.0, 29.0, 0.0, 0.0]

	if _ := matrix.rmatvec([1.0, 2.0, 3.0]) {
		assert false, 'CSR rmatvec must require one value per matrix row'
	}

	empty := Triplet.new[f64](3, 0, 0).to_csr()!
	assert empty.rmatvec([1.0, 2.0, 3.0])! == []
}

fn test_empty_triplet_converts_to_csr_with_empty_rows() {
	triplet := Triplet.new[f64](3, 0, 0)
	csr := triplet.to_csr()!

	assert csr.nnz() == 0
	assert csr.to_dense().equals(triplet.to_dense())
	assert csr.matvec([])! == [0.0, 0.0, 0.0]
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
