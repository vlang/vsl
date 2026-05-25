module func

import math

fn affine(x f64, params []f64) f64 {
	// y = a*x + b
	return params[0] * x + params[1]
}

fn reciprocal(x f64, _ []f64) f64 {
	if x == 0.0 {
		return math.inf(1)
	}
	return 1.0 / x
}

fn nan_fn(_ f64, _ []f64) f64 {
	return math.nan()
}

fn f_only(x f64, params []f64) f64 {
	return x + params[0]
}

fn df_only(x f64, params []f64) f64 {
	return params[0] * x * x
}

fn fdf_both(x f64, params []f64) (f64, f64) {
	// f(x) = a*x^2, f'(x) = 2*a*x
	a := params[0]
	return a * x * x, 2.0 * a * x
}

fn vec_weighted_sum(x f64, y []f64, params []f64) f64 {
	mut acc := params[0] * x
	for i, yi in y {
		acc += params[i + 1] * yi
	}
	return acc
}

fn test_fn_eval_with_parameters() {
	f := Fn.new(f: affine, params: [2.5, -1.0])
	assert math.abs(f.eval(4.0) - 9.0) < 1e-12
	assert math.abs(f.eval(-2.0) + 6.0) < 1e-12
}

fn test_fn_safe_eval_accepts_finite_value() {
	f := Fn.new(f: reciprocal)
	y := f.safe_eval(4.0)!
	assert math.abs(y - 0.25) < 1e-12
}

fn test_fn_safe_eval_rejects_inf_and_nan() {
	inf_fn := Fn.new(f: reciprocal)
	if y := inf_fn.safe_eval(0.0) {
		assert false, 'expected failure, got ${y}'
	} else {
		assert err.code() == 9
		assert err.msg().contains('function value is not finite')
	}

	nanf := Fn.new(f: nan_fn)
	if y := nanf.safe_eval(1.0) {
		assert false, 'expected failure, got ${y}'
	} else {
		assert err.code() == 9
		assert err.msg().contains('function value is not finite')
	}
}

fn test_fnfdf_optional_callbacks_behavior() {
	only_f := FnFdf.new(f: f_only, params: [3.0])
	assert only_f.eval_f(2.0) or { panic('expected f value') } == 5.0
	assert only_f.eval_df(2.0) == none
	if v1, v2 := only_f.eval_f_df(2.0) {
		assert false, 'expected none, got (${v1}, ${v2})'
	} else {
		assert true
	}

	only_df := FnFdf.new(df: df_only, params: [0.5])
	assert only_df.eval_f(3.0) == none
	assert math.abs((only_df.eval_df(3.0) or { panic('expected df value') }) - 4.5) < 1e-12
	if v1, v2 := only_df.eval_f_df(3.0) {
		assert false, 'expected none, got (${v1}, ${v2})'
	} else {
		assert true
	}
}

fn test_fnfdf_combined_f_and_df_consistency() {
	fdf := FnFdf.new(fdf: fdf_both, params: [2.0])
	fv, dfv := fdf.eval_f_df(1.5) or { panic('expected (f,df) pair') }
	assert math.abs(fv - 4.5) < 1e-12
	assert math.abs(dfv - 6.0) < 1e-12
}

fn test_fnvec_eval_weighted_projection() {
	fv := FnVec.new(f: vec_weighted_sum, params: [1.5, 2.0, -1.0, 0.5])
	y := [3.0, -2.0, 4.0]
	// 1.5*x + 2*y0 -1*y1 + 0.5*y2 with x=2
	result := fv.eval(2.0, y)
	assert math.abs(result - 13.0) < 1e-12
}
