module diff

import math
import vsl.float.float64
import vsl.func

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

fn test_diff() {
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

	assert diff_test('central', f1_, df1_, 1.0)
	assert diff_test('forward', f1_, df1_, 1.0)
	assert diff_test('backward', f1_, df1_, 1.0)
	assert diff_test('central', f2_, df2_, 0.1)
	assert diff_test('forward', f2_, df2_, 0.1)
	assert diff_test('backward', f2_, df2_, 0.1)
	assert diff_test('central', f3_, df3_, 0.45)
	assert diff_test('forward', f3_, df3_, 0.45)
	assert diff_test('backward', f3_, df3_, 0.45)
	assert diff_test('central', f4_, df4_, 0.5)
	assert diff_test('forward', f4_, df4_, 0.5)
	assert diff_test('backward', f4_, df4_, 0.5)
	assert diff_test('central', f5_, df5_, 0.0)
	assert diff_test('forward', f5_, df5_, 0.0)
	assert diff_test('backward', f5_, df5_, 0.0)
	assert diff_test('central', f6_, df6_, 10.0)
	assert diff_test('forward', f6_, df6_, 10.0)
	assert diff_test('backward', f6_, df6_, 10.0)
}

fn diff_test(diff_method string, f func.Fn, df func.Fn, x f64) bool {
	return diff_near_test(diff_method, f, df, x, 1e-5)
}

fn diff_near_test(diff_method string, f func.Fn, df func.Fn, x f64, tolerance f64) bool {
	expected := df.eval(x)
	result, _ := if diff_method == 'backward' {
		backward(f, x)
	} else if diff_method == 'forward' {
		forward(f, x)
	} else {
		central(f, x)
	}
	return float64.tolerance(result, expected, tolerance)
}
