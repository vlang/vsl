module la

import math
import math.util

fn feq(a f64, n f64) bool {
	return util.fabs_64(a - n) < math.max(n / 1000, 0.001) // 0.1% error, or min diff
}

fn test_vector_apply() {
	mut a := []f64{len: 5}
	b := [1.0, 2, 3, 4, 5]
	res := [2.0, 4, 6, 8, 10]
	vector_apply(mut a, 2, b)
	assert a == res // Should be exact as it is simple f64 mul
}

fn test_vector_apply_func() {
	func := fn (i int, x f64) f64 {
		return x + i
	}
	mut a := [1.0, 2, 3, 4, 5]
	res := [1.0, 3, 5, 7, 9]
	vector_apply_func(mut a, func)
	assert a == res // Should be exact as it is simple f64 mul
}

fn test_vector_unit() {
	mut a := [3.0, 4] // Pythagorean sides
	// res := [0.6,0.8] // This fails, due to floating point error of inverse (1.0 / x)
	res := [0.6000000000000001, 0.8] // This is the result
	assert res == vector_unit(mut a)

	// 0 vectors should stay the same
	a = [0.0]
	assert a == vector_unit(mut a)
}

fn test_vector_accum() {
	a := [1.0, 2, -3]
	s := 0.0
	assert feq(vector_accum(a), s)
	// assert vector_accum(a) == s
}

fn test_vector_norm() {
	a := [3.0, 4]
	n := 5.0
	assert feq(vector_norm(a), n)
}

fn test_vector_rms() {
	octave_val := 3.5355 // Calculated in GNU octave
	assert feq(vector_rms([3.0, 4]), octave_val)
}

fn test_vector_norm_diff() {
	a := [4.0, 7]
	b := [1.0, 3]
	n := 5.0
	assert feq(vector_norm_diff(a, b), n)
}

fn test_vector_largest() {
	a := [3.0, 4]
	l := 2.0
	assert feq(vector_largest(a, 2), l)
}
