module fun

import vsl.vmath as math

// Sinusoid implements the sinusoid equation:
//
//   y(t) = a0 + c1⋅cos(omega_0⋅t + theta)             [essential-form]
//
//   y(t) = a0 + a1⋅cos(omega_0⋅t) + b1⋅sin(omega_0⋅t)  [basis-form]
//
//   a1 =  c1⋅cos(theta)
//   b1 = -c1⋅sin(theta)
//   theta  = arctan(-b1 / a1)   if a1<0, theta += π
//   c1 = sqrt(a1² + b1²)
pub struct Sinusoid {
pub mut:
	// input
	period      f64 // t: period; e.g. [s]
	mean_value  f64 // a0: mean value; e.g. [m]
	amplitude   f64 // c1: amplitude; e.g. [m]
	phase_shift f64 // theta: phase shift; e.g. [rad]
	// derived
	frequency    f64 // f: frequency; e.g. [Hz] or [1 cycle/s]
	angular_freq f64 // omega_0 = 2⋅π⋅f: angular frequency; e.g. [rad⋅s⁻¹]
	time_shift   f64 // ts = theta / omega_0: time shift; e.g. [s]
	// derived: coefficients
	a []f64 // a0, a1, A2, ... (if series mode)
	b []f64 // B0, b1, B2, ... (if series mode)
}

// new_sinusoid_essential creates a new sinusoid object with the "essential" parameters set
//   t  -- period; e.g. [s]
//   a0 -- mean value; e.g. [m]
//   c1 -- amplitude; e.g. [m]
//   theta  -- phase shift; e.g. [rad]
pub fn new_sinusoid_essential(t f64, a0 f64, c1 f64, theta f64) &Sinusoid {
	// input
	mut o := &Sinusoid{}
	o.period = t
	o.mean_value = a0
	o.amplitude = c1
	o.phase_shift = theta

	// derived
	o.frequency = 1.0 / t
	o.angular_freq = 2.0 * math.pi * o.frequency
	o.time_shift = theta / o.angular_freq

	// derived: coefficients
	a1 := c1 * math.cos(theta)
	b1 := -c1 * math.sin(theta)
	o.a = [a0, a1]
	o.b = [0.0, b1]
	return o
}

// new_sinusoid_basis creates a new sinusoid object with the "basis" parameters set
//   t  -- period; e.g. [s]
//   a0 -- mean value; e.g. [m]
//   a1 -- coefficient of the cos term
//   b1 -- coefficient of the sin term
pub fn new_sinusoid_basis(t f64, a0 f64, a1 f64, b1 f64) &Sinusoid {
	// coefficients
	c1 := math.sqrt(a1 * a1 + b1 * b1)
	theta := math.atan2(-b1, a1)

	// input
	mut o := &Sinusoid{}
	o.period = t
	o.mean_value = a0
	o.amplitude = c1
	o.phase_shift = theta

	// derived
	o.frequency = 1.0 / t
	o.angular_freq = 2.0 * math.pi * o.frequency
	o.time_shift = theta / o.angular_freq

	// derived: coefficients
	o.a = [a0, a1]
	o.b = [0.0, b1]
	return o
}

// yessen computes y(t) = a0 + c1⋅cos(omega_0⋅t + theta [essential-form]
pub fn (o Sinusoid) yessen(t f64) f64 {
	omega_0 := o.angular_freq
	return o.mean_value + o.amplitude * math.cos(omega_0 * t + o.phase_shift)
}

// ybasis computes y(t) = a0 + a1⋅cos(omega_0⋅t) + b1⋅sin(omega_0⋅t) [basis-form]
pub fn (o Sinusoid) ybasis(t f64) f64 {
	omega_0 := o.angular_freq
	mut res := o.a[0]
	for i in 1 .. o.a.len {
		k := f64(i)
		res += o.a[i] * math.cos(k * omega_0 * t) + o.b[i] * math.sin(k * omega_0 * t)
	}
	return res
}

// approx_square_fourier approximates sinusoid using Fourier series with n terms
pub fn (mut o Sinusoid) approx_square_fourier(n int) {
	o.a = []f64{len: 1 + n} // all even a's are 0 (except a0)
	o.b = []f64{len: 1 + n} // all b's are 0
	o.a[0] = o.mean_value
	for k := 1; k <= n; k += 4 {
		o.a[k] = 4.0 / (f64(k) * math.pi)
	}
	for k := 3; k <= n; k += 4 {
		o.a[k] = -4.0 / (f64(k) * math.pi)
	}
}

// test_periodicity tests that f(t) = f(t + t)
pub fn (o Sinusoid) test_periodicity(tmin f64, tmax f64, npts int) bool {
	dt := (tmax - tmin) / f64(npts - 1)
	for i := 0; i < npts; i++ {
		t := tmin + f64(i) * dt
		mut ya := o.yessen(t)
		mut yb := o.yessen(t + o.period)
		if math.abs(ya - yb) > 1e-14 {
			return false
		}
		ya = o.ybasis(t)
		yb = o.ybasis(t + o.period)
		if math.abs(ya - yb) > 1e-14 {
			return false
		}
	}
	return true
}
