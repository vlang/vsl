module float32

const axpy_tests = [
	AxpyTest{
		alpha: f32(0.0)
		x: []f32{}
		y: []f32{}
		want: []f32{}
		want_rev: []f32{}
	},
	AxpyTest{
		alpha: f32(0)
		x: [f32(2.0)]
		y: [f32(-3.0)]
		want: [f32(-3.0)]
		want_rev: [f32(-3.0)]
	},
	AxpyTest{
		alpha: f32(1.0)
		x: [f32(2.0)]
		y: [f32(-3.0)]
		want: [f32(-1.0)]
		want_rev: [f32(-1.0)]
	},
	AxpyTest{
		alpha: f32(3.0)
		x: [f32(2.0)]
		y: [f32(-3.0)]
		want: [f32(3.0)]
		want_rev: [f32(3.0)]
	},
	AxpyTest{
		alpha: f32(-3.0)
		x: [f32(2.0)]
		y: [f32(-3.0)]
		want: [f32(-9.0)]
		want_rev: [f32(-9.0)]
	},
	AxpyTest{
		alpha: f32(1.0)
		x: [f32(1.0), 5]
		y: [f32(2.0), -3]
		want: [f32(3.0), 2]
		want_rev: [f32(7.0), -2]
	},
	AxpyTest{
		alpha: f32(1.0)
		x: [f32(2.0), 3, 4]
		y: [f32(-3.0), -2, -1]
		want: [f32(-1.0), 1, 3]
		want_rev: [f32(1.0), 1, 1]
	},
	AxpyTest{
		alpha: f32(0.0)
		x: [f32(0.0), 0, 1, 1, 2, -3, -4]
		y: [f32(0.0), 1, 0, 3, -4, 5, -6]
		want: [f32(0.0), 1, 0, 3, -4, 5, -6]
		want_rev: [f32(0.0), 1, 0, 3, -4, 5, -6]
	},
	AxpyTest{
		alpha: f32(1.0)
		x: [f32(0.0), 0, 1, 1, 2, -3, -4]
		y: [f32(0.0), 1, 0, 3, -4, 5, -6]
		want: [f32(0.0), 1, 1, 4, -2, 2, -10]
		want_rev: [f32(-4.0), -2, 2, 4, -3, 5, -6]
	},
	AxpyTest{
		alpha: f32(3.0)
		x: [f32(0.0), 0, 1, 1, 2, -3, -4]
		y: [f32(0.0), 1, 0, 3, -4, 5, -6]
		want: [f32(0.0), 1, 3, 6, 2, -4, -18]
		want_rev: [f32(-12.0), -8, 6, 6, -1, 5, -6]
	},
	AxpyTest{
		alpha: f32(-3.0)
		x: [f32(0.0), 0, 1, 1, 2, -3, -4, 0, 0, 1, 1, 2, -3, -4]
		y: [f32(0.0), 1, 0, 3, -4, 5, -6, 0, 1, 0, 3, -4, 5, -6]
		want: [f32(0.0), 1, -3, 0, -10, 14, 6, 0, 1, -3, 0, -10, 14, 6]
		want_rev: [f32(12.0), 10, -6, 0, -7, 5, -6, 12, 10, -6, 0, -7, 5, -6]
	},
	AxpyTest{
		alpha: f32(-5.0)
		x: [f32(0.0), 0, 1, 1, 2, -3, -4, 5, 1, 2, -3, -4, 5]
		y: [f32(0.0), 1, 0, 3, -4, 5, -6, 7, 3, -4, 5, -6, 7]
		want: [f32(0.0), 1, -5, -2, -14, 20, 14, -18, -2, -14, 20, 14, -18]
		want_rev: [f32(-25.0), 21, 15, -7, -9, -20, 14, 22, -7, -9, 0, -6, 7]
	},
]

struct AxpyTest {
	alpha    f32
	x        []f32
	y        []f32
	want     []f32
	want_rev []f32 // Result when x is traversed in reverse direction.
}

fn test_axpy_unitary() {
	x_gd_val, y_gd_val := f32(-1.0), f32(1.5)

	for test in float32.axpy_tests {
		for align in align2 {
			xg_ln, yg_ln := 4 + align.x, 4 + align.y
			xg, yg := guard_vector(test.x, x_gd_val, xg_ln), guard_vector(test.y, y_gd_val,
				yg_ln)
			x, mut y := xg[xg_ln..xg.len - xg_ln], unsafe { yg[yg_ln..yg.len - yg_ln] }
			axpy_unitary(test.alpha, x, mut y)

			assert is_valid_guard(xg, x_gd_val, xg_ln)
			assert is_valid_guard(yg, y_gd_val, yg_ln)
			assert equal_strided(test.x, x, 1)

			for i, w in test.want {
				assert same(y[i], w)
			}
		}
	}
}

fn test_axpy_unitary_to() {
	dst_gd_val, x_gd_val, y_gd_val := f32(1.0), f32(-1.0), f32(1.5)

	for test in float32.axpy_tests {
		for align in align3 {
			dg_ln, xg_ln, yg_ln := 4 + align.dst, 4 + align.x, 4 + align.y
			dst_orig := []f32{len: test.x.len}
			xg, yg := guard_vector(test.x, x_gd_val, xg_ln), guard_vector(test.y, y_gd_val,
				yg_ln)
			dstg := guard_vector(dst_orig, dst_gd_val, dg_ln)
			x, y := xg[xg_ln..xg.len - xg_ln], yg[yg_ln..yg.len - yg_ln]
			mut dst := unsafe { dstg[dg_ln..dstg.len - dg_ln] }
			axpy_unitary_to(mut dst, test.alpha, x, y)

			assert is_valid_guard(xg, x_gd_val, xg_ln)
			assert is_valid_guard(yg, y_gd_val, yg_ln)
			assert is_valid_guard(dstg, dst_gd_val, dg_ln)
			assert equal_strided(test.x, x, 1)
			assert equal_strided(test.y, y, 1)

			for i, w in test.want {
				assert same(dst[i], w)
			}
		}
	}
}

fn test_axpy_inc() {
	x_gd_val, y_gd_val := f32(-1.0), f32(1.5)
	gd_ln := 4

	for test in float32.axpy_tests {
		n := test.x.len

		for inc in IncSet.new(-7, -4, -3, -2, -1, 1, 2, 3, 4, 7) {
			mut ix := 0
			mut iy := 0
			if inc.x < 0 {
				ix = (-n + 1) * inc.x
			}
			if inc.y < 0 {
				iy = (-n + 1) * inc.y
			}
			xg, yg := guard_inc_vector(test.x, x_gd_val, inc.x, gd_ln), guard_inc_vector(test.y,
				y_gd_val, inc.y, gd_ln)
			x, mut y := xg[gd_ln..xg.len - gd_ln], unsafe { yg[gd_ln..yg.len - gd_ln] }
			axpy_inc(test.alpha, x, mut y, u32(n), u32(inc.x), u32(inc.y), u32(ix), u32(iy))

			assert equal_strided(test.x, x, inc.x)

			mut want := test.want.clone()
			incx := inc.x
			mut incy := inc.y
			if incx * incy < 0 {
				want = test.want_rev.clone()
			}
			if incy < 0 {
				incy = -incy
			}

			for i, w in want {
				assert same(y[i * incy], w)
			}
		}
	}
}

fn test_axpy_inc_to() {
	dst_gd_val, x_gd_val, y_gd_val := 1, f32(-1.0), f32(1.5)
	gd_ln := 4

	for test in float32.axpy_tests {
		n := test.x.len

		for inc in IncToSet.new(-7, -4, -3, -2, -1, 1, 2, 3, 4, 7) {
			mut ix := 0
			mut iy := 0
			mut idst := u32(0)
			if inc.x < 0 {
				ix = (-n + 1) * inc.x
			}
			if inc.y < 0 {
				iy = (-n + 1) * inc.y
			}
			if inc.dst < 0 {
				idst = u32((-n + 1) * inc.dst)
			}
			dst_orig := []f32{len: test.want.len}
			xg, yg := guard_inc_vector(test.x, x_gd_val, inc.x, gd_ln), guard_inc_vector(test.y,
				y_gd_val, inc.y, gd_ln)
			dstg := guard_inc_vector(dst_orig, dst_gd_val, inc.dst, gd_ln)
			x, y := xg[gd_ln..xg.len - gd_ln], yg[gd_ln..yg.len - gd_ln]
			mut dst := unsafe { dstg[gd_ln..dstg.len - gd_ln] }
			axpy_inc_to(mut dst, u32(inc.dst), idst, test.alpha, x, y, u32(n), u32(inc.x),
				u32(inc.y), u32(ix), u32(iy))

			assert equal_strided(test.x, x, inc.x)
			assert equal_strided(test.y, y, inc.y)

			mut want := test.want.clone()
			incx := inc.x
			mut incy := inc.y
			mut incdst := inc.dst
			mut iw, mut inc_w := 0, 1
			if incx * incy < 0 {
				want = test.want_rev.clone()
			}
			if incy * inc.dst < 0 {
				iw, inc_w = want.len - 1, -1
			}
			if incdst < 0 {
				incdst = -incdst
			}

			for i, _ in want {
				assert same(dst[i * incdst], want[iw + i * inc_w])
			}
		}
	}
}
