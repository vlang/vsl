
module vmath

// Floating-point mod function.
// mod returns the floating-point remainder of x/y.
// The magnitude of the result is less than y and its
// sign agrees with that of x.
//
// special cases are:
// mod(±inf, y) = nan
// mod(nan, y) = nan
// mod(x, 0) = nan
// mod(x, ±inf) = x
// mod(x, nan) = nan
pub fn mod(x f64, y f64) f64 {
	return fmod(x, y)
}

pub fn fmod(x f64, y f64) f64 {
	if y == 0 || is_inf(x, 0) || is_nan(x) || is_nan(y) {
		return nan()
	}
	abs_y := abs(y)
	abs_y_fr, abs_y_exp := frexp(abs_y)
	mut r := x
	if x < 0 {
		r = -x
	}
	for r >= abs_y {
		rfr, mut rexp := frexp(r)
		if rfr < abs_y_fr {
			rexp = rexp - 1
		}
		r = r - ldexp(abs_y, rexp - abs_y_exp)
	}
	if x < 0 {
		r = -r
	}
	return r
}

// gcd calculates greatest common (positive) divisor (or zero if a and b are both zero).
pub fn gcd(a_ i64, b_ i64) i64 {
	mut a := a_
	mut b := b_
	if a < 0 {
		a = -a
	}
	if b < 0 {
		b = -b
	}
	for b != 0 {
		a %= b
		if a == 0 {
			return b
		}
		b %= a
	}
	return a
}

// lcm calculates least common (non-negative) multiple.
pub fn lcm(a i64, b i64) i64 {
	if a == 0 {
		return a
	}
	res := a * (b / gcd(b, a))
	if res < 0 {
		return -res
	}
	return res
}
