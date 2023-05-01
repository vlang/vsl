module roots

import vsl.func
import math

// Bisection implements a bisection method for finding the root of a function
pub struct Bisection {
	f func.Fn [required]
pub mut:
	xmin    f64
	xmax    f64
	epsrel  f64
	epsabs  f64
	n_max   int
	n_calls int
	n_iter  int
}

// new_bisection creates a new Bisection object
pub fn new_bisection(f func.Fn) &Bisection {
	return &Bisection{
		f: f
		xmin: 0.0
		xmax: 0.0
		epsrel: 1e-6
		epsabs: 1e-6
		n_max: 100
	}
}

pub struct BisectionIteration {
pub mut:
	x       f64
	fx      f64
	n_calls int
	n_iter  int
}

// next returns the next iteration of the bisection method.
// If the maximum number of iterations is reached, an error is returned.
// If the root is found, the root is returned.
pub fn (mut solver Bisection) next() ?&BisectionIteration {
	if solver.n_iter == solver.n_max {
		return none
	}
	solver.n_iter += 1
	xmid := (solver.xmin + solver.xmax) / 2.0
	fxmid := solver.f.safe_eval(xmid) or { return none }
	solver.n_calls += 1
	if math.abs(fxmid) < solver.epsabs || math.abs(fxmid) < solver.epsrel * math.abs(fxmid) {
		return &BisectionIteration{
			x: xmid
			fx: fxmid
			n_calls: solver.n_calls
			n_iter: solver.n_iter
		}
	}
	fxmin := solver.f.safe_eval(solver.xmin) or { return none }
	if fxmid * fxmin < 0.0 {
		solver.xmax = xmid
	} else {
		solver.xmin = xmid
	}

	return &BisectionIteration{
		x: xmid
		fx: fxmid
		n_calls: solver.n_calls
		n_iter: solver.n_iter
	}
}

// solve solves for the root of the function using the bisection method.
// If the maximum number of iterations is reached, an error is returned.
// If the root is found, the root is returned.
pub fn (mut solver Bisection) solve() !&BisectionIteration {
	mut result := &BisectionIteration{}
	for {
		iter := solver.next() or { break }
		result.x = iter.x
		result.fx = iter.fx
		result.n_calls = iter.n_calls
		result.n_iter = iter.n_iter
	}
	return result
}
