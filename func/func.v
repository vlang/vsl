module func

import math
import vsl.errors

pub type ArbitraryFn = fn (x f64, params []f64) f64

pub type DfFn = fn (x f64, params []f64) f64

pub type FdfFn = fn (x f64, params []f64) (f64, f64)

pub type VectorValuedFn = fn (x f64, y []f64, params []f64) f64

// Definition of an arbitrary function with parameters
pub struct Fn {
	f ArbitraryFn [required]
mut:
	params []f64
}

// new_func returns an arbitrary function with parameters
[inline]
pub fn new_func(f Fn) Fn {
	return f
}

[inline]
pub fn (f Fn) eval(x f64) f64 {
	return f.f(x, f.params)
}

fn is_finite(a f64) bool {
	return !math.is_nan(a) && !math.is_inf(a, 0)
}

// Call the pointed-to function with argument x, put its result in y, and
// return an error if the function value is inf/nan.
[inline]
pub fn (f Fn) safe_eval(x f64) !f64 {
	y := f.f(x, f.params)
	if is_finite(y) {
		return y
	}
	return errors.error('function value is not finite', .ebadfunc)
}

// Definition of an arbitrary function returning two values, r1, r2
pub struct FnFdf {
	f   ?ArbitraryFn
	df  ?DfFn
	fdf ?FdfFn
mut:
	params []f64
}

// new_func_fdf returns an arbitrary function returning two values, r1, r2
[inline]
pub fn new_func_fdf(fn_fdf FnFdf) FnFdf {
	return fn_fdf
}

[inline]
pub fn (fdf FnFdf) eval_f(x f64) ?f64 {
	f := fdf.f or { return none }
	return f(x, fdf.params)
}

[inline]
pub fn (fdf FnFdf) eval_df(x f64) ?f64 {
	df := fdf.df or { return none }
	return df(x, fdf.params)
}

[inline]
pub fn (fdf FnFdf) eval_f_df(x f64) ?(f64, f64) {
	fdf_ := fdf.fdf or { return none }
	return fdf_(x, fdf.params)
}

// Definition of an arbitrary vector-valued function with parameters
pub struct FnVec {
	f VectorValuedFn [required]
mut:
	params []f64
}

// new_func_vec returns an arbitrary vector-valued function with parameters
[inline]
pub fn new_func_vec(f FnVec) FnVec {
	return f
}

[inline]
pub fn (f FnVec) eval(x f64, y []f64) f64 {
	return f.f(x, y, f.params)
}
