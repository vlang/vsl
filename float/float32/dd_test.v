module float32

import math

fn test_f32_sum_dd_recovers_terms_lost_by_naive_sum() {
	x := [f32(16777216.0), 1.0, -16777216.0]
	mut naive := f32(0.0)
	for value in x {
		naive += value
	}
	assert naive == 0.0 // 2^24 + 1 rounds back to 2^24 in f32

	hi, lo := sum_dd(x)
	assert hi == 1.0
	assert lo == 0.0
	assert sum_compensated(x) == 1.0
}

fn test_f32_sum_compensated_rounds_like_the_exact_sum() {
	// Exact sum: 1 + 1000 * 2^-25 = 1 + 250 * 2^-23, exactly 250
	// f32 ulps above 1.0. Sequential f32 addition never moves off
	// 1.0, because each 2^-25 increment is below half an ulp of 1.0.
	mut x := []f32{len: 1001}
	x[0] = 1.0
	for i in 1 .. x.len {
		x[i] = f32(2.98023223876953125e-8) // 2^-25, exact in f32
	}
	mut naive := f32(0.0)
	for value in x {
		naive += value
	}
	assert naive == 1.0
	assert sum_compensated(x) == math.f32_from_bits(0x3F800000 + 250)
	hi, lo := sum_dd(x)
	assert hi > 1.0 && hi < 1.0001
	assert math.abs(lo) < 1e-12
}

fn test_f32_dot_dd_recovers_products_lost_by_naive_dot() {
	x := [f32(16777216.0), 1.0, -16777216.0]
	y := [f32(1.0), 1.0, 1.0]
	hi, lo := dot_dd(x, y)
	assert hi == 1.0
	assert lo == 0.0
	assert dot_compensated(x, y) == 1.0
}

fn test_f32_compensated_agree_with_dot_unitary_on_benign_data() {
	mut x := []f32{len: 257}
	mut y := []f32{len: 257}
	for i in 0 .. x.len {
		x[i] = f32(i % 13) - 6.0
		y[i] = f32(i % 7) * 0.25
	}
	assert dot_compensated(x, y) == dot_unitary(x, y)
	mut expected := 0.0
	for value in x {
		expected += f64(value)
	}
	assert sum_compensated(x) == f32(expected)
}

fn test_f32_sum_dd_empty_input() {
	hi, lo := sum_dd([]f32{})
	assert hi == 0.0
	assert lo == 0.0
	assert sum_compensated([]f32{}) == 0.0
}
