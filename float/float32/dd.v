module float32

import vsl.float.float64 as f64m

// Compensated (double-double) sums and dot products for f32 inputs,
// the f32 counterpart of the float64 dd API. Every f32 is exact in
// f64 and every product of two f32 values is exact in f64 (24 + 24
// mantissa bits fit in 53), so accumulating the f64 values with
// error-free transformations keeps roughly 106 bits of precision:
// the results stay accurate on inputs where naive f32 evaluation
// cancels catastrophically, and the compensated variants are
// correctly rounded in practice (see vlang/vsl#65).

// dd_add_f64 returns the double-double sum of two double-double
// values held in f64 pairs.
fn dd_add_f64(a_hi f64, a_lo f64, b_hi f64, b_lo f64) (f64, f64) {
	mut s, e := f64m.two_sum(a_hi, b_hi)
	e += a_lo + b_lo
	return f64m.quick_two_sum(s, e)
}

// sum_dd returns the double-double sum (hi, lo) of x: hi + lo
// approximates the true sum with roughly 106 bits of precision.
pub fn sum_dd(x []f32) (f64, f64) {
	mut hi := 0.0
	mut lo := 0.0
	for value in x {
		hi, lo = dd_add_f64(hi, lo, f64(value), 0.0)
	}
	return hi, lo
}

// sum_compensated returns the sum of x rounded once to f32 from the
// double-double sum: correctly rounded in practice.
pub fn sum_compensated(x []f32) f32 {
	hi, lo := sum_dd(x)
	return round_dd_to_f32(hi, lo)
}

// dot_dd returns the double-double dot product (hi, lo) of x and y.
// Each product is exact in f64, so no product splitting is needed
// before the compensated accumulation.
@[direct_array_access]
pub fn dot_dd(x []f32, y []f32) (f64, f64) {
	if y.len < x.len {
		panic('dot_dd: second vector is shorter than first')
	}
	mut hi := 0.0
	mut lo := 0.0
	for i in 0 .. x.len {
		hi, lo = dd_add_f64(hi, lo, f64(x[i]) * f64(y[i]), 0.0)
	}
	return hi, lo
}

// dot_compensated returns the dot product of x and y rounded once to
// f32 from the double-double result: correctly rounded in practice.
pub fn dot_compensated(x []f32, y []f32) f32 {
	hi, lo := dot_dd(x, y)
	return round_dd_to_f32(hi, lo)
}
