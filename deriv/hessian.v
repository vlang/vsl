module deriv

import math
import vsl.errors

// HessianResult contains the estimated Hessian and per-entry error estimates.
// Both matrices are symmetric and shaped [input length, input length].
pub struct HessianResult {
pub:
	values         [][]f64
	error_estimate [][]f64
	evaluations    int
}

fn hessian_eval(f fn ([]f64) f64, point []f64) !f64 {
	value := f(point.clone())
	if !finite_deriv_value(value) {
		return errors.error('scalar function returned a non-finite value', .ebadfunc)
	}
	return value
}

fn hessian_point(x []f64, i int, delta_i f64, j int, delta_j f64) []f64 {
	mut point := x.clone()
	point[i] += delta_i
	if j >= 0 {
		point[j] += delta_j
	}
	return point
}

fn hessian_finite_denominator(value f64) bool {
	return finite_deriv_value(value) && value > 0.0
}

// hessian estimates the Hessian matrix (all second partial derivatives) of a
// scalar-valued function at x. h must be positive and finite; each coordinate
// uses h * max(1, abs(x[i])) as its initial step.
//
// Diagonal entries use the second-order central stencil
// (f(x+s) - 2 f(x) + f(x-s)) / s^2 and off-diagonal entries use the mixed
// four-point stencil. Each entry is computed at s and s/2 and refined with
// Richardson extrapolation; the difference between the two estimates supplies
// the per-entry error estimate. The returned matrices are symmetric: only the
// upper triangle is evaluated and mirrored. A non-positive or non-finite step,
// non-finite input or output, unrepresentable perturbation, or denominator
// overflow returns an error.
pub fn hessian(f fn ([]f64) f64, x []f64, h f64) !HessianResult {
	n := x.len
	if n == 0 || !finite_deriv_value(h) || h <= 0.0 {
		return errors.error('Hessian requires non-empty input and a positive finite step',
			.einval)
	}

	mut steps := []f64{len: n}
	for i, coordinate in x {
		if !finite_deriv_value(coordinate) {
			return errors.error('Hessian input coordinates must be finite', .einval)
		}
		step := h * math.max(1.0, math.abs(coordinate))
		half := step * 0.5
		if !finite_deriv_value(step) || step <= 0.0 || !finite_deriv_value(half) || half <= 0.0
			|| coordinate + step == coordinate || coordinate - step == coordinate
			|| coordinate + half == coordinate || coordinate - half == coordinate {
			return errors.error('Hessian step is not representable at an input coordinate',
				.einval)
		}
		steps[i] = step
	}

	base := hessian_eval(f, x) or {
		return err
	}
	mut evaluations := 1
	mut values := [][]f64{len: n, init: []f64{len: n}}
	mut error_estimate := [][]f64{len: n, init: []f64{len: n}}

	for i in 0 .. n {
		si := steps[i]
		hi := si * 0.5
		if !hessian_finite_denominator(si * si) || !hessian_finite_denominator(hi * hi) {
			return errors.error('Hessian step squared is not finite', .einval)
		}

		large_plus := hessian_eval(f, hessian_point(x, i, si, -1, 0.0)) or {
			return err
		}
		evaluations++
		large_minus := hessian_eval(f, hessian_point(x, i, -si, -1, 0.0)) or {
			return err
		}
		evaluations++
		small_plus := hessian_eval(f, hessian_point(x, i, hi, -1, 0.0)) or {
			return err
		}
		evaluations++
		small_minus := hessian_eval(f, hessian_point(x, i, -hi, -1, 0.0)) or {
			return err
		}
		evaluations++

		large := (large_plus - 2.0 * base + large_minus) / (si * si)
		small := (small_plus - 2.0 * base + small_minus) / (hi * hi)
		value, estimate := hessian_refine(large, small)
		if !finite_deriv_value(value) || !finite_deriv_value(estimate) {
			return errors.error('Hessian estimate is not finite', .ebadfunc)
		}
		values[i][i] = value
		error_estimate[i][i] = estimate
	}

	for i in 0 .. n {
		for j in i + 1 .. n {
			si := steps[i]
			sj := steps[j]
			hi := si * 0.5
			hj := sj * 0.5
			large_denom := 4.0 * si * sj
			small_denom := 4.0 * hi * hj
			if !hessian_finite_denominator(large_denom)
				|| !hessian_finite_denominator(small_denom) {
				return errors.error('Hessian mixed-partial denominator is not finite', .einval)
			}

			large_pp := hessian_eval(f, hessian_point(x, i, si, j, sj)) or {
				return err
			}
			evaluations++
			large_pm := hessian_eval(f, hessian_point(x, i, si, j, -sj)) or {
				return err
			}
			evaluations++
			large_mp := hessian_eval(f, hessian_point(x, i, -si, j, sj)) or {
				return err
			}
			evaluations++
			large_mm := hessian_eval(f, hessian_point(x, i, -si, j, -sj)) or {
				return err
			}
			evaluations++
			small_pp := hessian_eval(f, hessian_point(x, i, hi, j, hj)) or {
				return err
			}
			evaluations++
			small_pm := hessian_eval(f, hessian_point(x, i, hi, j, -hj)) or {
				return err
			}
			evaluations++
			small_mp := hessian_eval(f, hessian_point(x, i, -hi, j, hj)) or {
				return err
			}
			evaluations++
			small_mm := hessian_eval(f, hessian_point(x, i, -hi, j, -hj)) or {
				return err
			}
			evaluations++

			large := (large_pp - large_pm - large_mp + large_mm) / large_denom
			small := (small_pp - small_pm - small_mp + small_mm) / small_denom
			value, estimate := hessian_refine(large, small)
			if !finite_deriv_value(value) || !finite_deriv_value(estimate) {
				return errors.error('Hessian estimate is not finite', .ebadfunc)
			}
			values[i][j] = value
			values[j][i] = value
			error_estimate[i][j] = estimate
			error_estimate[j][i] = estimate
		}
	}

	return HessianResult{
		values:         values
		error_estimate: error_estimate
		evaluations:    evaluations
	}
}

fn hessian_refine(large f64, small f64) (f64, f64) {
	// Both stencils have O(h^2) truncation error, so halving the step quarters
	// the leading error term and Richardson removes it to O(h^4).
	value := (4.0 * small - large) / 3.0
	estimate := math.abs(small - large) / 3.0
	return value, estimate
}
