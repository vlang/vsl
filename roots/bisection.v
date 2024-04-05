module roots

import vsl.func
import math

// Bisection implements a bisection method for finding the root of a function
pub struct Bisection {
	f func.Fn @[required]
mut:
	last_iter ?&BisectionIteration // last iteration
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
		f: f
		xmin: params.xmin
		xmax: params.xmax
		epsrel: params.epsrel
		epsabs: params.epsabs
		n_max: params.n_max
	}
}

pub struct BisectionIteration {
pub mut:
	x         f64
	fx        f64
	n_f_calls int
	n_iter    int
}

// next returns the next iteration of the bisection method.
pub fn (mut solver Bisection) next() ?&BisectionIteration {
	if solver.n_iter == solver.n_max {
		return none
	}
	solver.n_iter += 1
	xmid := (solver.xmin + solver.xmax) / 2.0
	fxmid := solver.f.safe_eval(xmid) or { return none }
	solver.n_f_calls += 1
	if math.abs(fxmid) < solver.epsabs || math.abs(fxmid) < solver.epsrel * math.abs(fxmid) {
		solver.last_iter = &BisectionIteration{
			x: xmid
			fx: fxmid
			n_f_calls: solver.n_f_calls
			n_iter: solver.n_iter
		}
		return solver.last_iter?
	}
	fxmin := solver.f.safe_eval(solver.xmin) or { return none }
	if fxmid * fxmin < 0.0 {
		solver.xmax = xmid
	} else {
		solver.xmin = xmid
	}

	solver.last_iter = &BisectionIteration{
		x: xmid
		fx: fxmid
		n_f_calls: solver.n_f_calls
		n_iter: solver.n_iter
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
