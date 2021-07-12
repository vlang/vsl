module float64

import rand

struct ScalTest {
	alpha f64
	x     []f64
	want  []f64
}

const (
	scal_tests = [
		ScalTest{
			alpha: 0.
			x: []f64{}
			want: []f64{}
		},
		ScalTest{
			alpha: 0.
			x: [1.]
			want: [0.]
		},
		ScalTest{
			alpha: 1.
			x: [1.]
			want: [1.]
		},
		ScalTest{
			alpha: 2.
			x: [1., -2]
			want: [2., -4]
		},
		ScalTest{
			alpha: 2.
			x: [1., -2, 3]
			want: [2., -4, 6]
		},
		ScalTest{
			alpha: 2.
			x: [1., -2, 3, 4]
			want: [2., -4, 6, 8]
		},
		ScalTest{
			alpha: 2.
			x: [1., -2, 3, 4, -5]
			want: [2., -4, 6, 8, -10]
		},
		ScalTest{
			alpha: 2.
			x: [0., 1, -2, 3, 4, -5, 6, -7]
			want: [0., 2, -4, 6, 8, -10, 12, -14]
		},
		ScalTest{
			alpha: 2.
			x: [0., 1, -2, 3, 4, -5, 6, -7, 8]
			want: [0., 2, -4, 6, 8, -10, 12, -14, 16]
		},
		ScalTest{
			alpha: 2.
			x: [0., 1, -2, 3, 4, -5, 6, -7, 8, 9]
			want: [0., 2, -4, 6, 8, -10, 12, -14, 16, 18]
		},
		ScalTest{
			alpha: 3.
			x: [0., 1, -2, 3, 4, -5, 6, -7, 8, 9, 12]
			want: [0., 3, -6, 9, 12, -15, 18, -21, 24, 27, 36]
		},
	]
)

fn test_scal_unitary() {
	x_gd_val := -0.5

	for test in float64.scal_tests {
		for align in align1 {
			xg_ln := 4 + align
			xg := guard_vector(test.x, x_gd_val, xg_ln)
			mut x := xg[xg_ln..xg.len - xg_ln]

			scal_unitary(test.alpha, mut x)

			for i, w in test.want {
				assert same(x[i], w)
			}

			assert is_valid_guard(xg, x_gd_val, xg_ln)
		}
	}
}

fn test_scal_unitary_to() {
	rand.seed([u32(42), u32(42)])
	x_gd_val, dst_gd_val := -1., 0.5

	for test in float64.scal_tests {
		n := test.x.len
		for align in align2 {
			xg_ln, dg_ln := 4 + align.x, 4 + align.y
			xg := guard_vector(test.x, x_gd_val, xg_ln)
			dg := guard_vector(random_slice(n, 1), dst_gd_val, dg_ln)
			x := xg[xg_ln..xg.len - xg_ln]
			mut dst := dg[dg_ln..dg.len - dg_ln]

			scal_unitary_to(mut dst, test.alpha, x)

			for i, w in test.want {
				assert same(dst[i], w)
			}

			assert is_valid_guard(xg, x_gd_val, xg_ln)
			assert is_valid_guard(dg, dst_gd_val, dg_ln)
			assert equal_strided(test.x, x, 1)
		}
	}
}

fn test_scal_inc() {
	x_gd_val := -0.5
	gd_ln := 4

	for test in float64.scal_tests {
		n := test.x.len
		for incx in [1, 2, 3, 4, 7, 10] {
			xg := guard_inc_vector(test.x, x_gd_val, incx, gd_ln)
			mut x := xg[gd_ln..xg.len - gd_ln]

			scal_inc(test.alpha, mut x, u32(n), u32(incx))

			for i, w in test.want {
				assert same(x[i * incx], w)
			}

			assert is_valid_inc_guard(xg, x_gd_val, incx, gd_ln)
		}
	}
}

fn test_scal_inc_to() {
	rand.seed([u32(42), u32(42)])
	x_gd_val, dst_gd_val := -1., 0.5
	gd_ln := 4

	for test in float64.scal_tests {
		n := test.x.len
		for inc in new_inc_set(1, 2, 3, 4, 7, 10) {
			xg := guard_inc_vector(test.x, x_gd_val, inc.x, gd_ln)
			dg := guard_inc_vector(random_slice(n, 1), dst_gd_val, inc.y, gd_ln)
			x := xg[gd_ln..xg.len - gd_ln]
			mut dst := dg[gd_ln..dg.len - gd_ln]

			scal_inc_to(mut dst, u32(inc.y), test.alpha, x, u32(n), u32(inc.x))

			for i, w in test.want {
				assert same(dst[i * inc.y], w)
			}

			assert is_valid_inc_guard(xg, x_gd_val, inc.x, gd_ln)
			assert is_valid_inc_guard(dg, dst_gd_val, inc.y, gd_ln)
			assert equal_strided(test.x, x, inc.x)
		}
	}
}
