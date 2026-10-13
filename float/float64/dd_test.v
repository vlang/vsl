module float64

import math

fn test_two_sum_is_exact_on_cancelling_pair() {
	s, e := two_sum(1e16, 1.0)
	assert s == 1e16
	assert e == 1.0
	// plain f64 loses the 1 entirely
	assert 1e16 + 1.0 == 1e16
}

fn test_two_prod_is_exact_on_inexact_product() {
	a, b := 1.0000000001, 0.9999999999
	p, e := two_prod(a, b)
	// reconstruct in extended precision through the dd pair
	hi, lo := dd_add(p, e, 0.0, 0.0)
	assert hi == p
	assert math.abs(lo) < math.abs(p) * 1e-15
	assert e != 0.0 // the product is not representable in a single f64
}

fn test_sum_dd_recovers_terms_lost_by_naive_sum() {
	x := [1e16, 1.0, -1e16]
	mut naive := 0.0
	for value in x {
		naive += value
	}
	assert naive == 0.0 // the 1 is cancelled away in plain f64

	hi, lo := sum_dd(x)
	assert hi == 1.0
	assert lo == 0.0
	assert sum_compensated(x) == 1.0
}

fn test_sum_dd_matches_f64_reference_on_ordinary_values() {
	mut x := []f64{len: 1000}
	for i in 0 .. x.len {
		x[i] = math.sin(f64(i)) * 100.0
	}
	hi, lo := sum_dd(x)
	mut reference := 0.0
	for value in x {
		reference += value
	}
	// compensated result must be at least as close to hi+lo as the naive sum;
	// here both agree to well under a nanounit on benign data
	assert math.abs((hi + lo) - reference) < 1e-9
	assert math.abs(lo) < 1e-6
}

fn test_dot_dd_recovers_products_lost_by_naive_dot() {
	x := [1e16, 1.0, -1e16]
	y := [1.0, 1.0, 1.0]
	hi, lo := dot_dd(x, y)
	assert hi == 1.0
	assert lo == 0.0
	assert dot_compensated(x, y) == 1.0
}

fn test_dot_dd_agrees_with_dot_unitary_on_benign_data() {
	mut x := []f64{len: 257}
	mut y := []f64{len: 257}
	for i in 0 .. x.len {
		x[i] = f64(i % 13) - 6.0
		y[i] = f64(i % 7) * 0.25
	}
	assert math.abs(dot_compensated(x, y) - dot_unitary(x, y)) < 1e-9
}
