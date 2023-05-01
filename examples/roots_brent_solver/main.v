module main

import vsl.func
import vsl.roots
import math

const (
	tol   = 1e-10
	n_max = 100
)

fn yx(x f64, _ []f64) f64 {
	return math.pow(x, 3.0) - 0.165 * math.pow(x, 2.0) + 3.993e-4
}

// range: be sure to enclose root
xa, xb := 0.0, 0.11

f := func.new_func(f: yx)
mut solver := roots.new_brent(f)

solver.x1 = xa
solver.x2 = xb
solver.tol = tol
solver.n_max = n_max

expected := 0.0623775815137495

result := solver.solve()!

assert math.abs(result.x - expected) < epsabs

println('x = ${result.x}')
