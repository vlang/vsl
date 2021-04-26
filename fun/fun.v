module fun

import vsl.vmath as math
import vsl.vmath.complex as cmplx
import vsl.errors

// beta computes the beta function by calling the log_gamma_sign function
pub fn beta(a f64, b f64) f64 {
	la, sgnla := math.log_gamma_sign(a)
	lb, sgnlb := math.log_gamma_sign(b)
	lc, sgnlc := math.log_gamma_sign(a + b)
	return f64(sgnla * sgnlb * sgnlc) * math.exp(la + lb - lc)
}

// binomial comptues the binomial coefficient (n k)^t
pub fn binomial(n int, k_ int) f64 {
	mut k := k_
	if n < 0 || k < 0 || k > n {
		errors.vsl_panic('binomial function requires that k <= n (both positive). incorrect values: n=$n, k=$k',
			.erange)
	}
	if k == 0 || k == n {
		return 1
	}
	if k == 1 || k == n - 1 {
		return f64(n)
	}
	// use fast table lookup. see [1] page 258
	if n <= 22 {
		// the floor function cleans up roundoff error for smaller values of n and k.
		return math.floor(0.5 +
			math.factorial(f64(n)) / (math.factorial(f64(k)) * math.factorial(f64(n - k))))
	}
	// use beta function
	if k > n - k {
		k = n - k // take advantage of symmetry
	}
	res := f64(k) * beta(f64(k), f64(n - k + 1))
	if res == 0 {
		errors.vsl_panic('binomial function failed with n=$n, k=$k', .efailed)
	}
	return math.floor(0.5 + 1.0 / res)
}

// uint_binomial implements the binomial coefficient using u64. panic happens on overflow
// also, this function uses a loop so it may not be very efficient for large k
// the code below comes from https://en.wikipedia.org/wiki/binomial_coefficient
// [cannot find a reference to cite]
pub fn uint_binomial(n_ u64, k_ u64) u64 {
	mut n := n_
	mut k := k_
	if k > n {
		errors.vsl_panic('uint_binomial function requires that k <= n. incorrect values: n=$n, k=$k',
			.erange)
	}
	if k == 0 || k == n {
		return 1
	}
	if k == 1 || k == n - 1 {
		return n
	}
	if k > n - k {
		k = n - k // take advantage of symmetry
	}
	mut c := u64(1)
	for i := u64(1); i <= k; i++ {
		c_i := c / i
		max_n := math.max_u64 / n
		if c_i > max_n / n {
			errors.vsl_panic('overflow in uint_binomial: $c_i > $max_n', .eovrflw)
		}
		c = c_i * n + c % i * n / i // split c*n/i into (c/i*i + c%i)*n/i
		n = n - 1
	}
	return c
}

// rbinomial computes the binomial coefficient with real (non-negative) arguments by calling the gamma function
pub fn rbinomial(x f64, y f64) f64 {
	if x < 0 || y < 0 {
		errors.vsl_panic('rbinomial requires x and y to be non-negative, at this moment',
			.erange)
	}
	ga := math.gamma(x + 1.0)
	gb := math.gamma(y + 1.0)
	gc := math.gamma(x - y + 1.0)
	return ga / (gb * gc)
}

// (n+r-1)! / r! / (n-1)! when n > 0.
pub fn n_combos_w_replacement(n f64, r f64) u64 {
	if n <= 0 {
		return 0
	}
	numerator := math.factorial(n + r - 1)
	denominator := math.factorial(r) * math.factorial(n - 1)
	return u64(numerator / denominator)
}

// suqcos implements the superquadric auxiliary function that uses cos(x)
pub fn suqcos(angle f64, expon f64) f64 {
	return sign(math.cos(angle)) * math.pow(math.abs(math.cos(angle)), expon)
}

// suqsin implements the superquadric auxiliary function that uses sin(x)
pub fn suqsin(angle f64, expon f64) f64 {
	return sign(math.sin(angle)) * math.pow(math.abs(math.sin(angle)), expon)
}

// atan2p implements a positive version of atan2, in such a way that: 0 ≤ α ≤ 2π
pub fn atan2p(y f64, x f64) f64 {
	mut alpha_rad := math.atan2(y, x)
	if alpha_rad < 0.0 {
		alpha_rad += 2.0 * math.pi
	}
	return alpha_rad
}

// atan2pdeg implements a positive version of atan2, in such a way that: 0 ≤ α ≤ 360
pub fn atan2pdeg(y f64, x f64) f64 {
	mut alpha_deg := math.atan2(y, x) * 180.0 / math.pi
	if alpha_deg < 0.0 {
		alpha_deg += 360.0
	}
	return alpha_deg
}

// ramp function => macaulay brackets
pub fn ramp(x f64) f64 {
	if x < 0.0 {
		return 0.0
	}
	return x
}

// heav computes the heaviside step function (== derivative of ramp(x))
//
//             │ 0    if x < 0
//   heav(x) = ┤ 1/2  if x = 0
//             │ 1    if x > 0
//
pub fn heav(x f64) f64 {
	if x < 0.0 {
		return 0.0
	}
	if x > 0.0 {
		return 1.0
	}
	return 0.5
}

// sign implements the sign function
pub fn sign(x f64) f64 {
	if x < 0.0 {
		return -1.0
	}
	if x > 0.0 {
		return 1.0
	}
	return 0.0
}

// boxcar implements the boxcar function
//
// `boxcar(x;a,b) = heav(x-a) - heav(x-b)`
//
// _**NOTE**: a ≤ x ≤ b; i.e. b ≥ a (not checked)_
pub fn boxcar(x f64, a f64, b f64) f64 {
	if x < a || x > b {
		return 0
	}
	if x > a && x < b {
		return 1
	}
	return 0.5
}

// rect implements the rectangular function
//
// `rect(x) = boxcar(x;-0.5,0.5)`
pub fn rect(x f64) f64 {
	if x < -0.5 || x > 0.5 {
		return 0
	}
	if x > -0.5 && x < 0.5 {
		return 1
	}
	return 0.5
}

// hat implements the hat function
pub fn hat(x f64, xc f64, y0 f64, h f64, l f64) f64 {
	if x <= xc - l || x >= xc + l {
		return y0
	}
	if x <= xc {
		return y0 + (h / l) * (x - xc + l)
	}
	return y0 + h - (h / l) * (x - xc)
}

// hatd1 returns the first derivative of the hat function
// _**NOTE**: the discontinuity is ignored ⇒ d1(xc-l)=d1(xc+l)=d1(xc)=0_
pub fn hatd1(x f64, xc f64, y0 f64, h f64, l f64) f64 {
	if x <= xc - l || x >= xc + l || x == xc {
		return 0
	}
	if x < xc {
		return h / l
	}
	return -h / l
}

// sramp implements a smooth ramp function. ramp
pub fn sramp(x f64, beta f64) f64 {
	if -beta * x > 500.0 {
		return 0.0
	}
	return x + math.log(1.0 + math.exp(-beta * x)) / beta
}

// srampd1 returns the first derivative of sramp
pub fn srampd1(x f64, beta f64) f64 {
	if -beta * x > 500.0 {
		return 0.0
	}
	return 1.0 / (1.0 + math.exp(-beta * x))
}

// srampd2 returns the second derivative of sramp
pub fn srampd2(x f64, beta f64) f64 {
	if beta * x > 500.0 {
		return 0.0
	}
	return beta * math.exp(beta * x) / math.pow(math.exp(beta * x) + 1.0, 2.0)
}

// logistic implements the sigmoid/logistic function
pub fn logistic(z f64) f64 {
	return 1.0 / (1.0 + math.exp(-z))
}

// logistic_d1 implements the first derivative of the sigmoid/logistic function
pub fn logistic_d1(z f64) f64 {
	g := logistic(z)
	return g * (1.0 - g)
}

// sabs implements a smooth abs f: sabs(x) = x*x / (sign(x)*x + eps)
pub fn sabs(x f64, eps f64) f64 {
	mut s := 0.0
	if x > 0.0 {
		s = 1.0
	} else if x < 0.0 {
		s = -1.0
	}
	return x * x / (s * x + eps)
}

// sabs_d1 returns the first derivative of sabs
pub fn sabs_d1(x f64, eps f64) f64 {
	mut s := 0.0
	if x > 0.0 {
		s = 1.0
	} else if x < 0.0 {
		s = -1.0
	}
	d := s * x + eps
	y := x * x / d
	return (2.0 * x - s * y) / d
}

// sabs_d2 returns the first derivative of sabs
pub fn sabs_d2(x f64, eps f64) f64 {
	mut s := 0.0
	if x > 0.0 {
		s = 1.0
	} else if x < 0.0 {
		s = -1.0
	}
	d := s * x + eps
	y := x * x / d
	dydt := (2.0 * x - s * y) / d
	return 2.0 * (1.0 - s * dydt) / d
}

// exp_pix uses euler's formula to compute exp(+i⋅x) = cos(x) + i⋅sin(x)
pub fn exp_pix(x f64) cmplx.Complex {
	return cmplx.complex(math.cos(x), math.sin(x))
}

// exp_mix uses euler's formula to compute exp(-i⋅x) = cos(x) - i⋅sin(x)
pub fn exp_mix(x f64) cmplx.Complex {
	return cmplx.complex(math.cos(x), -math.sin(x))
}

// sinc computes the sine cardinal (sinc) function
//
//   sinc(x) = |     1      if x = 0
//             | sin(x)/x   otherwise
//
pub fn sinc(x f64) f64 {
	if x == 0 {
		return 1
	}
	return math.sin(x) / x
}

// neg_one_pow_n computes (-1)ⁿ
pub fn neg_one_pow_n(n int) f64 {
	if (n & 1) == 0 { // even
		return 1
	}
	return -1
}

// imag_pow_n computes iⁿ = (√-1)ⁿ
pub fn imag_pow_n(n int) cmplx.Complex {
	if n == 0 {
		return cmplx.complex(1.0, 0.0)
	}
	match n % 4 {
		1 { return cmplx.complex(0.0, 1.0) }
		2 { return cmplx.complex(1.0, 0.0) }
		3 { return cmplx.complex(0.0, -1.0) }
		else { cmplx.complex(1.0, 0.0) }
	}
	return cmplx.complex(1.0, 0.0)
}

// imag_x_pow_n computes (x⋅i)ⁿ
pub fn imag_x_pow_n(x f64, n int) cmplx.Complex {
	if n == 0 {
		return cmplx.complex(1.0, 0.0)
	}
	xn := math.pow(x, f64(n))
	match n % 4 {
		1 { return cmplx.complex(0.0, xn) }
		2 { return cmplx.complex(-xn, 0.0) }
		3 { return cmplx.complex(0.0, -xn) }
		else { cmplx.complex(xn, 0.0) }
	}
	return cmplx.complex(xn, 0.0)
}

// powp computes real raised to positive integer xⁿ
pub fn powp(x_ f64, n u32) f64 {
	mut x := x_
	if n == 0 {
		return 1.0
	}
	if n == 1 {
		return x
	}
	if n == 2 {
		return x * x
	}
	if n == 3 {
		return x * x * x
	}
	if n == 4 {
		r := x * x
		return r * r
	}
	if n == 5 {
		r := x * x
		return r * r * x
	}
	if n == 6 {
		r := x * x * x
		return r * r
	}
	if n == 7 {
		r := x * x * x
		return r * r * x
	}
	if n == 8 {
		r := x * x * x * x
		return r * r
	}
	if n == 9 {
		r := x * x * x
		return r * r * r
	}
	if n == 10 {
		r := x * x * x
		return r * r * r * x
	}
	mut r := 1.0
	for i := n; i > 0; i >>= 1 {
		if i & 1 == 1 {
			r *= x
		}
		x *= x
	}
	return r
}

// pow2 computes x²
pub fn pow2(x f64) f64 {
	return x * x
}

// pow3 computes x³
pub fn pow3(x f64) f64 {
	return x * x * x
}

fn is_neg_int(x f64) bool {
	if x < 0 {
		_, xf := math.modf(x)
		return xf == 0
	}
	return false
}
