module vsl

import vsl.vmath
import vsl.errors

pub type ArbitraryFn = fn (x f64, params []f64) f64

pub type DfFn = fn (x f64, params []f64) f64

pub type FdfFn = fn (x f64, params []f64) (f64, f64)

pub type VectorValuedFn = fn (x f64, y []f64, params []f64) f64

// Definition of an arbitrary function with parameters
pub struct Fn {
pub mut:
	f      ArbitraryFn
	params []f64
}

[inline]
pub fn (f Fn) eval(x f64) f64 {
	return f.f(x, f.params)
}

fn is_finite(a f64) bool {
	return !vmath.is_nan(a) && !vmath.is_inf(a, 0)
}

// Call the pointed-to function with argument x, put its result in y, and
// return an error if the function value is inf/nan.
[inline]
pub fn (f Fn) safe_eval(x f64) ?f64 {
	y := f.f(x, f.params)
	if is_finite(y) {
		return y
	}
	return errors.vsl_error('function value is not finite', .ebadfunc)
}

// Definition of an arbitrary function returning two values, r1, r2
pub struct FnFdf {
pub mut:
	f      ArbitraryFn
	df     DfFn
	fdf    FdfFn
	params []f64
}

[inline]
pub fn (fdf FnFdf) eval_f(x f64) f64 {
	return fdf.f(x, fdf.params)
}

[inline]
pub fn (fdf FnFdf) eval_df(x f64) f64 {
	return fdf.df(x, fdf.params)
}

[inline]
pub fn (fdf FnFdf) eval_f_df(x f64) (f64, f64) {
	return fdf.fdf(x, fdf.params)
}

// Definition of an arbitrary vector-valued function with parameters
pub struct FnVec {
pub mut:
	f      VectorValuedFn
	params []f64
}

[inline]
pub fn (f FnVec) eval(x f64, y []f64) f64 {
	return f.f(x, y, f.params)
}
