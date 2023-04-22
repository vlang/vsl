module main

import vsl.func
import vsl.roots
import math

const (
	epsabs = 0.0001
	epsrel = 0.00001
	n_max  = 100
)

fn cos(x f64, _ []f64) f64 {
	return math.cos(x)
}

f := func.new_func(f: cos)
result := roots.bisection(f, 0.0, 3.0, epsrel, epsabs, n_max)!

assert result == math.pi / 2.00

println(result)
