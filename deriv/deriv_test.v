import vsl.deriv
import vsl.func
import vsl.vmath

fn f1(x f64, _ []f64) f64 {
	return vmath.exp(x)
}

fn df1(x f64, _ []f64) f64 {
	return vmath.exp(x)
}

fn f2(x f64, _ []f64) f64 {
	if x >= 0.0 {
		return x * vmath.sqrt(x)
	} else {
		return 0.0
	}
}

fn df2(x f64, _ []f64) f64 {
	if x >= 0.0 {
		return 1.50 * vmath.sqrt(x)
	} else {
		return 0.0
	}
}

fn f3(x f64, _ []f64) f64 {
	if x != 0.0 {
		return vmath.sin(1.0 / x)
	} else {
		return 0.0
	}
}

fn df3(x f64, _ []f64) f64 {
	if x != 0.0 {
		return -vmath.cos(1.0 / x) / (x * x)
	} else {
		return 0.0
	}
}

fn f4(x f64, _ []f64) f64 {
	return vmath.exp(-x * x)
}

fn df4(x f64, _ []f64) f64 {
	return -2.0 * x * vmath.exp(-x * x)
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

fn test_deriv() {
	f1_ := func.new_func(f: f1)
	df1_ := func.new_func(f: df1)
	f2_ := func.new_func(f: f2)
	df2_ := func.new_func(f: df2)
	f3_ := func.new_func(f: f3)
	df3_ := func.new_func(f: df3)
	f4_ := func.new_func(f: f4)
	df4_ := func.new_func(f: df4)
	f5_ := func.new_func(f: f5)
	df5_ := func.new_func(f: df5)
	f6_ := func.new_func(f: f6)
	df6_ := func.new_func(f: df6)

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
}

fn deriv_test(deriv_method string, f func.Fn, df func.Fn, x f64) bool {
	expected := df.eval(x)
	h := 1e-5
	result, _ := if deriv_method == 'backward' {
		deriv.backward(f, x, h)
	} else if deriv_method == 'forward' {
		deriv.forward(f, x, h)
	} else {
		deriv.central(f, x, h)
	}
	return compare(result, expected)
}

fn deriv_near_test(deriv_method string, f func.Fn, df func.Fn, x f64, tolerance f64) bool {
	expected := df.eval(x)
	h := 1e-5
	result, _ := if deriv_method == 'backward' {
		deriv.backward(f, x, h)
	} else if deriv_method == 'forward' {
		deriv.forward(f, x, h)
	} else {
		deriv.central(f, x, h)
	}
	return compare_near(result, expected, tolerance)
}

// Helper methods for comparing floats
[inline]
fn compare(x f64, y f64) bool {
	return compare_near(x, y, 1e-5)
}

fn compare_near(x f64, y f64, tolerance f64) bool {
	// Special case for zeroes
	if x < tolerance && x > (-1.0 * tolerance) && y < tolerance && y > (-1.0 * tolerance) {
		return true
	}
	deriv := vmath.abs(x - y)
	mean := vmath.abs(x + y) / 2.0
	return if vmath.is_nan(deriv / mean) { true } else { ((deriv / mean) < tolerance) }
}
