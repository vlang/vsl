module deriv

import math

fn hessian_test_quadratic(x []f64) f64 {
	return 3.0 * x[0] * x[0] + 2.0 * x[0] * x[1] + 4.0 * x[1] * x[1]
}

fn hessian_test_mixed(x []f64) f64 {
	return math.sin(x[0]) * math.exp(x[1]) + x[0] * x[2] * x[2]
}

fn hessian_test_cubic(x []f64) f64 {
	return x[0] * x[0] * x[0]
}

fn hessian_test_non_finite_value(_ []f64) f64 {
	return math.nan()
}

fn hessian_test_non_finite_perturbation(x []f64) f64 {
	if x[0] == 1.0 {
		return 0.0
	}
	return math.inf(1)
}

fn test_hessian_matches_analytic_quadratic() {
	x := [0.7, -0.4]
	result := hessian(hessian_test_quadratic, x, 1e-3)!
	assert result.values.len == 2
	assert result.values[0].len == 2
	assert result.evaluations == 17
	assert math.abs(result.values[0][0] - 6.0) < 1e-8
	assert math.abs(result.values[0][1] - 2.0) < 1e-8
	assert math.abs(result.values[1][0] - 2.0) < 1e-8
	assert math.abs(result.values[1][1] - 8.0) < 1e-8
	for row in result.error_estimate {
		for estimate in row {
			assert estimate >= 0.0
		}
	}
	assert x == [0.7, -0.4]
}

fn test_hessian_matches_analytic_mixed_partials() {
	x := [0.5, 0.25, 1.5]
	result := hessian(hessian_test_mixed, x, 1e-3)!
	expected_00 := -math.sin(x[0]) * math.exp(x[1])
	expected_11 := math.sin(x[0]) * math.exp(x[1])
	expected_01 := math.cos(x[0]) * math.exp(x[1])
	assert math.abs(result.values[0][0] - expected_00) < 1e-7
	assert math.abs(result.values[1][1] - expected_11) < 1e-7
	assert math.abs(result.values[2][2] - 2.0 * x[0]) < 1e-7
	assert math.abs(result.values[0][1] - expected_01) < 1e-7
	assert math.abs(result.values[1][0] - expected_01) < 1e-7
	assert math.abs(result.values[0][2] - 2.0 * x[2]) < 1e-7
	assert math.abs(result.values[2][0] - 2.0 * x[2]) < 1e-7
	assert math.abs(result.values[1][2]) < 1e-7
	assert math.abs(result.values[2][1]) < 1e-7
}

fn test_hessian_is_symmetric() {
	result := hessian(hessian_test_mixed, [0.5, 0.25, 1.5], 1e-3)!
	assert result.values[0][1] == result.values[1][0]
	assert result.values[0][2] == result.values[2][0]
	assert result.values[1][2] == result.values[2][1]
	assert result.error_estimate[0][2] == result.error_estimate[2][0]
}

fn test_hessian_single_coordinate() {
	result := hessian(hessian_test_cubic, [2.0], 1e-3)!
	assert result.values.len == 1
	assert result.values[0].len == 1
	assert result.evaluations == 5
	assert math.abs(result.values[0][0] - 12.0) < 1e-6
}

fn test_hessian_rejects_empty_input() {
	hessian(hessian_test_quadratic, [], 1e-3) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected empty input to be rejected'
}

fn test_hessian_rejects_invalid_steps() {
	hessian(hessian_test_quadratic, [1.0, 2.0], 0.0) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected zero step to be rejected'
	hessian(hessian_test_quadratic, [1.0, 2.0], -1e-3) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected negative step to be rejected'
	hessian(hessian_test_quadratic, [1.0, 2.0], math.nan()) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected non-finite step to be rejected'
}

fn test_hessian_rejects_non_finite_coordinates() {
	hessian(hessian_test_quadratic, [math.inf(1), 2.0], 1e-3) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected non-finite coordinate to be rejected'
}

fn test_hessian_rejects_unrepresentable_steps() {
	hessian(hessian_test_cubic, [0.0], 5e-324) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected an unrepresentable step to be rejected'
}

fn test_hessian_rejects_non_finite_function_values() {
	hessian(hessian_test_non_finite_value, [1.0], 1e-3) or {
		assert err.code() == 9
		return
	}
	assert false, 'expected a non-finite base value to be rejected'
}

fn test_hessian_rejects_non_finite_perturbed_values() {
	hessian(hessian_test_non_finite_perturbation, [1.0], 1e-3) or {
		assert err.code() == 9
		return
	}
	assert false, 'expected a non-finite perturbed value to be rejected'
}
