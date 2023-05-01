module main

import vsl.func
import vsl.roots
import math

const (
	tol = 1e-10
)

fn yx(x f64, _ []f64) f64 {
	return math.pow(x, 3.0) - 0.165 * math.pow(x, 2.0) + 3.993e-4
}

// range: be sure to enclose root
xa, xb := 0.0, 0.11

f := func.new_func(f: yx)
result, err := roots.brent(f, xa, xb, tol)!

expected := 0.0623775815137495

assert math.abs(result - expected) < err

println(result)
