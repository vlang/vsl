module deriv

import math
import vsl.errors

// JacobianResult contains the estimated Jacobian and per-entry error estimates.
// Rows correspond to output components and columns to input coordinates.
pub struct JacobianResult {
pub:
	values         [][]f64
	error_estimate [][]f64
	evaluations    int
}

fn finite_deriv_value(value f64) bool {
	return !math.is_nan(value) && !math.is_inf(value, 0)
}

fn evaluate_vector_function(f fn ([]f64) []f64, x []f64, expected_len int) ![]f64 {
	values := f(x.clone())
	if values.len != expected_len {
		return errors.error('vector function changed its output length', .einval)
	}
	for value in values {
		if !finite_deriv_value(value) {
			return errors.error('vector function returned a non-finite value', .ebadfunc)
		}
	}
	return values
}

// jacobian estimates the Jacobian of a vector-valued function at x.
// It uses central differences at h and h/2 with Richardson extrapolation.
// The returned values and error estimates are shaped [output length, input
// length]. h must be positive and finite; each coordinate uses
// h * max(1, abs(x[i])) as its initial step.
pub fn jacobian(f fn ([]f64) []f64, x []f64, h f64) !JacobianResult {
	if x.len == 0 || !finite_deriv_value(h) || h <= 0.0 {
		return errors.error('Jacobian requires non-empty input and a positive finite step',
			.einval)
	}
	for value in x {
		if !finite_deriv_value(value) {
			return errors.error('Jacobian input coordinates must be finite', .einval)
		}
	}

	base := f(x.clone())
	if base.len == 0 {
		return errors.error('vector function must return at least one value', .einval)
	}
	for value in base {
		if !finite_deriv_value(value) {
			return errors.error('vector function returned a non-finite value', .ebadfunc)
		}
	}

	mut values := [][]f64{len: base.len, init: []f64{len: x.len}}
	mut error_estimate := [][]f64{len: base.len, init: []f64{len: x.len}}
	mut evaluations := 1
	for input_index, coordinate in x {
		step := h * math.max(1.0, math.abs(coordinate))
		half_step := step * 0.5
		if !finite_deriv_value(step) || step <= 0.0 || coordinate + step == coordinate
			|| coordinate - step == coordinate || !finite_deriv_value(half_step)
			|| half_step <= 0.0 || coordinate + half_step == coordinate
			|| coordinate - half_step == coordinate {
			return errors.error('Jacobian step is not representable at an input coordinate',
				.einval)
		}
		mut samples := [][]f64{len: 4}
		for step_index in 0 .. 2 {
			current_step := if step_index == 0 { step } else { half_step }
			for direction_index, direction in [-1.0, 1.0] {
				mut point := x.clone()
				point[input_index] = coordinate + direction * current_step
				if !finite_deriv_value(point[input_index]) {
					return errors.error('Jacobian perturbation overflowed', .einval)
				}
				sample := evaluate_vector_function(f, point, base.len) or {
					return err
				}
				evaluations++
				samples[step_index * 2 + direction_index] = sample
			}
		}
		for output_index in 0 .. base.len {
			large_step_derivative := (0.5 * samples[1][output_index] - 0.5 *
				samples[0][output_index]) / step
			small_step := half_step
			small_step_derivative := (0.5 * samples[3][output_index] - 0.5 *
				samples[2][output_index]) / small_step
			derivative := (4.0 * small_step_derivative - large_step_derivative) / 3.0
			absolute_error := math.abs(small_step_derivative - large_step_derivative) / 3.0
			if !finite_deriv_value(derivative) || !finite_deriv_value(absolute_error) {
				return errors.error('Jacobian estimate is not finite', .ebadfunc)
			}
			values[output_index][input_index] = derivative
			error_estimate[output_index][input_index] = absolute_error
		}
	}
	return JacobianResult{
		values:         values
		error_estimate: error_estimate
		evaluations:    evaluations
	}
}
