module deriv

import math

fn deriv_test_vector_function(x []f64) []f64 {
	return [3.0 * x[0] + 2.0 * x[1], x[0] * x[1], math.sin(x[0]) + math.exp(x[1])]
}

fn deriv_test_non_finite_vector_function(_ []f64) []f64 {
	return [math.nan()]
}

fn deriv_test_non_finite_perturbation_function(x []f64) []f64 {
	if x[0] == 1.0 {
		return [1.0]
	}
	return [math.inf(1)]
}

fn deriv_test_identity_vector_function(x []f64) []f64 {
	return [x[0]]
}

fn deriv_test_changing_shape_vector_function(x []f64) []f64 {
	if x[0] > 1.0 {
		return [x[0], 0.0]
	}
	return [x[0]]
}

fn test_jacobian_estimates_multivariable_derivatives() {
	x := [0.7, 0.4]
	result := jacobian(deriv_test_vector_function, x, 1e-3)!
	assert result.values.len == 3
	assert result.values[0].len == 2
	assert result.evaluations == 9
	assert math.abs(result.values[0][0] - 3.0) < 1e-8
	assert math.abs(result.values[0][1] - 2.0) < 1e-8
	assert math.abs(result.values[1][0] - x[1]) < 1e-8
	assert math.abs(result.values[1][1] - x[0]) < 1e-8
	assert math.abs(result.values[2][0] - math.cos(x[0])) < 1e-7
	assert math.abs(result.values[2][1] - math.exp(x[1])) < 1e-7
	assert result.error_estimate[0][0] >= 0.0
	assert result.error_estimate[2][1] >= 0.0
	assert x == [0.7, 0.4]
}

fn test_jacobian_rejects_invalid_steps() {
	jacobian(deriv_test_vector_function, [1.0, 2.0], 0.0) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected a zero step to be rejected'
}

fn test_jacobian_rejects_unrepresentable_half_steps() {
	jacobian(deriv_test_identity_vector_function, [0.0], 5e-324) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected an unrepresentable half-step to be rejected'
}

fn test_jacobian_rejects_non_finite_coordinates() {
	jacobian(deriv_test_vector_function, [math.inf(1)], 1e-4) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected a non-finite coordinate to be rejected'
}

fn test_jacobian_rejects_non_finite_function_values() {
	jacobian(deriv_test_non_finite_vector_function, [1.0], 1e-4) or {
		assert err.code() == 9
		return
	}
	assert false, 'expected a non-finite vector result to be rejected'
}

fn test_jacobian_rejects_non_finite_perturbation_values() {
	jacobian(deriv_test_non_finite_perturbation_function, [1.0], 1e-4) or {
		assert err.code() == 9
		return
	}
	assert false, 'expected non-finite perturbed output to be rejected'
}

fn test_jacobian_rejects_output_shape_changes() {
	jacobian(deriv_test_changing_shape_vector_function, [1.0], 1e-3) or {
		assert err.code() == 4
		return
	}
	assert false, 'expected an inconsistent output shape to be rejected'
}
