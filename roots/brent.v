module roots

import math
import vsl.errors
import vsl.func
import vsl.internal.prec

// BrentStatus reports why a Brent solver stopped.
pub enum BrentStatus {
	converged
	invalid_bracket
	max_iterations
	max_evaluations
	non_finite_function_value
	precision_limit
}

// BrentParams configures a bracketed Brent root solver.
@[params]
pub struct BrentParams {
pub:
	x1        f64
	x2        f64
	tol       f64 = 1e-6
	n_max     int = 100
	max_evals int = 102
}

// Brent implements Brent's method for finding a root in [x1, x2].
// The function must be continuous and the interval must bracket a root.
pub struct Brent {
pub:
	f func.Fn @[required]
pub mut:
	x1        f64
	x2        f64
	tol       f64
	n_max     int
	max_evals int
	n_calls   int
	n_iter    int
}

// Brent.new creates a Brent solver with default tolerances and limits.
// Set x1 and x2 before calling solve, or use Brent.new_with_params.
pub fn Brent.new(f func.Fn) &Brent {
	return Brent.new_with_params(f, BrentParams{})
}

// Brent.new_with_params creates a configured Brent solver.
pub fn Brent.new_with_params(f func.Fn, params BrentParams) &Brent {
	return &Brent{
		f:         f
		x1:        params.x1
		x2:        params.x2
		tol:       params.tol
		n_max:     params.n_max
		max_evals: params.max_evals
	}
}

// BrentIteration is the final root estimate and convergence diagnostics.
pub struct BrentIteration {
pub:
	x           f64
	fx          f64
	lower       f64
	upper       f64
	error_bound f64
	n_calls     int
	n_iter      int
	status      BrentStatus
}

fn finite_value(x f64) bool {
	return !math.is_nan(x) && !math.is_inf(x, 0)
}

fn (solver Brent) result(x f64, fx f64, a f64, b f64, status BrentStatus) BrentIteration {
	lower := math.min(a, b)
	upper := math.max(a, b)
	return BrentIteration{
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

// solve finds a root in the configured bracket and returns its diagnostics.
// A non-converged termination is returned in result.status; invalid solver
// parameters are returned as errors.
pub fn (mut solver Brent) solve() !BrentIteration {
	solver.n_calls = 0
	solver.n_iter = 0
	if !finite_value(solver.x1) || !finite_value(solver.x2) || solver.x1 >= solver.x2
		|| !finite_value(solver.tol) || solver.tol <= 0.0 || solver.n_max <= 0
		|| solver.max_evals < 1 {
		return errors.error('invalid Brent solver parameters', .einval)
	}
	mut a := solver.x1
	mut b := solver.x2
	mut fa := solver.f.safe_eval(a) or {
		solver.n_calls++
		return solver.result(a, math.nan(), a, b, .non_finite_function_value)
	}
	solver.n_calls++
	if fa == 0.0 {
		return solver.result(a, fa, a, a, .converged)
	}
	if solver.n_calls >= solver.max_evals {
		return solver.result(a, fa, a, b, .max_evaluations)
	}
	mut fb := solver.f.safe_eval(b) or {
		solver.n_calls++
		return solver.result(a, fa, a, b, .non_finite_function_value)
	}
	solver.n_calls++
	if fb == 0.0 {
		return solver.result(b, fb, b, b, .converged)
	}
	if (fa < 0.0 && fb < 0.0) || (fa > 0.0 && fb > 0.0) {
		best_x, best_fx := if math.abs(fa) < math.abs(fb) { a, fa } else { b, fb }
		return solver.result(best_x, best_fx, a, b, .invalid_bracket)
	}
	mut c := a
	mut fc := fa
	mut d := 0.5 * b - 0.5 * a
	mut e := d
	for solver.n_iter < solver.n_max {
		if math.abs(fc) < math.abs(fb) {
			a = b
			b = c
			c = a
			fa = fb
			fb = fc
			fc = fa
		}
		tol1 := 2.0 * prec.f64_epsilon * math.abs(b) + 0.5 * solver.tol
		m := 0.5 * c - 0.5 * b
		if math.abs(m) <= tol1 || fb == 0.0 {
			status := if math.abs(m) <= 2.0 * prec.f64_epsilon * math.abs(b)
				&& math.abs(m) > 0.5 * solver.tol {
				BrentStatus.precision_limit
			} else {
				.converged
			}
			return solver.result(b, fb, b, c, status)
		}
		if math.abs(e) >= tol1 && math.abs(fa) > math.abs(fb) {
			s := fb / fa
			mut p := 0.0
			mut q := 0.0
			if a == c {
				p = 2.0 * m * s
				q = 1.0 - s
			} else {
				q = fa / fc
				r := fb / fc
				delta := b - a
				if finite_value(delta) {
					p = s * (2.0 * m * q * (q - r) - delta * (r - 1.0))
				} else {
					p = math.nan()
				}
				q = (q - 1.0) * (r - 1.0) * (s - 1.0)
			}
			if p > 0.0 {
				q = -q
			} else {
				p = -p
			}
			if finite_value(p) && finite_value(q) && q != 0.0 && 2.0 * p < 3.0 * m * q - math.abs(tol1 * q)
				&& 2.0 * p < math.abs(e * q) {
				e = d
				d = p / q
			} else {
				d = m
				e = m
			}
		} else {
			d = m
			e = m
		}
		a = b
		fa = fb
		if solver.n_calls >= solver.max_evals {
			return solver.result(b, fb, b, c, .max_evaluations)
		}
		if math.abs(d) > tol1 {
			next_b := b + d
			if finite_value(next_b) && next_b >= math.min(b, c) && next_b <= math.max(b, c) && next_b != b {
				b = next_b
			} else {
				b = 0.5 * b + 0.5 * c
			}
		} else {
			b += if m > 0.0 { tol1 } else { -tol1 }
		}
		if b == a {
			return solver.result(b, fb, b, c, .precision_limit)
		}
		fb = solver.f.safe_eval(b) or {
			solver.n_calls++
			solver.n_iter++
			return solver.result(b, math.nan(), b, c, .non_finite_function_value)
		}
		solver.n_calls++
		solver.n_iter++
		if (fb < 0.0 && fc < 0.0) || (fb > 0.0 && fc > 0.0) {
			c = a
			fc = fa
		}
	}
	return solver.result(b, fb, b, c, .max_iterations)
}
