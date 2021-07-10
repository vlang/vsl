module fun

import vsl.vmath as math
import vsl.errors

// InterpQuad computes a quadratic polynomial to perform interpolation either using 3 points
// or 2 points and a known derivative
pub struct InterpQuad {
pub mut:
	// coefficients of polynomial a, b, c
	a f64
	b f64
	c f64
	// tolerance to avoid zero denominator
	tol_den f64
}

// new_interp_quad returns a new InterpQuad instance
pub fn new_interp_quad() &InterpQuad {
	return &InterpQuad{
		tol_den: 1e-15
	}
}

// f computes y = f(x) curve
pub fn (o InterpQuad) f(x f64) f64 {
	return o.a * x * x + o.b * x + o.c
}

// g computes y' = df/x|(x) curve
pub fn (o InterpQuad) g(x f64) f64 {
	return 2.0 * o.a * x + o.b
}

// optimum returns the minimum or maximum point; i.e. the point with zero derivative
//   xopt -- x @ optimum
//   fopt -- f(xopt) = y @ optimum
pub fn (o InterpQuad) optimum() (f64, f64) {
	if math.abs(o.a) < o.tol_den {
		errors.vsl_panic('cannot compute optimum because zero A=$o.a', .ezerodiv)
	}
	xopt := -0.5 * o.b / o.a
	fopt := o.f(xopt)
	return xopt, fopt
}

// fit_3points fits polynomial to 3 points
//   (x0, y0) -- first point
//   (x1, y1) -- second point
//   (x2, y2) -- third point
pub fn (mut o InterpQuad) fit_3points(x0 f64, y0 f64, x1 f64, y1 f64, x2 f64, y2 f64) ? {
	z0, z1, z2 := x0 * x0, x1 * x1, x2 * x2
	den := x0 * (z2 - z1) - x1 * z2 + x2 * z1 + (x1 - x2) * z0
	if math.abs(den) < o.tol_den {
		return errors.error('Cannot fit 3 points because denominator=$den is near zero.\n\t(x0,y0)=($x0,$y0)\t(x1,y1)=($x1,$y1)\t(x2,y2)=($x2,$y2)',
			.ezerodiv)
	}
	o.a = ((x1 - x2) * y0 + x2 * y1 - x1 * y2 + x0 * (y2 - y1)) / den
	o.b = ((y1 - y2) * z0 + y2 * z1 - y1 * z2 + y0 * (z2 - z1)) / den
	o.c = -((x2 * y1 - x1 * y2) * z0 + y0 * (x1 * z2 - x2 * z1) + x0 * (y2 * z1 - y1 * z2)) / den
}

// fit_2points_d fits polynomial to 2 points and known derivative
//   (x0, y0) -- first point
//   (x1, y1) -- second point
//   (x2, d2) -- derivate @ x2
pub fn (mut o InterpQuad) fit_2points_d(x0 f64, y0 f64, x1 f64, y1 f64, x2 f64, d2 f64) ? {
	z0, z1 := x0 * x0, x1 * x1
	den := -z1 + z0 + 2 * x1 * x2 - 2 * x0 * x2
	if math.abs(den) < o.tol_den {
		return errors.error('Cannot fit 2 points because denominator=$den is near zero.\n\t(x0,y0)=($x0,$y0)\t(x1,y1)=($x1,$y1)\t(x2,d2)=($x2,$d2)',
			.ezerodiv)
	}
	o.a = (-d2 * x0 + d2 * x1 + y0 - y1) / den
	o.b = (-2 * x2 * y0 + 2 * x2 * y1 + d2 * z0 - d2 * z1) / den
	o.c = ((y1 - d2 * x1) * z0 + y0 * (2 * x1 * x2 - z1) + x0 * (d2 * z1 - 2 * x2 * y1)) / den
}
