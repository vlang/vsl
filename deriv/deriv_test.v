module deriv

import vsl.func
import vsl.float.float64
import math

fn f1(x f64, _ []f64) f64 {
	return math.exp(x)
}

fn df1(x f64, _ []f64) f64 {
	return math.exp(x)
}

fn f2(x f64, _ []f64) f64 {
	if x >= 0.0 {
		return x * math.sqrt(x)
	} else {
		return 0.0
	}
}

fn df2(x f64, _ []f64) f64 {
	if x >= 0.0 {
		return 1.50 * math.sqrt(x)
	} else {
		return 0.0
	}
}

fn f3(x f64, _ []f64) f64 {
	if x != 0.0 {
		return math.sin(1.0 / x)
	} else {
		return 0.0
	}
}

fn df3(x f64, _ []f64) f64 {
	if x != 0.0 {
		return -math.cos(1.0 / x) / (x * x)
	} else {
		return 0.0
	}
}

fn f4(x f64, _ []f64) f64 {
	return math.exp(-x * x)
}

fn df4(x f64, _ []f64) f64 {
	return -2.0 * x * math.exp(-x * x)
}

fn f5(x f64, _ []f64) f64 {
	return x * x
}

fn df5(x f64, _ []f64) f64 {
	return 2.0 * x
}

fn f6(x f64, _ []f64) f64 {
	return 1.0 / x
}

fn df6(x f64, _ []f64) f64 {
	return -1.0 / (x * x)
}

fn f_multi(x []f64) f64 {
	return x[0] * x[0] + x[1] * x[1] // f(x,y) = x^2 + y^2
}

fn df_multi_dx(x []f64) f64 {
	return 2 * x[0] // ∂f/∂x = 2x
}

fn df_multi_dy(x []f64) f64 {
	return 2 * x[1] // ∂f/∂y = 2y
}

fn test_deriv() {
	f1_ := func.Fn.new(f: f1)
	df1_ := func.Fn.new(f: df1)
	f2_ := func.Fn.new(f: f2)
	df2_ := func.Fn.new(f: df2)
	f3_ := func.Fn.new(f: f3)
	df3_ := func.Fn.new(f: df3)
	f4_ := func.Fn.new(f: f4)
	df4_ := func.Fn.new(f: df4)
	f5_ := func.Fn.new(f: f5)
	df5_ := func.Fn.new(f: df5)
	f6_ := func.Fn.new(f: f6)
	df6_ := func.Fn.new(f: df6)

	assert deriv_test('central', f1_, df1_, 1.0)
	assert deriv_test('forward', f1_, df1_, 1.0)
	assert deriv_test('backward', f1_, df1_, 1.0)
	assert deriv_test('central', f2_, df2_, 0.1)
	assert deriv_test('forward', f2_, df2_, 0.1)
	assert deriv_test('backward', f2_, df2_, 0.1)
	assert deriv_test('central', f3_, df3_, 0.45)
	assert deriv_test('forward', f3_, df3_, 0.45)
	assert deriv_test('backward', f3_, df3_, 0.45)
	assert deriv_test('central', f4_, df4_, 0.5)
	assert deriv_test('forward', f4_, df4_, 0.5)
	assert deriv_test('backward', f4_, df4_, 0.5)
	assert deriv_test('central', f5_, df5_, 0.0)
	assert deriv_test('forward', f5_, df5_, 0.0)
	assert deriv_test('backward', f5_, df5_, 0.0)
	assert deriv_test('central', f6_, df6_, 10.0)
	assert deriv_test('forward', f6_, df6_, 10.0)
	assert deriv_test('backward', f6_, df6_, 10.0)

	// Partial derivative test
	x := [2.0, 3.0]
	h := 1e-5

	// Partial derivative with respect to x
	dx, _ := partial(f_multi, x, 0, h)
	assert float64.tolerance(dx, df_multi_dx(x), 1e-5)

	// Partial derivative with respect to y
	dy, _ := partial(f_multi, x, 1, h)
	assert float64.tolerance(dy, df_multi_dy(x), 1e-5)
}

fn deriv_test(deriv_method string, f func.Fn, df func.Fn, x f64) bool {
	return deriv_near_test(deriv_method, f, df, x, 1e-5)
}

fn deriv_near_test(deriv_method string, f func.Fn, df func.Fn, x f64, tolerance f64) bool {
	expected := df.eval(x)
	h := 1e-5
	result, _ := if deriv_method == 'backward' {
		backward(f, x, h)
	} else if deriv_method == 'forward' {
		forward(f, x, h)
	} else {
		central(f, x, h)
	}
	return float64.tolerance(result, expected, tolerance)
}
