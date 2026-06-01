module func

import math
import vsl.errors

// ArbitraryFn defines a public type used by this module.
pub type ArbitraryFn = fn (x f64, params []f64) f64

// DfFn defines a public type used by this module.
pub type DfFn = fn (x f64, params []f64) f64

// FdfFn defines a public type used by this module.
pub type FdfFn = fn (x f64, params []f64) (f64, f64)

// VectorValuedFn defines a public type used by this module.
pub type VectorValuedFn = fn (x f64, y []f64, params []f64) f64

// Definition of an arbitrary function with parameters
pub struct Fn {
pub:
	f ArbitraryFn @[required]
mut:
	params []f64
}

// Fn.new returns an arbitrary function with parameters

// Fn.new exposes this operation as part of the public API.

// Fn.new exposes this operation as part of the public API.
@[inline]
pub fn Fn.new(f Fn) Fn {
	return f
}

// eval exposes this operation as part of the public API.

// eval exposes this operation as part of the public API.
@[inline]
pub fn (f Fn) eval(x f64) f64 {
	return f.f(x, f.params)
}

fn is_finite(a f64) bool {
	return !math.is_nan(a) && !math.is_inf(a, 0)
}

// Call the pointed-to function with argument x, put its result in y, and
// return an error if the function value is inf/nan.

// safe_eval exposes this operation as part of the public API.

// safe_eval exposes this operation as part of the public API.
@[inline]
pub fn (f Fn) safe_eval(x f64) !f64 {
	y := f.f(x, f.params)
	if is_finite(y) {
		return y
	}
	return errors.error('function value is not finite', .ebadfunc)
}

// Definition of an arbitrary function returning two values, r1, r2
pub struct FnFdf {
pub:
	f   ?ArbitraryFn
	df  ?DfFn
	fdf ?FdfFn
mut:
	params []f64
}

// FnFdf.new returns an arbitrary function returning two values, r1, r2

// FnFdf.new exposes this operation as part of the public API.

// FnFdf.new exposes this operation as part of the public API.
@[inline]
pub fn FnFdf.new(fn_fdf FnFdf) FnFdf {
	return fn_fdf
}

// eval_f exposes this operation as part of the public API.

// eval_f exposes this operation as part of the public API.
@[inline]
pub fn (fdf FnFdf) eval_f(x f64) ?f64 {
	f := fdf.f or { return none }
	return f(x, fdf.params)
}

// eval_df exposes this operation as part of the public API.

// eval_df exposes this operation as part of the public API.
@[inline]
pub fn (fdf FnFdf) eval_df(x f64) ?f64 {
	df := fdf.df or { return none }
	return df(x, fdf.params)
}

// eval_f_df exposes this operation as part of the public API.

// eval_f_df exposes this operation as part of the public API.
@[inline]
pub fn (fdf FnFdf) eval_f_df(x f64) ?(f64, f64) {
	fdf_ := fdf.fdf or { return none }
	return fdf_(x, fdf.params)
}

// Definition of an arbitrary vector-valued function with parameters
pub struct FnVec {
	f VectorValuedFn @[required]
mut:
	params []f64
}

// FnVec.new returns an arbitrary vector-valued function with parameters

// FnVec.new exposes this operation as part of the public API.

// FnVec.new exposes this operation as part of the public API.
@[inline]
pub fn FnVec.new(f FnVec) FnVec {
	return f
}

// eval exposes this operation as part of the public API.

// eval exposes this operation as part of the public API.
@[inline]
pub fn (f FnVec) eval(x f64, y []f64) f64 {
	return f.f(x, y, f.params)
}
