module la

import math

fn test_csr_conjugate_gradient_solves_spd_system_and_reports_true_residual() {
	mut entries := Triplet.new[f64](3, 3, 7)
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
	assert result.iterations > 0
	assert result.iterations <= 3
	assert math.abs(result.x[0] - 1.0) < 1e-12
	assert math.abs(result.x[1] - 2.0) < 1e-12
	assert math.abs(result.x[2] - 3.0) < 1e-12
	assert result.residual_norm < 1e-12
	dense_result := matrix_vector_mul(1.0, matrix.to_dense(), result.x)
	assert vector_norm_diff(dense_result, [6.0, 10.0, 8.0]) < 1e-12
}

fn test_csr_conjugate_gradient_zero_rhs_converges_without_iterations() {
	mut entries := Triplet.new[f64](2, 2, 2)
	entries.put(0, 0, 2.0)!
	entries.put(1, 1, 3.0)!

	result := entries.to_csr()!.conjugate_gradient([0.0, 0.0], 1e-8, 5)!

	assert result.converged
	assert result.iterations == 0
	assert result.residual_norm == 0.0
	assert result.x == [0.0, 0.0]
}

fn test_csr_conjugate_gradient_returns_nonconverged_at_iteration_limit() {
	mut entries := Triplet.new[f64](3, 3, 3)
	entries.put(0, 0, 1.0)!
	entries.put(1, 1, 2.0)!
	entries.put(2, 2, 4.0)!

	matrix := entries.to_csr()!
	right_hand_side := [1.0, 2.0, 4.0]
	result := matrix.conjugate_gradient(right_hand_side, 1e-14, 1)!

	assert !result.converged
	assert result.iterations == 1
	assert result.residual_norm > 0.0
	dense_result := matrix_vector_mul(1.0, matrix.to_dense(), result.x)
	assert math.abs(result.residual_norm - vector_norm_diff(dense_result, right_hand_side)) < 1e-14
}

fn test_csr_conjugate_gradient_rejects_non_positive_curvature() {
	mut entries := Triplet.new[f64](2, 2, 2)
	entries.put(0, 0, -1.0)!
	entries.put(1, 1, -1.0)!

	if _ := entries.to_csr()!.conjugate_gradient([1.0, 1.0], 1e-8, 5) {
		assert false
	}
}

fn test_csr_preconditioned_conjugate_gradient_uses_jacobi_diagonal() {
	mut entries := Triplet.new[f64](3, 3, 3)
	entries.put(0, 0, 1.0)!
	entries.put(1, 1, 100.0)!
	entries.put(2, 2, 10_000.0)!

	matrix := entries.to_csr()!
	result := matrix.preconditioned_conjugate_gradient([2.0, 300.0, 40_000.0], 1e-12, 3)!

	assert result.converged
	assert result.iterations == 1
	assert result.x == [2.0, 3.0, 4.0]
	assert result.residual_norm == 0.0

	mut coupled_entries := Triplet.new[f64](3, 3, 7)
	coupled_entries.put(0, 0, 4.0)!
	coupled_entries.put(0, 1, 1.0)!
	coupled_entries.put(1, 0, 1.0)!
	coupled_entries.put(1, 1, 3.0)!
	coupled_entries.put(1, 2, 1.0)!
	coupled_entries.put(2, 1, 1.0)!
	coupled_entries.put(2, 2, 2.0)!
	coupled_matrix := coupled_entries.to_csr()!
	coupled_result := coupled_matrix.preconditioned_conjugate_gradient([6.0, 10.0, 8.0],
		1e-12, 10)!
	assert coupled_result.converged
	assert coupled_result.iterations <= 3
	assert math.abs(coupled_result.x[0] - 1.0) < 1e-12
	assert math.abs(coupled_result.x[1] - 2.0) < 1e-12
	assert math.abs(coupled_result.x[2] - 3.0) < 1e-12
	assert coupled_result.residual_norm < 1e-12
}

fn test_csr_preconditioned_conjugate_gradient_rejects_missing_or_nonpositive_diagonal() {
	mut missing_diagonal := Triplet.new[f64](2, 2, 1)
	missing_diagonal.put(0, 0, 1.0)!
	if _ := missing_diagonal.to_csr()!.preconditioned_conjugate_gradient([1.0, 1.0], 1e-8, 5) {
		assert false
	}

	mut negative_diagonal := Triplet.new[f64](2, 2, 2)
	negative_diagonal.put(0, 0, -1.0)!
	negative_diagonal.put(1, 1, 1.0)!
	if _ := negative_diagonal.to_csr()!.preconditioned_conjugate_gradient([1.0, 1.0], 1e-8,
		5) {
		assert false
	}
}

fn test_csr_conjugate_gradient_validates_inputs() {
	mut rectangular := Triplet.new[f64](2, 3, 1)
	rectangular.put(0, 0, 1.0)!
	if _ := rectangular.to_csr()!.conjugate_gradient([1.0, 0.0], 1e-8, 5) {
		assert false
	}

	mut square := Triplet.new[f64](2, 2, 2)
	square.put(0, 0, 1.0)!
	square.put(1, 1, 1.0)!
	matrix := square.to_csr()!
	if _ := matrix.conjugate_gradient([1.0], 1e-8, 5) {
		assert false
	}
	if _ := matrix.conjugate_gradient([1.0, 1.0], 0.0, 5) {
		assert false
	}
	if _ := matrix.conjugate_gradient([1.0, 1.0], 1e-8, 0) {
		assert false
	}
	if _ := matrix.conjugate_gradient([math.nan(), 1.0], 1e-8, 5) {
		assert false
	}
}

fn test_csr_gmres_solves_nonsymmetric_system_and_reports_true_residual() {
	mut entries := Triplet.new[f64](3, 3, 7)
	entries.put(0, 0, 4.0)!
	entries.put(0, 1, 1.0)!
	entries.put(1, 0, 2.0)!
	entries.put(1, 1, 3.0)!
	entries.put(1, 2, 1.0)!
	entries.put(2, 1, 1.0)!
	entries.put(2, 2, 2.0)!

	matrix := entries.to_csr()!
	right_hand_side := [6.0, 7.0, 0.0]
	result := matrix.gmres(right_hand_side, 1e-12, 10, 3)!

	assert result.converged
	assert result.iterations > 0
	assert result.iterations <= 3
	assert math.abs(result.x[0] - 1.0) < 1e-12
	assert math.abs(result.x[1] - 2.0) < 1e-12
	assert math.abs(result.x[2] + 1.0) < 1e-12
	dense_result := matrix_vector_mul(1.0, matrix.to_dense(), result.x)
	assert math.abs(result.residual_norm - vector_norm_diff(dense_result, right_hand_side)) < 1e-14
	assert result.residual_norm < 1e-12
}

fn test_csr_gmres_restarts_and_reports_iteration_limit() {
	mut entries := Triplet.new[f64](3, 3, 7)
	entries.put(0, 0, 4.0)!
	entries.put(0, 1, 1.0)!
	entries.put(1, 0, 2.0)!
	entries.put(1, 1, 3.0)!
	entries.put(1, 2, 1.0)!
	entries.put(2, 1, 1.0)!
	entries.put(2, 2, 2.0)!

	matrix := entries.to_csr()!
	right_hand_side := [6.0, 7.0, 0.0]
	restarted := matrix.gmres(right_hand_side, 1e-10, 30, 2)!
	assert restarted.converged
	assert restarted.iterations > 2
	assert math.abs(restarted.x[0] - 1.0) < 1e-9
	assert math.abs(restarted.x[1] - 2.0) < 1e-9
	assert math.abs(restarted.x[2] + 1.0) < 1e-9

	limited := matrix.gmres(right_hand_side, 1e-14, 1, 1)!
	assert !limited.converged
	assert limited.iterations == 1
	dense_result := matrix_vector_mul(1.0, matrix.to_dense(), limited.x)
	assert math.abs(limited.residual_norm - vector_norm_diff(dense_result, right_hand_side)) < 1e-14
}

fn test_csr_gmres_zero_rhs_and_input_validation() {
	mut entries := Triplet.new[f64](2, 2, 2)
	entries.put(0, 0, 2.0)!
	entries.put(1, 1, 3.0)!
	matrix := entries.to_csr()!

	zero := matrix.gmres([0.0, 0.0], 1e-8, 5, 2)!
	assert zero.converged
	assert zero.iterations == 0
	assert zero.residual_norm == 0.0
	assert zero.x == [0.0, 0.0]

	if _ := matrix.gmres([1.0], 1e-8, 5, 2) {
		assert false
	}
	if _ := matrix.gmres([1.0, 1.0], 0.0, 5, 2) {
		assert false
	}
	if _ := matrix.gmres([1.0, 1.0], 1e-8, 0, 2) {
		assert false
	}
	if _ := matrix.gmres([1.0, 1.0], 1e-8, 5, 0) {
		assert false
	}
	if _ := matrix.gmres([math.inf(1), 1.0], 1e-8, 5, 2) {
		assert false
	}
}
