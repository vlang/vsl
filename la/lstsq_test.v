module la

import math

fn test_lstsq_reports_squared_residuals_only_for_full_rank_overdetermined_systems() {
	a := Matrix.deep2([
		[1.0, 0.0],
		[0.0, 1.0],
		[1.0, 1.0],
	])
	b := Matrix.deep2([[1.0], [2.0], [4.0]])
	x, residuals, rank, singular_values := lstsq(a, b)
	assert rank == 2
	assert singular_values.len == 2
	assert math.abs(x[0][0] - 4.0 / 3.0) < 1e-10
	assert math.abs(x[1][0] - 7.0 / 3.0) < 1e-10
	assert residuals.len == 1
	assert math.abs(residuals[0] - 1.0 / 3.0) < 1e-10
}

fn test_lstsq_rank_deficient_system_has_minimum_norm_solution_and_no_residuals() {
	a := Matrix.deep2([
		[1.0, 1.0],
		[2.0, 2.0],
		[3.0, 3.0],
	])
	b := Matrix.deep2([[2.0], [4.0], [6.0]])
	x, residuals, rank, _ := lstsq(a, b)
	assert rank == 1
	assert x.len == 2
	assert math.abs(x[0][0] - 1.0) < 1e-10
	assert math.abs(x[1][0] - 1.0) < 1e-10
	assert residuals.len == 0
}

fn test_lstsq_underdetermined_system_has_no_residuals() {
	a := Matrix.deep2([[1.0, 1.0]])
	b := Matrix.deep2([[2.0]])
	x, residuals, rank, _ := lstsq(a, b)
	assert rank == 1
	assert math.abs(x[0][0] - 1.0) < 1e-10
	assert math.abs(x[1][0] - 1.0) < 1e-10
	assert residuals.len == 0
}

fn test_lstsq_rcond_controls_numerical_rank() {
	a := Matrix.deep2([
		[1.0, 0.0],
		[0.0, 1e-16],
		[0.0, 0.0],
	])
	b := Matrix.deep2([[1.0], [1e-16], [0.0]])
	_, _, default_rank, _ := lstsq(a, b)
	_, _, exact_rank, _ := lstsq_with_rcond(a, b, 0)
	assert default_rank == 1
	assert exact_rank == 2
}

fn test_lstsq_multiple_rhs_returns_squared_residual_per_column() {
	a := Matrix.deep2([
		[1.0, 0.0],
		[0.0, 1.0],
		[1.0, 1.0],
	])
	b := Matrix.deep2([
		[1.0, 2.0],
		[2.0, 1.0],
		[4.0, 4.0],
	])
	x, residuals, rank, _ := lstsq(a, b)
	assert rank == 2
	assert x.len == 2
	assert x[0].len == 2
	assert residuals.len == 2
	assert math.abs(residuals[0] - 1.0 / 3.0) < 1e-10
	assert math.abs(residuals[1] - 1.0 / 3.0) < 1e-10
}
