module float32

import math

struct L2NormTest {
	inc  int
	x    []f32
	y    []f32
	want f32
}

fn test_l2_norm_unitary() {
	tol := f32(1e-7)

	mut src_gd := f32(1.0)

	l2_norm_unitary_tests := [
		L2NormTest{
			want: f32(0.0)
			x:    []f32{}
		},
		L2NormTest{
			want: f32(2.0)
			x:    [f32(2.0)]
		},
		L2NormTest{
			want: f32(3.7416573867739413)
			x:    [f32(1.0), 2, 3]
		},
		L2NormTest{
			want: f32(3.7416573867739413)
			x:    [f32(-1.0), -2, -3]
		},
		L2NormTest{
			want: f32(math.nan())
			x:    [f32(math.nan())]
		},
		L2NormTest{
			want: f32(17.88854381999832)
			x:    [f32(8.0), -8, 8, -8, 8]
		},
		L2NormTest{
			want: f32(2.23606797749979)
			x:    [f32(0.0), 1, 0, -1, 0, 1, 0, -1, 0, 1]
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

fn test_l2_norm_unitary_simd_matches_f64_reference_and_keeps_extreme_fallback() {
	mut values := []f32{len: 257}
	mut reference_sum := 0.0
	for i in 0 .. values.len {
		values[i] = f32((i % 13) - 6) * 0.25
		reference_sum += f64(values[i]) * f64(values[i])
	}
	assert tolerance(f32(math.sqrt(reference_sum)), l2_norm_unitary(values), f32(1e-6))

	large_values := []f32{len: 64, init: f32(1e20)}
	large_reference := math.sqrt(64 * f64(large_values[0]) * f64(large_values[0]))
	assert tolerance(f32(large_reference), l2_norm_unitary(large_values), f32(1e-6))

	tiny_values := []f32{len: 64, init: f32(1e-30)}
	tiny_reference := math.sqrt(64 * f64(tiny_values[0]) * f64(tiny_values[0]))
	assert tolerance(f32(tiny_reference), l2_norm_unitary(tiny_values), f32(1e-6))

	mut non_finite := []f32{len: 64, init: 1}
	non_finite[0] = f32(math.inf(1))
	non_finite[63] = f32(math.nan())
	assert math.is_nan(f64(l2_norm_unitary(non_finite)))
}

fn test_l2_norm_inc() {
	tol := f32(1e-7)

	mut src_gd := f32(1.0)

	l2_norm_inc_tests := [
		L2NormTest{
			inc:  2
			want: f32(0.0)
			x:    []f32{}
		},
		L2NormTest{
			inc:  3
			want: f32(2.0)
			x:    [f32(2.0)]
		},
		L2NormTest{
			inc:  10
			want: f32(3.7416573867739413)
			x:    [f32(1.0), 2, 3]
		},
		L2NormTest{
			inc:  5
			want: f32(3.7416573867739413)
			x:    [f32(-1.0), -2, -3]
		},
		L2NormTest{
			inc:  3
			want: f32(math.nan())
			x:    [f32(math.nan())]
		},
		L2NormTest{
			inc:  15
			want: f32(17.88854381999832)
			x:    [f32(8.0), -8, 8, -8, 8]
		},
		L2NormTest{
			inc:  1
			want: f32(2.23606797749979)
			x:    [f32(0.0), 1, 0, -1, 0, 1, 0, -1, 0, 1]
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
	tol := f32(1e-7)

	mut src_gd := f32(1.0)

	l2_distance_unitary_tests := [
		L2NormTest{
			want: f32(0.0)
			x:    []f32{}
			y:    []f32{}
		},
		L2NormTest{
			want: f32(2.0)
			x:    [f32(3.0)]
			y:    [f32(1.0)]
		},
		L2NormTest{
			want: f32(3.7416573867739413)
			x:    [f32(2.0), 4, 6]
			y:    [f32(1.0), 2, 3]
		},
		L2NormTest{
			want: f32(3.7416573867739413)
			x:    [f32(1.0), 2, 3]
			y:    [f32(2.0), 4, 6]
		},
		L2NormTest{
			want: f32(math.nan())
			x:    [f32(math.nan())]
			y:    [f32(0.0)]
		},
		L2NormTest{
			want: f32(17.88854381999832)
			x:    [f32(9.0), -9, 9, -9, 9]
			y:    [f32(1.0), -1, 1, -1, 1]
		},
		L2NormTest{
			want: f32(2.23606797749979)
			x:    [f32(0.0), 1, 0, -1, 0, 1, 0, -1, 0, 1]
			y:    [f32(0.0), 2, 0, -2, 0, 2, 0, -2, 0, 2]
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
