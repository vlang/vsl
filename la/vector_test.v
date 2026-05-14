module la

import vsl.float.float64

fn tolerance_equal(data1 []f64, data2 []f64) bool {
	if data1.len != data2.len {
		return false
	}
	for i := 0; i < data1.len; i++ {
		if !float64.veryclose(data1[i], data2[i]) {
			return false
		}
	}
	return true
}

fn test_vector_apply() {
	mut a := []f64{len: 5}
	b := [1.0, 2, 3, 4, 5]
	res := [2.0, 4, 6, 8, 10]
	vector_apply(mut a, 2, b)
	assert tolerance_equal(a, res)
}

fn test_vector_apply_func() {
	func := fn (i int, x f64) f64 {
		return x + i
	}
	mut a := [1.0, 2, 3, 4, 5]
	res := [1.0, 3, 5, 7, 9]
	vector_apply_func(mut a, func)
	assert tolerance_equal(a, res)
}

fn test_vector_unit() {
	mut a := [3.0, 4]
	res := [0.6, 0.8]
	assert tolerance_equal(res, vector_unit(mut a))

	a = [0.0]
	assert tolerance_equal(a, vector_unit(mut a))
}

fn test_vector_accum() {
	a := [1.0, 2, -3]
	s := 0.0
	assert float64.close(vector_accum(a), s)
}

fn test_vector_norm() {
	a := [3.0, 4]
	n := 5.0
	assert float64.close(vector_norm(a), n)
}

fn test_vector_rms() {
	octave_val := 3.5355
	assert float64.tolerance(vector_rms([3.0, 4]), octave_val, 1e-5)
}

fn test_vector_norm_diff() {
	a := [4.0, 7]
	b := [1.0, 3]
	n := 5.0
	assert float64.close(vector_norm_diff(a, b), n)
}

fn test_vector_largest() {
	a := [3.0, 4]
	l := 2.0
	assert float64.close(vector_largest(a, 2), l)
}

fn test_vector_cosine_similarity() {
	a := [1.0, 2.0, 3.0]
	b := [4.0, 5.0, 6.0]
	c := [1.0, 0.0, 0.0]
	d := [0.0, 1.0, 0.0]

	// Cosine similarity of a and b (should be close to 0.974631846)
	assert float64.tolerance(vector_cosine_similarity(a, b), 0.974631846, 1e-8)

	// Cosine similarity of a with itself (should be exactly 1)
	assert float64.close(vector_cosine_similarity(a, a), 1.0)

	// Cosine similarity of perpendicular vectors (should be 0)
	assert float64.close(vector_cosine_similarity(c, d), 0.0)

	// Cosine similarity of a zero vector with another vector (should be 0)
	zero_vector := [0.0, 0.0, 0.0]
	assert float64.close(vector_cosine_similarity(zero_vector, a), 0.0)
}
