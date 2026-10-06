module main

import vsl.poly

fn main() {
	curve := poly.new_bspline_curve(2,
		[0.0, 0.0, 0.0, 1.0, 1.0, 1.0],
		[[0.0, 0.0], [1.0, 2.0], [2.0, 0.0]]) or { panic(err) }

	println('sampled quadratic B-spline:')
	for sample_index in 0 .. 5 {
		u := f64(sample_index) / 4.0
		point := curve.evaluate(u) or { panic(err) }
		println('u=${u}: ${point}')
	}

	refined := curve.insert_knot(0.5) or { panic(err) }
	println('refined knot vector: ${refined.knots}')
	println('basis N_1,2(0.5): ${poly.bspline_basis(2, curve.knots, 1, 0.5) or { panic(err) }}')
}
