module poly

import math

fn assert_bspline_close(actual f64, expected f64, tolerance f64) {
	assert math.abs(actual - expected) < tolerance
}

fn test_quadratic_bspline_basis_partition_and_endpoints() {
	knots := [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]
	b0 := bspline_basis(2, knots, 0, 0.5) or { panic(err) }
	b1 := bspline_basis(2, knots, 1, 0.5) or { panic(err) }
	b2 := bspline_basis(2, knots, 2, 0.5) or { panic(err) }
	assert_bspline_close(b0, 0.25, 1e-12)
	assert_bspline_close(b1, 0.5, 1e-12)
	assert_bspline_close(b2, 0.25, 1e-12)
	assert_bspline_close(b0 + b1 + b2, 1.0, 1e-12)
	assert_bspline_close(bspline_basis(2, knots, 0, 0.0) or { panic(err) }, 1.0, 1e-12)
	assert_bspline_close(bspline_basis(2, knots, 2, 1.0) or { panic(err) }, 1.0, 1e-12)
}

fn test_de_boor_evaluates_quadratic_bezier_curve() {
	curve := new_bspline_curve(2, [0.0, 0.0, 0.0, 1.0, 1.0, 1.0], [[0.0], [1.0], [0.0]]) or {
		panic(err)
	}
	assert_bspline_close((curve.evaluate(0.0) or { panic(err) })[0], 0.0, 1e-12)
	assert_bspline_close((curve.evaluate(0.5) or { panic(err) })[0], 0.5, 1e-12)
	assert_bspline_close((curve.evaluate(1.0) or { panic(err) })[0], 0.0, 1e-12)
}

fn test_de_boor_evaluates_piecewise_linear_curve() {
	curve := new_bspline_curve(1, [0.0, 0.0, 1.0, 2.0, 2.0], [[0.0], [1.0], [3.0]]) or {
		panic(err)
	}
	assert_bspline_close((curve.evaluate(0.5) or { panic(err) })[0], 0.5, 1e-12)
	assert_bspline_close((curve.evaluate(1.0) or { panic(err) })[0], 1.0, 1e-12)
	assert_bspline_close((curve.evaluate(2.0) or { panic(err) })[0], 3.0, 1e-12)
}

fn test_knot_insertion_preserves_curve_shape() {
	curve := new_bspline_curve(2, [0.0, 0.0, 0.0, 1.0, 1.0, 1.0], [[0.0, 0.0], [1.0, 2.0], [2.0,
		0.0]]) or {
		panic(err)
	}
	inserted := curve.insert_knot(0.5) or { panic(err) }
	assert inserted.knots == [0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]
	assert inserted.control_points.len == curve.control_points.len + 1
	for u in [0.0, 0.125, 0.25, 0.5, 0.75, 0.875, 1.0] {
		before := curve.evaluate(u) or { panic(err) }
		after := inserted.evaluate(u) or { panic(err) }
		for dimension in 0 .. before.len {
			assert_bspline_close(after[dimension], before[dimension], 1e-12)
		}
	}
}
