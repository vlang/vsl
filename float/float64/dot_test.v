module float64

import math

struct DotTest {
	x        []f64
	y        []f64
	want     f64
	want_rev f64
}

const (
	dot_tests = [
		DotTest{
			x: [2.0]
			y: [-3.0]
			want: -6
			want_rev: -6
		},
		DotTest{
			x: [2.0, 3]
			y: [-3.0, 4]
			want: 6
			want_rev: -1
		},
		DotTest{
			x: [2.0, 3, -4]
			y: [-3.0, 4, 5]
			want: -14
			want_rev: 34
		},
		DotTest{
			x: [2.0, 3, -4, -5]
			y: [-3.0, 4, 5, -6]
			want: 16
			want_rev: 2
		},
		DotTest{
			x: [0.0, 2, 3, -4, -5]
			y: [0.0, -3, 4, 5, -6]
			want: 16
			want_rev: 34
		},
		DotTest{
			x: [0.0, 0, 2, 3, -4, -5]
			y: [0.0, 1, -3, 4, 5, -6]
			want: 16
			want_rev: -5
		},
		DotTest{
			x: [0.0, 0, 1, 1, 2, -3, -4]
			y: [0.0, 1, 0, 3, -4, 5, -6]
			want: 4
			want_rev: -4
		},
		DotTest{
			x: [0.0, 0, 1, 1, 2, -3, -4, 5]
			y: [0.0, 1, 0, 3, -4, 5, -6, 7]
			want: 39
			want_rev: 3
		},
	]
)

fn test_dot_unitary() {
	for i, test in float64.dot_tests {
		x, x_front, x_back := new_guarded_vector(test.x, 1)
		y, y_front, y_back := new_guarded_vector(test.y, 1)
		got := dot_unitary(x, y)

		assert all_nan(x_front)
		assert all_nan(x_back)
		assert all_nan(y_front)
		assert all_nan(y_back)
		assert equal_strided(test.x, x, 1)
		assert equal_strided(test.y, y, 1)

		if math.is_nan(got) {
			continue
		}

		assert got == test.want
	}
}

fn test_dot_inc() {
	for i, test in float64.dot_tests {
		for incx in [-7, -3, -2, -1, 1, 2, 3, 7] {
			for incy in [-7, -3, -2, -1, 1, 2, 3, 7] {
				n := test.x.len
				x, x_front, x_back := new_guarded_vector(test.x, incx)
				y, y_front, y_back := new_guarded_vector(test.y, incy)
				mut ix := 0
				mut iy := 0
				if incx < 0 {
					ix = (-n + 1) * incx
				}
				if incy < 0 {
					iy = (-n + 1) * incy
				}

				got := dot_inc(x, y, u32(n), u32(incx), u32(incy), u32(ix), u32(iy))

				assert all_nan(x_front)
				assert all_nan(x_back)
				assert all_nan(y_front)
				assert all_nan(y_back)

				if math.is_nan(got) {
					continue
				}

				mut want := test.want
				if incx * incy < 0 {
					want = test.want_rev
				}

				assert got == want
			}
		}
	}
}
