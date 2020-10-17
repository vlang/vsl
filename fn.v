// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module vsl

import vsl.vmath
import vsl.errno

// TODO: change params type from []f64 to []T
pub type ArbitraryFn = fn (x f64, params []f64) f64

pub type DfFn = fn (x f64, params []f64) f64

pub type FdfFn = fn (x f64, params []f64) (f64, f64)

pub type VectorValuedFn = fn (x f64, y []f64, params []f64) f64

// Definition of an arbitrary function with parameters
pub struct Function {
pub mut:
	function ArbitraryFn
	params   []f64
}

[inline]
pub fn (f Function) eval(x f64) f64 {
	function := f.function
	return function(x, f.params)
}

fn is_finite(a f64) bool {
	return !vmath.is_nan(a) && !vmath.is_inf(a, 0)
}

// Call the pointed-to function with argument x, put its result in y, and
// return an error if the function value is inf/nan.
[inline]
pub fn (f Function) safe_eval(x f64) ?f64 {
	function := f.function
	y := function(x, f.params)
	if is_finite(y) {
		return y
	}
	return error(errno.vsl_error_message('function value is not finite', .ebadfunc))
}

// Definition of an arbitrary function returning two values, r1, r2
pub struct FunctionFdf {
pub mut:
	f      ArbitraryFn
	df     DfFn
	fdf    FdfFn
	params []f64
}

[inline]
pub fn (fdf FunctionFdf) eval_f(x f64) f64 {
	function := fdf.f
	return function(x, fdf.params)
}

[inline]
pub fn (fdf FunctionFdf) eval_df(x f64) f64 {
	function := fdf.df
	return function(x, fdf.params)
}

[inline]
pub fn (fdf FunctionFdf) eval_f_df(x f64) (f64, f64) {
	function := fdf.fdf
	return function(x, fdf.params)
}

// Definition of an arbitrary vector-valued function with parameters
pub struct FunctionVec {
pub mut:
	function VectorValuedFn
	params   []f64
}

[inline]
pub fn (f FunctionVec) eval(x f64, y []f64) f64 {
	function := f.function
	return function(x, y, f.params)
}
