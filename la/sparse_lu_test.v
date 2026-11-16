module la

import math

fn sparse_lu_matrix(values [][]f64) !&CSRMatrix[f64] {
	n := values.len
	mut entries := Triplet.new[f64](n, n, n * n)
	for row in 0 .. n {
		for column in 0 .. values[row].len {
			if values[row][column] != 0.0 {
				entries.put(row, column, values[row][column])!
			}
		}
	}
	return entries.to_csr()
}

fn sparse_lu_dense_residual_norm(matrix &CSRMatrix[f64], solution []f64, rhs []f64) f64 {
	dense := matrix.to_dense()
	mut norm_squared := 0.0
	for row in 0 .. rhs.len {
		mut residual := -rhs[row]
		for column in 0 .. rhs.len {
			residual += dense.get(row, column) * solution[column]
		}
		norm_squared += residual * residual
	}
	return math.sqrt(norm_squared)
}

fn test_sparse_lu_pivots_and_reuses_factorization() {
	matrix := sparse_lu_matrix([
		[f64(0), 2, 1],
		[1, -2, -3],
		[2, 3, 1],
	])!
	factor := matrix.factorize_lu()!
	rhs := [3.0, 0.0, 7.0]
	first_solution := factor.solve(rhs)!
	assert math.abs(first_solution[0] - 1.0) < 1e-12
	assert math.abs(first_solution[1] - 2.0) < 1e-12
	assert math.abs(first_solution[2] + 1.0) < 1e-12
	assert sparse_lu_dense_residual_norm(matrix, first_solution, rhs) < 1e-12

	second_solution_expected := [2.0, -1.0, 3.0]
	second_rhs := matrix.matvec(second_solution_expected)!
	second_solution := factor.solve(second_rhs)!
	for index in 0 .. second_solution_expected.len {
		assert math.abs(second_solution[index] - second_solution_expected[index]) < 1e-12
	}
	assert sparse_lu_dense_residual_norm(matrix, second_solution, second_rhs) < 1e-12
}

fn test_sparse_lu_matches_dense_reference_residual_for_sparse_system() {
	matrix := sparse_lu_matrix([
		[f64(4), 1, 0, 0],
		[2, 5, 1, 0],
		[0, -1, 3, 1],
		[1, 0, 2, 6],
	])!
	expected := [1.0, -2.0, 0.5, 3.0]
	rhs := matrix.matvec(expected)!
	solution := matrix.factorize_lu()!.solve(rhs)!

	for index in 0 .. expected.len {
		assert math.abs(solution[index] - expected[index]) < 1e-12
	}
	assert sparse_lu_dense_residual_norm(matrix, solution, rhs) < 1e-12
}

fn test_sparse_lu_rejects_singular_and_invalid_shapes() {
	singular := sparse_lu_matrix([
		[f64(1), 2],
		[2, 4],
	])!
	if _ := singular.factorize_lu() {
		assert false
	}

	mut rectangular_entries := Triplet.new[f64](2, 3, 2)
	rectangular_entries.put(0, 0, 1.0)!
	rectangular_entries.put(1, 2, 1.0)!
	rectangular := rectangular_entries.to_csr()!
	if _ := rectangular.factorize_lu() {
		assert false
	}

	malformed := &CSRMatrix[f64]{
		m:   1
		n:   1
		nnz: 1
		p:   [0, 2]
		j:   [0]
		x:   [1.0]
	}
	if _ := malformed.factorize_lu() {
		assert false
	}

	matrix := sparse_lu_matrix([
		[f64(2), 0],
		[0, 3],
	])!
	factor := matrix.factorize_lu()!
	if _ := factor.solve([1.0]) {
		assert false
	}
}

fn test_sparse_lu_rejects_non_finite_matrix_and_rhs_values() {
	for invalid_value in [math.inf(1), math.nan()] {
		mut entries := Triplet.new[f64](1, 1, 1)
		entries.put(0, 0, invalid_value)!
		matrix := entries.to_csr()!
		if _ := matrix.factorize_lu() {
			assert false
		}
	}

	matrix := sparse_lu_matrix([[f64(1)]])!
	factor := matrix.factorize_lu()!
	for invalid_value in [math.inf(1), math.nan()] {
		if _ := factor.solve([invalid_value]) {
			assert false
		}
	}
}
