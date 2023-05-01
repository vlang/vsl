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

mut solver := roots.new_bisection(f)

solver.xmin = 0.0
solver.xmax = 3.0
solver.epsabs = epsabs
solver.epsrel = epsrel
solver.n_max = n_max

result := solver.solve()!

expected := math.pi / 2.0
assert math.abs(result.x - expected) < epsabs

println('x = ${result.x}')
