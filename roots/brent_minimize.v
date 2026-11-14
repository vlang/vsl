module roots

import math
import vsl.errors
import vsl.func

// BrentMinimizerParams configures a bounded scalar minimizer.
@[params]
pub struct BrentMinimizerParams {
pub:
	xmin      f64
	xmax      f64
	tol       f64 = 1e-6
	n_max     int = 100
	max_evals int = 102
}

// BrentMinimizerIteration is the best point and termination diagnostics.
pub struct BrentMinimizerIteration {
pub:
	x           f64
	fx          f64
	lower       f64
	upper       f64
	error_bound f64
	n_calls     int
	n_iter      int
	status      MinimizeStatus
}

// BrentMinimizer minimizes a unimodal scalar function over [xmin, xmax].
pub struct BrentMinimizer {
pub:
	f func.Fn @[required]
pub mut:
	xmin      f64
	xmax      f64
	tol       f64
	n_max     int
	max_evals int
	n_calls   int
	n_iter    int
}

// BrentMinimizer.new creates a minimizer with default tolerances and limits.
// Set xmin and xmax before calling solve, or use new_with_params.
pub fn BrentMinimizer.new(f func.Fn) &BrentMinimizer {
	return BrentMinimizer.new_with_params(f, BrentMinimizerParams{})
}

// BrentMinimizer.new_with_params creates a configured minimizer.
pub fn BrentMinimizer.new_with_params(f func.Fn, params BrentMinimizerParams) &BrentMinimizer {
	return &BrentMinimizer{
		f:         f
		xmin:      params.xmin
		xmax:      params.xmax
		tol:       params.tol
		n_max:     params.n_max
		max_evals: params.max_evals
	}
}

fn (solver BrentMinimizer) result(x f64, fx f64, a f64, b f64, status MinimizeStatus) BrentMinimizerIteration {
	lower := math.min(a, b)
	upper := math.max(a, b)
	return BrentMinimizerIteration{
		x:           x
		fx:          fx
		lower:       lower
		upper:       upper
		error_bound: math.max(math.abs(x - lower), math.abs(upper - x))
		n_calls:     solver.n_calls
		n_iter:      solver.n_iter
		status:      status
	}
}

fn brent_minimizer_half_delta(x f64, a f64, b f64, midpoint f64) f64 {
	if x >= midpoint {
		return a * 0.5 - x * 0.5
	}
	return b * 0.5 - x * 0.5
}

// solve minimizes a unimodal function over the configured interval.
// A non-converged termination is returned in result.status; invalid parameters
// are returned as errors. The function is evaluated only at interior points.
pub fn (mut solver BrentMinimizer) solve() !BrentMinimizerIteration {
	solver.n_calls = 0
	solver.n_iter = 0
	if !finite_value(solver.xmin) || !finite_value(solver.xmax) || solver.xmin >= solver.xmax
		|| !finite_value(solver.tol) || solver.tol <= 0.0 || solver.n_max <= 0
		|| solver.max_evals < 1 {
		return errors.error('invalid Brent minimizer parameters', .einval)
	}
	mut a := solver.xmin
	mut b := solver.xmax
	mut x := a * 0.5 + b * 0.5
	if x <= a || x >= b {
		return solver.result(x, math.nan(), a, b, .precision_limit)
	}
	mut fx := solver.f.safe_eval(x) or {
		solver.n_calls++
		return solver.result(x, math.nan(), a, b, .non_finite_function_value)
	}
	solver.n_calls++
	mut w := x
	mut v := x
	mut fw := fx
	mut fv := fx
	mut d := 0.0
	mut e := 0.0
	for solver.n_iter < solver.n_max {
		if math.max(math.abs(x - a), math.abs(b - x)) <= solver.tol {
			return solver.result(x, fx, a, b, .converged)
		}
		if solver.n_calls >= solver.max_evals {
			return solver.result(x, fx, a, b, .max_evaluations)
		}
		midpoint := a * 0.5 + b * 0.5
		mut step := 0.0
		mut next_e := 0.0
		mut use_parabolic_step := false
		if finite_value(e) && math.abs(e) > 0.5 * solver.tol {
			r := (x - w) * (fx - fv)
			q := (x - v) * (fx - fw)
			mut p := (x - v) * q - (x - w) * r
			mut denominator := 2.0 * (q - r)
			if denominator > 0.0 {
				p = -p
			} else {
				denominator = -denominator
			}
			if finite_value(p) && finite_value(denominator) && denominator != 0.0 {
				proposed_step := p / denominator
				proposed_x := x + proposed_step
				if finite_value(proposed_step) && finite_value(proposed_x)
					&& math.abs(proposed_step) < math.abs(e)
					&& proposed_x > a && proposed_x < b {
					step = proposed_step
					next_e = d
					use_parabolic_step = true
					if proposed_x - a < 2.0 * solver.tol || b - proposed_x < 2.0 * solver.tol {
						step = if midpoint >= x { solver.tol } else { -solver.tol }
					}
				}
			}
		}
		if !use_parabolic_step {
			half_delta := brent_minimizer_half_delta(x, a, b, midpoint)
			step = 0.7639320225002103 * half_delta
			next_e = half_delta
		}
		e = next_e
		d = step
		mut candidate := if math.abs(step) >= solver.tol {
			x + step
		} else {
			x + if step >= 0.0 { solver.tol } else { -solver.tol }
		}
		if candidate <= a || candidate >= b || !finite_value(candidate) {
			candidate = x * 0.5 + midpoint * 0.5
		}
		if !finite_value(candidate) || candidate <= a || candidate >= b || candidate == x {
			return solver.result(x, fx, a, b, .precision_limit)
		}
		fu := solver.f.safe_eval(candidate) or {
			solver.n_calls++
			solver.n_iter++
			return solver.result(x, fx, a, b, .non_finite_function_value)
		}
		solver.n_calls++
		solver.n_iter++
		if fu <= fx {
			if candidate >= x {
				a = x
			} else {
				b = x
			}
			v = w
			fv = fw
			w = x
			fw = fx
			x = candidate
			fx = fu
		} else {
			if candidate < x {
				a = candidate
			} else {
				b = candidate
			}
			if fu <= fw || w == x {
				v = w
				fv = fw
				w = candidate
				fw = fu
			} else if fu <= fv || v == x || v == w {
				v = candidate
				fv = fu
			}
		}
	}
	status := if math.max(math.abs(x - a), math.abs(b - x)) <= solver.tol {
		MinimizeStatus.converged
	} else {
		.max_iterations
	}
	return solver.result(x, fx, a, b, status)
}
