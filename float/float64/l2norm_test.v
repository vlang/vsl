module float64

import math

// nanwith creates nan from payload
fn nanwith(payload u64) f64 {
	nan_bits := u64(0x7ff8000000000000)
	nan_mask := u64(0xfff8000000000000)
	return math.f64_from_bits(nan_bits | (payload & ~nan_mask))
}

struct L2NormTest {
	inc  int
	x    []f64
	y    []f64
	want f64
}

fn test_l2_norm_unitary() {
	tol := 1e-15

	mut src_gd := 1.0

	l2_norm_unitary_tests := [
		L2NormTest{
			want: 0.0
			x: []f64{}
		},
		L2NormTest{
			want: 2.0
			x: [2.0]
		},
		L2NormTest{
			want: 3.7416573867739413
			x: [1.0, 2, 3]
		},
		L2NormTest{
			want: 3.7416573867739413
			x: [-1.0, -2, -3]
		},
		L2NormTest{
			want: math.nan()
			x: [math.nan()]
		},
		L2NormTest{
			want: math.nan()
			x: [1.0, math.inf(1), 3, nanwith(25), 5]
		},
		L2NormTest{
			want: 17.88854381999832
			x: [8.0, -8, 8, -8, 8]
		},
		L2NormTest{
			want: 2.23606797749979
			x: [0.0, 1, 0, -1, 0, 1, 0, -1, 0, 1]
		},
	]

	for i, test in l2_norm_unitary_tests {
		g_ln := 4 + i % 2
		x := guard_vector(test.x, src_gd, g_ln)
		src := x[g_ln..x.len - g_ln]
		ret := l2_norm_unitary(src)
		assert tolerance(test.want, ret, tol)
		assert is_valid_guard(x, src_gd, g_ln)
	}
}

fn test_l2_norm_inc() {
	tol := 1e-15

	mut src_gd := 1.0

	l2_norm_inc_tests := [
		L2NormTest{
			inc: 2
			want: 0.0
			x: []f64{}
		},
		L2NormTest{
			inc: 3
			want: 2.0
			x: [2.0]
		},
		L2NormTest{
			inc: 10
			want: 3.7416573867739413
			x: [1.0, 2, 3]
		},
		L2NormTest{
			inc: 5
			want: 3.7416573867739413
			x: [-1.0, -2, -3]
		},
		L2NormTest{
			inc: 3
			want: math.nan()
			x: [math.nan()]
		},
		L2NormTest{
			inc: 15
			want: 17.88854381999832
			x: [8.0, -8, 8, -8, 8]
		},
		L2NormTest{
			inc: 1
			want: 2.23606797749979
			x: [0.0, 1, 0, -1, 0, 1, 0, -1, 0, 1]
		},
	]

	for i, test in l2_norm_inc_tests {
		g_ln, ln := 4 + i % 2, test.x.len
		x := guard_inc_vector(test.x, src_gd, test.inc, g_ln)
		src := x[g_ln..x.len - g_ln]
		ret := l2_norm_inc(src, u32(ln), u32(test.inc))
		assert tolerance(test.want, ret, tol)
		assert is_valid_inc_guard(x, src_gd, test.inc, g_ln)
	}
}

fn test_l2_distance_unitary() {
	tol := 1e-15

	mut src_gd := 1.0

	l2_distance_unitary_tests := [
		L2NormTest{
			want: 0.0
			x: []f64{}
			y: []f64{}
		},
		L2NormTest{
			want: 2.0
			x: [3.0]
			y: [1.0]
		},
		L2NormTest{
			want: 3.7416573867739413
			x: [2.0, 4, 6]
			y: [1.0, 2, 3]
		},
		L2NormTest{
			want: 3.7416573867739413
			x: [1.0, 2, 3]
			y: [2.0, 4, 6]
		},
		L2NormTest{
			want: math.nan()
			x: [math.nan()]
			y: [0.0]
		},
		L2NormTest{
			want: 17.88854381999832
			x: [9.0, -9, 9, -9, 9]
			y: [1.0, -1, 1, -1, 1]
		},
		L2NormTest{
			want: 2.23606797749979
			x: [0.0, 1, 0, -1, 0, 1, 0, -1, 0, 1]
			y: [0.0, 2, 0, -2, 0, 2, 0, -2, 0, 2]
		},
	]

	for i, test in l2_distance_unitary_tests {
		g_ln := 4 + i % 2
		x := guard_vector(test.x, src_gd, g_ln)
		y := guard_vector(test.y, src_gd, g_ln)
		src_x := x[g_ln..x.len - g_ln]
		src_y := y[g_ln..y.len - g_ln]
		ret := l2_distance_unitary(src_x, src_y)
		assert tolerance(test.want, ret, tol)
		assert is_valid_guard(x, src_gd, g_ln)
	}
}
