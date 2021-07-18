module fun

import vsl.float.float64

fn test_interp_cubic_01() {
	// test set
	ycor := fn (x f64) f64 {
		return x * x * x - 3 * x * x - 144 * x + 432
	}
	dcor := fn (x f64) f64 {
		return 3 * x * x - 6 * x - 144
	}
	x0, y0 := -12.0, 0.0
	x1, y1 := -6.0, 972.0
	x2, y2 := 1.0, 286.0
	x3, y3 := 12.0, 0.0

	// intepolator
	mut interp := new_interp_cubic()
	interp.fit_4points(x0, y0, x1, y1, x2, y2, x3, y3) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 1.0, 8.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert float64.tolerance(y, ycor(x), 1e-15)
		assert float64.tolerance(yd, dcor(x), 1e-15)
	}

	// check critical points
	xmin, xmax, xifl, has_min, has_max, has_ifl := interp.critical()
	assert has_min
	assert has_max
	assert has_ifl
	assert float64.tolerance(xmin, 8, 1e-15)
	assert float64.tolerance(xmax, -6, 1e-15)
	assert float64.tolerance(xifl, 1, 1e-15)
}

fn test_interp_cubic_02() {
	// test set
	ycor := fn (x f64) f64 {
		return pow3(x - 25) + 450
	}
	dcor := fn (x f64) f64 {
		return 3 * pow2(x - 25)
	}
	x0, x1, x2, x3 := 22.0, 23.0, 24.0, 25.0
	y0, y1, y2, y3 := ycor(x0), ycor(x1), ycor(x2), ycor(x3)

	// intepolator
	mut interp := new_interp_cubic()
	interp.fit_4points(x0, y0, x1, y1, x2, y2, x3, y3) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 5.0, 100.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert float64.tolerance(y, ycor(x), 1e-15)
		assert float64.tolerance(yd, dcor(x), 1e-15)
	}

	// check critical points
	_, _, xifl, has_min, has_max, has_ifl := interp.critical()
	assert !has_min
	assert !has_max
	assert has_ifl
	assert float64.tolerance(xifl, 25, 1e-15)
}

fn test_interp_cubic_03() {
	// test set
	ycor := fn (x f64) f64 {
		return x * x * x + x * x + x + 1
	}
	dcor := fn (x f64) f64 {
		return 3 * x * x + 2 * x + 1
	}
	x0, x1, x2, x3 := -2.0, -1.0, 1.0, 2.0
	y0, y1, y2, y3 := ycor(x0), ycor(x1), ycor(x2), ycor(x3)

	// intepolator
	mut interp := new_interp_cubic()
	interp.fit_4points(x0, y0, x1, y1, x2, y2, x3, y3) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 5.0, 100.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert float64.tolerance(y, ycor(x), 1e-15)
		assert float64.tolerance(yd, dcor(x), 1e-15)
	}

	// check critical points
	_, _, _, has_min, has_max, has_ifl := interp.critical()
	assert !has_min
	assert !has_max
	assert !has_ifl
}

fn test_interp_cubic_04() {
	// test set
	ycor := fn (x f64) f64 {
		return x * x * x - 3 * x * x - 144 * x + 432
	}
	dcor := fn (x f64) f64 {
		return 3 * x * x - 6 * x - 144
	}
	x0, y0 := -12.0, 0.0
	x1, y1 := -6.0, 972.0
	x2, y2 := 1.0, 286.0
	x3, d3 := 8.0, 0.0

	// intepolator
	mut interp := new_interp_cubic()
	interp.fit_3points_d(x0, y0, x1, y1, x2, y2, x3, d3) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 1.0, 8.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert float64.tolerance(y, ycor(x), 1e-15)
		assert float64.tolerance(yd, dcor(x), 1e-15)
	}

	// check critical points
	xmin, xmax, xifl, has_min, has_max, has_ifl := interp.critical()
	assert has_min
	assert has_max
	assert has_ifl
	assert float64.tolerance(xmin, 8, 1e-15)
	assert float64.tolerance(xmax, -6, 1e-15)
	assert float64.tolerance(xifl, 1, 1e-15)
}
