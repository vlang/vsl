module roots

import math
import vsl.errors
import vsl.func

// MinimizeStatus reports why a bounded minimizer stopped.
pub enum MinimizeStatus {
	converged
	max_iterations
	max_evaluations
	non_finite_function_value
	precision_limit
}

// GoldenSectionParams configures a bounded scalar minimizer.
@[params]
pub struct GoldenSectionParams {
pub:
	xmin      f64
	xmax      f64
	tol       f64 = 1e-6
	n_max     int = 100
	max_evals int = 104
}

// GoldenSectionIteration is the best observed point and termination diagnostics.
pub struct GoldenSectionIteration {
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

// GoldenSection minimizes a unimodal scalar function over [xmin, xmax].
pub struct GoldenSection {
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

// GoldenSection.new creates a minimizer with default tolerances and limits.
// Set xmin and xmax before calling solve, or use new_with_params.
pub fn GoldenSection.new(f func.Fn) &GoldenSection {
	return GoldenSection.new_with_params(f, GoldenSectionParams{})
}

// GoldenSection.new_with_params creates a configured minimizer.
pub fn GoldenSection.new_with_params(f func.Fn, params GoldenSectionParams) &GoldenSection {
	return &GoldenSection{
		f:         f
		xmin:      params.xmin
		xmax:      params.xmax
		tol:       params.tol
		n_max:     params.n_max
		max_evals: params.max_evals
	}
}

fn (solver GoldenSection) result(x f64, fx f64, a f64, b f64, status MinimizeStatus) GoldenSectionIteration {
	lower := math.min(a, b)
	upper := math.max(a, b)
	return GoldenSectionIteration{
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

fn golden_section_point(a f64, b f64, fraction f64) f64 {
	return a * (1.0 - fraction) + b * fraction
}

fn golden_section_converged(a f64, b f64, x f64, tol f64) bool {
	error_bound := math.max(math.abs(x - a), math.abs(b - x))
	return error_bound <= tol
}

// solve minimizes a unimodal function over the configured interval.
// A non-converged termination is returned in result.status; invalid parameters
// are returned as errors. The function is evaluated only at interior points.
pub fn (mut solver GoldenSection) solve() !GoldenSectionIteration {
	solver.n_calls = 0
	solver.n_iter = 0
	if !finite_value(solver.xmin) || !finite_value(solver.xmax) || solver.xmin >= solver.xmax
		|| !finite_value(solver.tol) || solver.tol <= 0.0 || solver.n_max <= 0
		|| solver.max_evals < 1 {
		return errors.error('invalid golden-section minimizer parameters', .einval)
	}
	mut a := solver.xmin
	mut b := solver.xmax
	ratio := (math.sqrt(5.0) - 1.0) / 2.0
	mut x1 := golden_section_point(a, b, 1.0 - ratio)
	mut x2 := golden_section_point(a, b, ratio)
	if x1 <= a || x2 >= b || x1 >= x2 {
		if x1 <= a || x1 >= b {
			return solver.result(x1, math.nan(), a, b, .precision_limit)
		}
		fx := solver.f.safe_eval(x1) or {
			solver.n_calls++
			return solver.result(x1, math.nan(), a, b, .non_finite_function_value)
		}
		solver.n_calls++
		return solver.result(x1, fx, a, b, .precision_limit)
	}
	mut f1 := solver.f.safe_eval(x1) or {
		solver.n_calls++
		return solver.result(x1, math.nan(), a, b, .non_finite_function_value)
	}
	solver.n_calls++
	mut best_x := x1
	mut best_fx := f1
	if solver.n_calls >= solver.max_evals {
		return solver.result(best_x, best_fx, a, b, .max_evaluations)
	}
	mut f2 := solver.f.safe_eval(x2) or {
		solver.n_calls++
		return solver.result(best_x, best_fx, a, b, .non_finite_function_value)
	}
	solver.n_calls++
	if f2 < best_fx {
		best_x = x2
		best_fx = f2
	}
	for solver.n_iter < solver.n_max {
		if golden_section_converged(a, b, best_x, solver.tol) {
			return solver.result(best_x, best_fx, a, b, .converged)
		}
		if solver.n_calls >= solver.max_evals {
			return solver.result(best_x, best_fx, a, b, .max_evaluations)
		}
		if f1 == f2 {
			return solver.result(best_x, best_fx, a, b, .precision_limit)
		}
		mut evaluate_left := false
		if f1 < f2 {
			b = x2
			x2 = x1
			f2 = f1
			x1 = golden_section_point(a, b, 1.0 - ratio)
			evaluate_left = true
		} else {
			a = x1
			x1 = x2
			f1 = f2
			x2 = golden_section_point(a, b, ratio)
		}
		solver.n_iter++
		if best_x < a || best_x > b {
			if evaluate_left {
				best_x = x2
				best_fx = f2
			} else {
				best_x = x1
				best_fx = f1
			}
		}
		if x1 <= a || x2 >= b || x1 >= x2 {
			return solver.result(best_x, best_fx, a, b, .precision_limit)
		}
		if evaluate_left {
			f1 = solver.f.safe_eval(x1) or {
				solver.n_calls++
				return solver.result(best_x, best_fx, a, b, .non_finite_function_value)
			}
			solver.n_calls++
			if f1 < best_fx {
				best_x = x1
				best_fx = f1
			}
		} else {
			f2 = solver.f.safe_eval(x2) or {
				solver.n_calls++
				return solver.result(best_x, best_fx, a, b, .non_finite_function_value)
			}
			solver.n_calls++
			if f2 < best_fx {
				best_x = x2
				best_fx = f2
			}
		}
	}
	status := if golden_section_converged(a, b, best_x, solver.tol) {
		MinimizeStatus.converged
	} else {
		.max_iterations
	}
	return solver.result(best_x, best_fx, a, b, status)
}
