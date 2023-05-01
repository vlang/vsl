module roots

import vsl.func
import vsl.float.float64
import math

const (
	epsabs = 0.0001
	epsrel = 0.00001
	n_max  = 100
)

fn f_cos(x f64, _ []f64) f64 {
	return math.cos(x)
}

fn fdf_cos(x f64, _ []f64) (f64, f64) {
	return math.cos(x), -math.sin(x)
}

fn test_root_bisection() {
	f := func.new_func(f: f_cos)
	mut solver := new_bisection(f,
		xmin: 0.0
		xmax: 3.0
		epsrel: roots.epsrel
		epsabs: roots.epsabs
		n_max: roots.n_max
	)
	result := solver.solve()!
	assert float64.soclose(result.x, math.pi / 2.00, roots.epsabs)
}

fn test_root_newton() {
	x0 := f64(0.5)
	f := func.new_func_fdf(fdf: fdf_cos)
	result := newton(f, x0, roots.epsrel, roots.epsabs, roots.n_max)!
	assert float64.soclose(result, math.pi / 2.00, roots.epsabs)
}
