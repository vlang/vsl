module la

import math

fn test_csr_bicgstab_solves_nonsymmetric_system_with_true_residual() {
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
	result := matrix.bicgstab(right_hand_side, 1e-12, 10)!

	assert result.converged
	assert !result.breakdown
	assert result.iterations > 0
	assert result.iterations <= 3
	assert math.abs(result.x[0] - 1.0) < 1e-12
	assert math.abs(result.x[1] - 2.0) < 1e-12
	assert math.abs(result.x[2] + 1.0) < 1e-12
	dense_result := matrix_vector_mul(1.0, matrix.to_dense(), result.x)
	assert math.abs(result.residual_norm - vector_norm_diff(dense_result,
		right_hand_side)) < 1e-14
	assert result.residual_norm < 1e-12
}

fn test_csr_bicgstab_zero_rhs_and_iteration_limit() {
	mut entries := Triplet.new[f64](3, 3, 3)
	entries.put(0, 0, 1.0)!
	entries.put(1, 1, 2.0)!
	entries.put(2, 2, 4.0)!
	matrix := entries.to_csr()!

	zero := matrix.bicgstab([0.0, 0.0, 0.0], 1e-8, 5)!
	assert zero.converged
	assert !zero.breakdown
	assert zero.iterations == 0
	assert zero.residual_norm == 0.0
	assert zero.x == [0.0, 0.0, 0.0]

	right_hand_side := [1.0, 2.0, 4.0]
	limited := matrix.bicgstab(right_hand_side, 1e-14, 1)!
	assert !limited.converged
	assert !limited.breakdown
	assert limited.iterations == 1
	dense_result := matrix_vector_mul(1.0, matrix.to_dense(), limited.x)
	assert math.abs(limited.residual_norm - vector_norm_diff(dense_result,
		right_hand_side)) < 1e-14
}

fn test_csr_bicgstab_reports_convergence_and_breakdown_for_singular_systems() {
	mut entries := Triplet.new[f64](2, 2, 1)
	entries.put(0, 0, 1.0)!
	matrix := entries.to_csr()!

	consistent := matrix.bicgstab([1.0, 0.0], 1e-12, 5)!
	assert consistent.converged
	assert !consistent.breakdown
	assert consistent.x == [1.0, 0.0]
	assert consistent.residual_norm == 0.0

	inconsistent := matrix.bicgstab([1.0, 1.0], 1e-12, 5)!
	assert !inconsistent.converged
	assert inconsistent.breakdown
	assert inconsistent.iterations > 0
	assert math.abs(inconsistent.residual_norm - 1.0) < 1e-12
}

fn test_csr_bicgstab_validates_inputs_and_finite_values() {
	mut rectangular := Triplet.new[f64](2, 3, 1)
	rectangular.put(0, 0, 1.0)!
	if _ := rectangular.to_csr()!.bicgstab([1.0, 0.0], 1e-8, 5) {
		assert false
	}

	mut square := Triplet.new[f64](2, 2, 2)
	square.put(0, 0, 1.0)!
	square.put(1, 1, 1.0)!
	matrix := square.to_csr()!
	if _ := matrix.bicgstab([1.0], 1e-8, 5) {
		assert false
	}
	if _ := matrix.bicgstab([1.0, 1.0], 0.0, 5) {
		assert false
	}
	if _ := matrix.bicgstab([1.0, 1.0], 1e-8, 0) {
		assert false
	}
	if _ := matrix.bicgstab([math.nan(), 1.0], 1e-8, 5) {
		assert false
	}

	mut non_finite_entries := Triplet.new[f64](1, 1, 1)
	non_finite_entries.put(0, 0, math.nan())!
	if _ := non_finite_entries.to_csr()!.bicgstab([1.0], 1e-8, 5) {
		assert false
	}
}
