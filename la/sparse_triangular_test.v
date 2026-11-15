module la

import math

fn test_csr_lower_triangular_solve_matches_known_solution() {
	mut entries := Triplet.new[f64](3, 3, 6)
	entries.put(0, 0, 2.0)!
	entries.put(1, 0, 3.0)!
	entries.put(1, 1, 1.0)!
	entries.put(2, 0, 1.0)!
	entries.put(2, 1, -1.0)!
	entries.put(2, 2, 4.0)!
	matrix := entries.to_csr()!

	assert matrix.solve_lower_triangular([2.0, 5.0, -5.0])! == [1.0, 2.0, -1.0]
}

fn test_csr_upper_triangular_solve_matches_known_solution() {
	mut entries := Triplet.new[f64](3, 3, 6)
	entries.put(0, 0, 2.0)!
	entries.put(0, 1, 3.0)!
	entries.put(0, 2, 1.0)!
	entries.put(1, 1, 1.0)!
	entries.put(1, 2, -1.0)!
	entries.put(2, 2, 4.0)!
	matrix := entries.to_csr()!

	assert matrix.solve_upper_triangular([7.0, 3.0, -4.0])! == [1.0, 2.0, -1.0]
}

fn test_csr_triangular_solve_rejects_invalid_shapes_and_non_finite_rhs() {
	mut rectangular_entries := Triplet.new[f64](2, 3, 2)
	rectangular_entries.put(0, 0, 1.0)!
	rectangular_entries.put(1, 1, 1.0)!
	rectangular := rectangular_entries.to_csr()!
	if _ := rectangular.solve_lower_triangular([1.0, 2.0]) {
		assert false, 'triangular solve must reject non-square matrices'
	} else {
		assert err.msg().contains('square')
	}

	mut entries := Triplet.new[f64](2, 2, 2)
	entries.put(0, 0, 1.0)!
	entries.put(1, 1, 1.0)!
	matrix := entries.to_csr()!
	if _ := matrix.solve_upper_triangular([1.0]) {
		assert false, 'triangular solve must validate rhs length'
	} else {
		assert err.msg().contains('right-hand side length')
	}
	if _ := matrix.solve_lower_triangular([1.0, math.nan()]) {
		assert false, 'triangular solve must reject a non-finite rhs'
	} else {
		assert err.msg().contains('finite')
	}
}

fn test_csr_triangular_solve_rejects_wrong_structure_and_missing_diagonal() {
	mut upper_entries := Triplet.new[f64](2, 2, 3)
	upper_entries.put(0, 0, 1.0)!
	upper_entries.put(0, 1, 2.0)!
	upper_entries.put(1, 1, 1.0)!
	upper := upper_entries.to_csr()!
	if _ := upper.solve_lower_triangular([1.0, 2.0]) {
		assert false, 'lower solve must reject an entry above the diagonal'
	} else {
		assert err.msg().contains('lower-triangular')
	}

	mut missing_diagonal_entries := Triplet.new[f64](2, 2, 2)
	missing_diagonal_entries.put(0, 0, 1.0)!
	missing_diagonal_entries.put(1, 0, 2.0)!
	missing_diagonal := missing_diagonal_entries.to_csr()!
	if _ := missing_diagonal.solve_lower_triangular([1.0, 2.0]) {
		assert false, 'triangular solve must reject a missing diagonal'
	} else {
		assert err.msg().contains('nonzero diagonal')
	}
}

fn test_csr_triangular_solve_rejects_non_finite_matrix_and_result() {
	mut non_finite_entries := Triplet.new[f64](1, 1, 1)
	non_finite_entries.put(0, 0, math.nan())!
	non_finite := non_finite_entries.to_csr()!
	if _ := non_finite.solve_lower_triangular([1.0]) {
		assert false, 'triangular solve must reject non-finite matrix values'
	} else {
		assert err.msg().contains('matrix values')
	}

	mut overflow_entries := Triplet.new[f64](1, 1, 1)
	overflow_entries.put(0, 0, 1e-308)!
	overflow := overflow_entries.to_csr()!
	if _ := overflow.solve_lower_triangular([1e308]) {
		assert false, 'triangular solve must reject a non-finite solution'
	} else {
		assert err.msg().contains('non-finite')
	}
}
