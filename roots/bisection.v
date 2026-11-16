module roots

import vsl.func
import math

// Bisection implements a bisection method for finding the root of a function
pub struct Bisection {
	f func.Fn @[required]
mut:
	last_iter   ?&BisectionIteration // last iteration
	f_xmin      f64
	cached_xmin f64
	cached_xmax f64
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
	if solver.initialized && (solver.xmin != solver.cached_xmin || solver.xmax != solver.cached_xmax) {
		solver.initialized = false
		solver.finished = false
		solver.n_iter = 0
		solver.last_iter = none
	}
	if solver.finished || solver.n_iter >= solver.n_max {
		return none
	}
	if !solver.initialized {
		if !finite_value(solver.xmin) || !finite_value(solver.xmax) || solver.xmin >= solver.xmax
			|| !finite_value(solver.epsabs) || solver.epsabs < 0.0 || !finite_value(solver.epsrel)
			|| solver.epsrel < 0.0 || solver.n_max <= 0 {
			solver.last_iter = none
			solver.finished = true
			return none
		}
		solver.n_f_calls++
		fxmin := solver.f.safe_eval(solver.xmin) or {
			solver.last_iter = none
			solver.finished = true
			return none
		}
		if fxmin == 0.0 {
			solver.finished = true
			solver.last_iter = &BisectionIteration{
				x:         solver.xmin
				fx:        fxmin
				n_f_calls: solver.n_f_calls
				n_iter:    solver.n_iter
			}
			return solver.last_iter?
		}
		solver.n_f_calls++
		fxmax := solver.f.safe_eval(solver.xmax) or {
			solver.last_iter = none
			solver.finished = true
			return none
		}
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
		if (fxmin < 0.0 && fxmax < 0.0) || (fxmin > 0.0 && fxmax > 0.0) {
			solver.last_iter = none
			solver.finished = true
			return none
		}
		solver.f_xmin = fxmin
		solver.cached_xmin = solver.xmin
		solver.cached_xmax = solver.xmax
		solver.initialized = true
	}
	xmid := solver.xmin * 0.5 + solver.xmax * 0.5
	if xmid == solver.xmin || xmid == solver.xmax {
		solver.finished = true
		return none
	}
	solver.n_f_calls++
	fxmid := solver.f.safe_eval(xmid) or {
		solver.last_iter = none
		solver.finished = true
		return none
	}
	solver.n_iter++
	solver.last_iter = &BisectionIteration{
		x:         xmid
		fx:        fxmid
		n_f_calls: solver.n_f_calls
		n_iter:    solver.n_iter
	}
	half_width := solver.xmax * 0.5 - solver.xmin * 0.5
	x_tolerance := solver.epsabs + solver.epsrel * math.abs(xmid)
	if fxmid == 0.0 || half_width <= x_tolerance {
		solver.finished = true
		return solver.last_iter?
	}
	if (fxmid < 0.0 && solver.f_xmin < 0.0) || (fxmid > 0.0 && solver.f_xmin > 0.0) {
		solver.xmin = xmid
		solver.f_xmin = fxmid
		solver.cached_xmin = xmid
	} else {
		solver.xmax = xmid
		solver.cached_xmax = xmid
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
