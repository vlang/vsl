module fun

import math
import vsl.errors

// InterpCubic computes a cubic polynomial to perform interpolation either using 4 points
// or 3 points and a known derivative
pub struct InterpCubic {
pub mut:
	// coefficients of polynomial a, b, c, d
	a f64
	b f64
	c f64
	d f64
	// tolerance to avoid zero denominator
	tol_den f64
}

// new_interp_cubic returns a new InterpCubic instance
pub fn new_interp_cubic() &InterpCubic {
	return &InterpCubic{
		tol_den: 1e-15
	}
}

// f computes y = f(x) curve
pub fn (o InterpCubic) f(x f64) f64 {
	return o.a * x * x * x + o.b * x * x + o.c * x + o.d
}

// g computes y' = df/x|(x) curve
pub fn (o InterpCubic) g(x f64) f64 {
	return 3.0 * o.a * x * x + 2.0 * o.b * x + o.c
}

// critical returns the critical points
//   xmin -- x @ min and y(xmin)
//   xmax -- x @ max and y(xmax)
//   xifl -- x @ inflection point and y(ifl)
//   has_min, has_max, has_ifl -- flags telling what is available
pub fn (o InterpCubic) critical() (f64, f64, f64, bool, bool, bool) {
	del_by_4 := o.b * o.b - 3.0 * o.a * o.c
	if del_by_4 < 0 {
		return 0.0, 0.0, 0.0, false, false, false // cubic function is strictly monotonic
	}
	den := 3.0 * o.a
	mut xmin := 0.0
	mut xmax := 0.0
	mut has_min := false
	mut has_max := false
	xifl := -o.b / den
	has_ifl := true
	if del_by_4 != 0.0 {
		xmin = (-o.b + math.sqrt(del_by_4)) / den
		xmax = (-o.b - math.sqrt(del_by_4)) / den
		if o.f(xmin) > o.f(xmax) {
			xmin, xmax = xmax, xmin
		}
		has_min = true
		has_max = true
	}
	return xmin, xmax, xifl, has_min, has_max, has_ifl
}

// fit_4points fits polynomial to 3 points
//   (x0, y0) -- first point
//   (x1, y1) -- second point
//   (x2, y2) -- third point
//   (x3, y3) -- fourth point
pub fn (mut o InterpCubic) fit_4points(x0 f64, y0 f64, x1 f64, y1 f64, x2 f64, y2 f64, x3 f64, y3 f64) ? {
	z0, z1, z2, z3 := x0 * x0, x1 * x1, x2 * x2, x3 * x3
	w0, w1, w2, w3 := z0 * x0, z1 * x1, z2 * x2, z3 * x3
	den := w0 * ((x2 - x3) * z1 + x3 * z2 - x2 * z3 + x1 * (z3 - z2)) + w1 * (x2 * z3 - x3 * z2) +
		x0 * ((w3 - w2) * z1 - w3 * z2 + w1 * (z2 - z3) + w2 * z3) + x1 * (w3 * z2 - w2 * z3) +
		(w2 * x3 - w3 * x2) * z1 + ((w2 - w3) * x1 + w3 * x2 - w2 * x3 + w1 * (x3 - x2)) * z0
	if math.abs(den) < o.tol_den {
		return errors.error('Cannot fit 4 points because denominator=$den is near zero.\n\t(x0,y0)=($x0,$y0)\t(x1,y1)=($x1,$y1)\t(x2,y2)=($x2,$y2)\t(x3,d3)=($x3,$y3)',
			.ezerodiv)
	}
	o.a = -((x1 * (y3 - y2) - x2 * y3 + x3 * y2 + (x2 - x3) * y1) * z0 + (x2 * y3 - x3 * y2) * z1 +
		y1 * (x3 * z2 - x2 * z3) + y0 * (x2 * z3 + x1 * (z2 - z3) - x3 * z2 + (x3 - x2) * z1) +
		x1 * (y2 * z3 - y3 * z2) + x0 * (y1 * (z3 - z2) - y2 * z3 + y3 * z2 + (y2 - y3) * z1)) / den
	o.b = ((w1 * (x3 - x2) - w2 * x3 + w3 * x2 + (w2 - w3) * x1) * y0 + (w2 * x3 - w3 * x2) * y1 +
		x1 * (w3 * y2 - w2 * y3) + x0 * (w2 * y3 + w1 * (y2 - y3) - w3 * y2 + (w3 - w2) * y1) +
		w1 * (x2 * y3 - x3 * y2) + w0 * (x1 * (y3 - y2) - x2 * y3 + x3 * y2 + (x2 - x3) * y1)) / den
	o.c = ((w1 * (y3 - y2) - w2 * y3 + w3 * y2 + (w2 - w3) * y1) * z0 + (w2 * y3 - w3 * y2) * z1 +
		y1 * (w3 * z2 - w2 * z3) + y0 * (w2 * z3 + w1 * (z2 - z3) - w3 * z2 + (w3 - w2) * z1) +
		w1 * (y2 * z3 - y3 * z2) + w0 * (y1 * (z3 - z2) - y2 * z3 + y3 * z2 + (y2 - y3) * z1)) / den
	o.d = ((w1 * (x3 * y2 - x2 * y3) + x1 * (w2 * y3 - w3 * y2) + (w3 * x2 - w2 * x3) * y1) * z0 +
		y0 * (w1 * (x2 * z3 - x3 * z2) + x1 * (w3 * z2 - w2 * z3) + (w2 * x3 - w3 * x2) * z1) +
		x0 * (w1 * (y3 * z2 - y2 * z3) + y1 * (w2 * z3 - w3 * z2) + (w3 * y2 - w2 * y3) * z1) +
		w0 * (x1 * (y2 * z3 - y3 * z2) + y1 * (x3 * z2 - x2 * z3) + (x2 * y3 - x3 * y2) * z1)) / den
}

// fit_3points_d fits polynomial to 3 points and known derivative
//   (x0, y0) -- first point
//   (x1, y1) -- second point
//   (x2, y2) -- third point
//   (x3, d3) -- derivative @ x3
pub fn (mut o InterpCubic) fit_3points_d(x0 f64, y0 f64, x1 f64, y1 f64, x2 f64, y2 f64, x3 f64, d3 f64) ? {
	z0, z1, z2, z3 := x0 * x0, x1 * x1, x2 * x2, x3 * x3
	w0, w1, w2 := z0 * x0, z1 * x1, z2 * x2
	den := x0 * (2 * w1 * x3 - 2 * w2 * x3 - 3 * z1 * z3 + 3 * z2 * z3) +
		x1 * (2 * w2 * x3 - 3 * z2 * z3) + z1 * (3 * x2 * z3 - w2) + z0 * (-w1 + w2 +
		3 * x1 * z3 - 3 * x2 * z3) + w1 * (z2 - 2 * x2 * x3) + w0 * (-2 * x1 * x3 + 2 * x2 * x3 +
		z1 - z2)
	if math.abs(den) < o.tol_den {
		return errors.error('Cannot fit 3 points because denominator=$den is near zero.\n\t(x0,y0)=($x0,$y0)\t(x1,y1)=($x1,$y1)\t(x2,y2)=($x2,$y2)\t(x3,d3)=($x3,$d3)',
			.ezerodiv)
	}
	o.a = -(-2 * x1 * x3 * y2 + x0 * (2 * x3 * y2 - 2 * x3 * y1) + (y1 - y2) * z0 + y2 * z1 +
		y1 * (2 * x2 * x3 - z2) + y0 * (z2 - z1 - 2 * x2 * x3 + 2 * x1 * x3)) / den
	o.b = (w0 * (y1 - y2) + w1 * y2 - 3 * x1 * y2 * z3 + y0 * (-3 * x2 * z3 + 3 * x1 * z3 +
		w2 - w1) + y1 * (3 * x2 * z3 - w2) + x0 * (3 * y2 * z3 - 3 * y1 * z3)) / den
	o.c = (-2 * w1 * x3 * y2 + w0 * (2 * x3 * y2 - 2 * x3 * y1) + 3 * y2 * z1 * z3 +
		z0 * (3 * y1 * z3 - 3 * y2 * z3) + y1 * (2 * w2 * x3 - 3 * z2 * z3) +
		y0 * (3 * z2 * z3 - 3 * z1 * z3 - 2 * w2 * x3 + 2 * w1 * x3)) / den
	o.d = -(w0 * (y1 * (z2 - 2 * x2 * x3) - y2 * z1 + 2 * x1 * x3 * y2) +
		z0 * (y1 * (3 * x2 * z3 - w2) - 3 * x1 * y2 * z3 + w1 * y2) +
		x0 * (y1 * (2 * w2 * x3 - 3 * z2 * z3) + 3 * y2 * z1 * z3 - 2 * w1 * x3 * y2) +
		y0 * (x1 * (3 * z2 * z3 - 2 * w2 * x3) + z1 * (w2 - 3 * x2 * z3) + w1 * (2 * x2 * x3 - z2))) / den
}
