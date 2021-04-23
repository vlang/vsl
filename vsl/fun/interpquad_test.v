module fun

fn test_interp_quad_01() {
	// test set
	ycor := fn (x f64) f64 {
		return 1.0 + (x - 1.0) * (x - 1.0)
	}
	dcor := fn (x f64) f64 {
		return 2.0 * (x - 1.0)
	}
	x0, y0 := 0.0, 2.0
	x1, y1 := 2.0, 2.0
	x2, y2 := 3.0, 5.0

	// intepolator
	mut interp := new_interp_quad()
	interp.fit_3points(x0, y0, x1, y1, x2, y2) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 1.0, 8.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert tolerance(y, ycor(x), 1e-15)
		assert tolerance(yd, dcor(x), 1e-15)
	}

	// check optimum
	xopt, fopt := interp.optimum()
	assert tolerance(xopt, 1.0, 1e-15)
	assert tolerance(fopt, 1.0, 1e-15)
}

fn test_interp_quad_02() {
	// test set (flipped compared to previous test)
	ycor := fn (x f64) f64 {
		return 3.0 - (x - 1.0) * (x - 1.0)
	}
	dcor := fn (x f64) f64 {
		return -2.0 * (x - 1.0)
	}
	x0, y0 := 0.0, 2.0
	x1, y1 := 2.0, 2.0
	x2, y2 := 3.0, -1.0

	// intepolator
	mut interp := new_interp_quad()
	interp.fit_3points(x0, y0, x1, y1, x2, y2) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 1.0, 8.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert tolerance(y, ycor(x), 1e-15)
		assert tolerance(yd, dcor(x), 1e-15)
	}

	// check optimum
	xopt, fopt := interp.optimum()
	assert tolerance(xopt, 1.0, 1e-15)
	assert tolerance(fopt, 3.0, 1e-15)
}

fn test_interp_quad_03() {
	// test set
	ycor := fn (x f64) f64 {
		return 1.0 + (x - 1.0) * (x - 1.0)
	}
	dcor := fn (x f64) f64 {
		return 2.0 * (x - 1.0)
	}
	x0, y0 := 0.0, 2.0
	x1, y1 := 2.0, 2.0
	x2, d2 := -1.0, -4.0

	// intepolator
	mut interp := new_interp_quad()
	interp.fit_2points_d(x0, y0, x1, y1, x2, d2) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 1.0, 8.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert tolerance(y, ycor(x), 1e-15)
		assert tolerance(yd, dcor(x), 1e-15)
	}

	// check optimum
	xopt, fopt := interp.optimum()
	assert tolerance(xopt, 1.0, 1e-15)
	assert tolerance(fopt, 1.0, 1e-15)
}

fn test_interp_quad_04() {
	// test set (flipped compared to previous test)
	ycor := fn (x f64) f64 {
		return 3.0 - (x - 1.0) * (x - 1.0)
	}
	dcor := fn (x f64) f64 {
		return -2.0 * (x - 1.0)
	}
	x0, y0 := 0.0, 2.0
	x1, y1 := 2.0, 2.0
	x2, d2 := -1.0, 4.0

	// intepolator
	mut interp := new_interp_quad()
	interp.fit_2points_d(x0, y0, x1, y1, x2, d2) or { panic(err) }

	// check model and derivatives
	for x in [-10.0, 0.0, 1.0, 8.0] {
		y := interp.f(x)
		yd := interp.g(x)
		assert tolerance(y, ycor(x), 1e-15)
		assert tolerance(yd, dcor(x), 1e-15)
	}

	// check optimum
	xopt, fopt := interp.optimum()
	assert tolerance(xopt, 1.0, 1e-15)
	assert tolerance(fopt, 3.0, 1e-15)
}
