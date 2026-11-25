module roots

import vsl.func
import math

// Bisection implements a bisection method for finding the root of a function
pub struct Bisection {
	f func.Fn @[required]
mut:
	last_iter   ?&BisectionIteration // last iteration
	f_xmin      f64
	initialized bool
	finished    bool
pub mut:
	xmin      f64 // lower bound
	xmax      f64 // upper bound
	epsrel    f64 // relative error tolerance
	epsabs    f64 // absolute error tolerance
	n_max     int // maximum number of iterations
	n_f_calls int // number of function calls
	n_iter    int // number of iterations
}

// BisectionParams contains the parameters for the bisection method

// BisectionParams defines a public data structure for this module.

// BisectionParams defines a public data structure for this module.
@[params]
pub struct BisectionParams {
pub:
	xmin   f64
	xmax   f64
	epsrel f64 = 1e-6
	epsabs f64 = 1e-6
	n_max  int = 100
}

// Bisection.new creates a new Bisection object with the given parameters
pub fn Bisection.new(f func.Fn, params BisectionParams) &Bisection {
	return &Bisection{
		f:      f
		xmin:   params.xmin
		xmax:   params.xmax
		epsrel: params.epsrel
		epsabs: params.epsabs
		n_max:  params.n_max
	}
}

// BisectionIteration defines a public data structure for this module.
pub struct BisectionIteration {
pub mut:
	x         f64
	fx        f64
	n_f_calls int
	n_iter    int
}

// next returns the next iteration of the bisection method.
pub fn (mut solver Bisection) next() ?&BisectionIteration {
	if solver.finished || solver.n_iter >= solver.n_max {
		return none
	}
	if !solver.initialized {
		if math.is_nan(solver.xmin) || math.is_inf(solver.xmin, 0)
			|| math.is_nan(solver.xmax) || math.is_inf(solver.xmax, 0)
			|| solver.xmin >= solver.xmax || math.is_nan(solver.epsabs)
			|| math.is_inf(solver.epsabs, 0) || solver.epsabs < 0.0
			|| math.is_nan(solver.epsrel) || math.is_inf(solver.epsrel, 0)
			|| solver.epsrel < 0.0 || solver.n_max <= 0 {
			solver.finished = true
			return none
		}
		solver.f_xmin = solver.f.safe_eval(solver.xmin) or {
			solver.finished = true
			return none
		}
		solver.n_f_calls++
		if solver.f_xmin == 0.0 {
			solver.finished = true
			solver.last_iter = &BisectionIteration{
				x:         solver.xmin
				fx:        solver.f_xmin
				n_f_calls: solver.n_f_calls
				n_iter:    solver.n_iter
			}
			return solver.last_iter?
		}
		fxmax := solver.f.safe_eval(solver.xmax) or {
			solver.finished = true
			return none
		}
		solver.n_f_calls++
		if fxmax == 0.0 {
			solver.finished = true
			solver.last_iter = &BisectionIteration{
				x:         solver.xmax
				fx:        fxmax
				n_f_calls: solver.n_f_calls
				n_iter:    solver.n_iter
			}
			return solver.last_iter?
		}
		if (solver.f_xmin < 0.0 && fxmax < 0.0) || (solver.f_xmin > 0.0 && fxmax > 0.0) {
			solver.finished = true
			return none
		}
		solver.initialized = true
	}

	xmid := solver.xmin * 0.5 + solver.xmax * 0.5
	if xmid == solver.xmin || xmid == solver.xmax {
		solver.finished = true
		solver.last_iter = &BisectionIteration{
			x:         solver.xmin
			fx:        solver.f_xmin
			n_f_calls: solver.n_f_calls
			n_iter:    solver.n_iter
		}
		return solver.last_iter?
	}

	fxmid := solver.f.safe_eval(xmid) or {
		solver.finished = true
		solver.last_iter = none
		return none
	}
	solver.n_f_calls++
	solver.n_iter++
	solver.last_iter = &BisectionIteration{
		x:         xmid
		fx:        fxmid
		n_f_calls: solver.n_f_calls
		n_iter:    solver.n_iter
	}
	half_width := math.abs(solver.xmax * 0.5 - solver.xmin * 0.5)
	x_tolerance := solver.epsabs + solver.epsrel * math.abs(xmid)
	if fxmid == 0.0 || half_width <= x_tolerance {
		solver.finished = true
		return solver.last_iter?
	}
	if (solver.f_xmin < 0.0 && fxmid < 0.0) || (solver.f_xmin > 0.0 && fxmid > 0.0) {
		solver.xmin = xmid
		solver.f_xmin = fxmid
	} else {
		solver.xmax = xmid
	}
	return solver.last_iter?
}

// solve solves for the root of the function using the bisection method.
pub fn (mut solver Bisection) solve() ?&BisectionIteration {
	for {
		solver.next() or { break }
	}
	return solver.last_iter?
}
