module float64

// Error-free transformations and double-double accumulators.
//
// Plain f64 accumulation discards low-order bits at every step. The routines
// in this file keep the discarded part in a second f64 (a "double-double"
// value hi+lo with roughly 106 bits of precision), so sums and dot products
// stay accurate on inputs where naive left-to-right evaluation cancels
// catastrophically. They are the building blocks for correctly rounded
// elementary functions (see vlang/vsl#65).

// two_sum returns (s, e) with s = fl(a + b) and s + e == a + b exactly,
// for any a and b (Knuth's TwoSum, no ordering requirement).
pub fn two_sum(a f64, b f64) (f64, f64) {
	s := a + b
	bb := s - a
	e := (a - (s - bb)) + (b - bb)
	return s, e
}

// quick_two_sum returns (s, e) with s + e == a + b exactly; requires |a| >= |b|.
pub fn quick_two_sum(a f64, b f64) (f64, f64) {
	s := a + b
	e := b - (s - a)
	return s, e
}

// two_prod returns (p, e) with p = fl(a * b) and p + e == a * b exactly,
// using Dekker's splitting (no FMA required).
pub fn two_prod(a f64, b f64) (f64, f64) {
	p := a * b
	splitter := 134217729.0 // 2^27 + 1
	a_big := splitter * a
	a_hi := a_big - (a_big - a)
	a_lo := a - a_hi
	b_big := splitter * b
	b_hi := b_big - (b_big - b)
	b_lo := b - b_hi
	e := ((a_hi * b_hi - p) + a_hi * b_lo + a_lo * b_hi) + a_lo * b_lo
	return p, e
}

// dd_add returns the double-double sum (hi, lo) of two double-double values.
fn dd_add(a_hi f64, a_lo f64, b_hi f64, b_lo f64) (f64, f64) {
	mut s, e := two_sum(a_hi, b_hi)
	e += a_lo + b_lo
	return quick_two_sum(s, e)
}

// sum_dd returns the double-double sum (hi, lo) of x: the exact sum of the
// inputs rounded to a hi part, with lo holding the residual. hi + lo
// approximates the true sum with roughly 106 bits of precision.
pub fn sum_dd(x []f64) (f64, f64) {
	mut hi := 0.0
	mut lo := 0.0
	for value in x {
		hi, lo = dd_add(hi, lo, value, 0.0)
	}
	return hi, lo
}

// sum_compensated returns sum_dd rounded to a single f64 (hi + lo).
pub fn sum_compensated(x []f64) f64 {
	hi, lo := sum_dd(x)
	return hi + lo
}

// dot_dd returns the double-double dot product (hi, lo) of x and y, with
// each product split exactly by two_prod before accumulation.
@[direct_array_access]
pub fn dot_dd(x []f64, y []f64) (f64, f64) {
	if y.len < x.len {
		panic('dot_dd: second vector is shorter than first')
	}
	mut hi := 0.0
	mut lo := 0.0
	for i in 0 .. x.len {
		p, e := two_prod(x[i], y[i])
		hi, lo = dd_add(hi, lo, p, e)
	}
	return hi, lo
}

// dot_compensated returns dot_dd rounded to a single f64 (hi + lo).
pub fn dot_compensated(x []f64, y []f64) f64 {
	hi, lo := dot_dd(x, y)
	return hi + lo
}
