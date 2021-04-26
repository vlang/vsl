module vimpl

// sinh calculates hyperbolic sine.
pub fn sinh(x_ f64) f64 {
	mut x := x_
	// The coefficients are #2029 from Hart & Cheney. (20.36D)
	p0_ := -0.6307673640497716991184787251e+6
	p1_ := -0.8991272022039509355398013511e+5
	p2_ := -0.2894211355989563807284660366e+4
	p3_ := -0.2630563213397497062819489e+2
	q0_ := -0.6307673640497716991212077277e+6
	q1_ := 0.1521517378790019070696485176e+5
	q2_ := -0.173678953558233699533450911e+3
	mut sign := false
	if x < 0 {
		x = -x
		sign = true
	}
	mut temp := 0.0
	if x > 21 {
		temp = exp(x) * 0.5
	} else if x > 0.5 {
		ex := exp(x)
		temp = (ex - 1.0 / ex) * 0.5
	} else {
		sq := x * x
		temp = (((p3_ * sq + p2_) * sq + p1_) * sq + p0_) * x
		temp = temp / (((sq + q2_) * sq + q1_) * sq + q0_)
	}
	if sign {
		temp = -temp
	}
	return temp
}

// cosh returns the hyperbolic cosine of x.
//
// special cases are:
// cosh(±0) = 1
// cosh(±inf) = +inf
// cosh(nan) = nan
pub fn cosh(x f64) f64 {
	abs_x := abs(x)
	if abs_x > 21 {
		return exp(abs_x) * 0.5
	}
	ex := exp(abs_x)
	return (ex + 1.0 / ex) * 0.5
}
