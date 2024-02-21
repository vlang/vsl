module fun

import math
import vsl.internal.prec

// sinh(x) series
// double-precision for |x| < 1.0
@[inline]
fn sinh_series(x f64) f64 {
	y := x * x
	c0 := 1.0 / 6.0
	c1 := 1.0 / 120.0
	c2 := 1.0 / 5040.0
	c3 := 1.0 / 362880.0
	c4 := 1.0 / 39916800.0
	c5 := 1.0 / 6227020800.0
	c6 := 1.0 / 1307674368000.0
	c7 := 1.0 / 355687428096000.0
	return x * (1.0 + y * (c0 + y * (c1 + y * (c2 + y * (c3 + y * (c4 + y * (c5 + y * (c6 +
		y * c7))))))))
}

// cosh(x)-1 series
// double-precision for |x| < 1.0
@[inline]
fn cosh_m1_series(x f64) f64 {
	y := x * x
	c0 := f64(0.5)
	c1 := 1.0 / 24.0
	c2 := 1.0 / 720.0
	c3 := 1.0 / 40320.0
	c4 := 1.0 / 3628800.0
	c5 := 1.0 / 479001600.0
	c6 := 1.0 / 87178291200.0
	c7 := 1.0 / 20922789888000.0
	c8 := 1.0 / 6402373705728000.0
	return y * (c0 + y * (c1 + y * (c2 + y * (c3 + y * (c4 + y * (c5 + y * (c6 + y * (c7 +
		y * c8))))))))
}

const sin_data = [
	-0.3295190160663511504173,
	0.0025374284671667991990,
	0.0006261928782647355874,
	-4.6495547521854042157541e-06,
	-5.6917531549379706526677e-07,
	3.7283335140973803627866e-09,
	3.0267376484747473727186e-10,
	-1.7400875016436622322022e-12,
	-1.0554678305790849834462e-13,
	5.3701981409132410797062e-16,
	2.5984137983099020336115e-17,
	-1.1821555255364833468288e-19,
]
const sin_cs = ChebSeries{
	c: sin_data
	order: 11
	a: -1
	b: 1
}
const cos_data = [
	0.165391825637921473505668118136,
	-0.00084852883845000173671196530195,
	-0.000210086507222940730213625768083,
	1.16582269619760204299639757584e-6,
	1.43319375856259870334412701165e-7,
	-7.4770883429007141617951330184e-10,
	-6.0969994944584252706997438007e-11,
	2.90748249201909353949854872638e-13,
	1.77126739876261435667156490461e-14,
	-7.6896421502815579078577263149e-17,
	-3.7363121133079412079201377318e-18,
]
const cos_cs = ChebSeries{
	c: cos_data
	order: 10
	a: -1
	b: 1
}
const p1 = 7.85398125648498535156e-1
const p2 = 3.77489470793079817668e-8
const p3 = 2.69515142907905952645e-15

pub fn sin_e(x f64) (f64, f64) {
	sgn_x := if x < 0 { -1 } else { 1 }
	abs_x := math.abs(x)
	if abs_x < prec.root4_f64_epsilon {
		x2 := x * x
		return x * (1.0 - x2 / 6.0), math.abs(x * x2 * x2 / 100.0)
	} else {
		mut sgn_result := sgn_x
		mut y := math.floor(abs_x / (0.25 * math.pi))
		mut octant := int(y - math.ldexp(math.floor(math.ldexp(y, -3)), 3))
		if (octant & 1) == 1 {
			octant++
			octant &= 7
			y += 1.0
		}
		if octant > 3 {
			octant -= 4
			sgn_result = -sgn_result
		}
		z := ((abs_x - y * fun.p1) - y * fun.p2) - y * fun.p3
		mut result := 0.0
		mut result_err := 0.0
		if octant == 0 {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			sin_cs_val, _ := fun.sin_cs.eval_e(t)
			result = z * (1.0 + z * z * sin_cs_val)
		} else {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			cos_cs_val, _ := fun.cos_cs.eval_e(t)
			result = 1.0 - 0.5 * z * z * (1.0 - z * z * cos_cs_val)
		}
		result *= sgn_result
		if abs_x > 1.0 / prec.f64_epsilon {
			result_err = math.abs(result)
		} else if abs_x > 100.0 / prec.sqrt_f64_epsilon {
			result_err = 2.0 * abs_x * prec.f64_epsilon * math.abs(result)
		} else if abs_x > 0.1 / prec.sqrt_f64_epsilon {
			result_err = 2.0 * prec.sqrt_f64_epsilon * math.abs(result)
		} else {
			result_err = 2.0 * prec.f64_epsilon * math.abs(result)
		}
		return result, result_err
	}
}

pub fn cos_e(x f64) (f64, f64) {
	abs_x := math.abs(x)
	if abs_x < prec.root4_f64_epsilon {
		x2 := x * x
		return 1.0 - 0.5 * x2, math.abs(x2 * x2 / 12.0)
	} else {
		mut sgn_result := 1
		mut y := math.floor(abs_x / (0.25 * math.pi))
		mut octant := int(y - math.ldexp(math.floor(math.ldexp(y, -3)), 3))
		if (octant & 1) == 1 {
			octant++
			octant &= 7
			y += 1.0
		}
		if octant > 3 {
			octant -= 4
			sgn_result = -sgn_result
		}
		if octant > 1 {
			sgn_result = -sgn_result
		}
		z := ((abs_x - y * fun.p1) - y * fun.p2) - y * fun.p3
		mut result := 0.0
		mut result_err := 0.0
		if octant == 0 {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			cos_cs_val, _ := fun.cos_cs.eval_e(t)
			result = 1.0 - 0.5 * z * z * (1.0 - z * z * cos_cs_val)
		} else {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			sin_cs_val, _ := fun.sin_cs.eval_e(t)
			result = z * (1.0 + z * z * sin_cs_val)
		}
		result *= sgn_result
		if abs_x > 1.0 / prec.f64_epsilon {
			result_err = math.abs(result)
		} else if abs_x > 100.0 / prec.sqrt_f64_epsilon {
			result_err = 2.0 * abs_x * prec.f64_epsilon * math.abs(result)
		} else if abs_x > 0.1 / prec.sqrt_f64_epsilon {
			result_err = 2.0 * prec.sqrt_f64_epsilon * math.abs(result)
		} else {
			result_err = 2.0 * prec.f64_epsilon * math.abs(result)
		}
		return result, result_err
	}
}

pub fn sin(x f64) f64 {
	sgn_x := if x < 0 { -1 } else { 1 }
	abs_x := math.abs(x)
	if abs_x < prec.root4_f64_epsilon {
		x2 := x * x
		return x * (1.0 - x2 / 6.0)
	} else {
		mut sgn_result := sgn_x
		mut y := math.floor(abs_x / (0.25 * math.pi))
		mut octant := int(y - math.ldexp(math.floor(math.ldexp(y, -3)), 3))
		if (octant & 1) == 1 {
			octant++
			octant &= 7
			y += 1.0
		}
		if octant > 3 {
			octant -= 4
			sgn_result = -sgn_result
		}
		z := ((abs_x - y * fun.p1) - y * fun.p2) - y * fun.p3
		mut result := 0.0
		if octant == 0 {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			sin_cs_val, _ := fun.sin_cs.eval_e(t)
			result = z * (1.0 + z * z * sin_cs_val)
		} else {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			cos_cs_val, _ := fun.cos_cs.eval_e(t)
			result = 1.0 - 0.5 * z * z * (1.0 - z * z * cos_cs_val)
		}
		result *= sgn_result
		return result
	}
}

pub fn cos(x f64) f64 {
	abs_x := math.abs(x)
	if abs_x < prec.root4_f64_epsilon {
		x2 := x * x
		return 1.0 - 0.5 * x2
	} else {
		mut sgn_result := 1
		mut y := math.floor(abs_x / (0.25 * math.pi))
		mut octant := int(y - math.ldexp(math.floor(math.ldexp(y, -3)), 3))
		if (octant & 1) == 1 {
			octant++
			octant &= 7
			y += 1.0
		}
		if octant > 3 {
			octant -= 4
			sgn_result = -sgn_result
		}
		if octant > 1 {
			sgn_result = -sgn_result
		}
		z := ((abs_x - y * fun.p1) - y * fun.p2) - y * fun.p3
		mut result := 0.0
		if octant == 0 {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			cos_cs_val, _ := fun.cos_cs.eval_e(t)
			result = 1.0 - 0.5 * z * z * (1.0 - z * z * cos_cs_val)
		} else {
			t := 8.0 * math.abs(z) / math.pi - 1.0
			sin_cs_val, _ := fun.sin_cs.eval_e(t)
			result = z * (1.0 + z * z * sin_cs_val)
		}
		result *= sgn_result
		return result
	}
}
