module fun

import math
import vsl.errors

// InterpFn defines the type of the implementation of the data interpolation
pub type InterpFn = fn (mut o DataInterp, j int, x f64) f64

// DataInterp implements numeric interpolators to be used with discrete data
[heap]
pub struct DataInterp {
mut:
	// input data
	itype string // type of interpolator
	xx    []f64  // x-data values
	yy    []f64  // y-data values
	// derived data
	m        int  // number of points of interpolating formula; e.g. 2 for segments, 3 for 2nd order polynomials
	n        int  // length of xx
	j_hunt   int  // temporary j to decide on using hunt
	dj_hunt  int  // increent of j to decide on using hunt function or locate
	use_hunt bool // use hunt code instead of locate
	ascnd    bool // ascending order of x-values
	// implementation
	interp InterpFn
pub mut:
	// configuration data
	disable_hunt bool // do not use hunt code at all
	// output data
	dy f64 // error estimate
}

// new_data_interp creates new interpolator for data point sets xx and yy (with same lengths)
//
//     type -- type of interpolator
//        "lin"  : linear
//        "poly" : polynomial
//
//     p  -- order of interpolator
//     xx -- x-data
//     yy -- y-data
pub fn new_data_interp(itype string, p int, xx []f64, yy []f64) &DataInterp {
	mut o := &DataInterp{
		itype: itype
	}
	match itype {
		'lin' {
			o.m = 2
			o.interp = lin_interp
		}
		'poly' {
			o.m = p + 1
			o.interp = poly_interp
		}
		else {
			errors.vsl_panic('cannot find interpolator type == $itype', .efailed)
		}
	}
	o.reset(xx, yy)
	return o
}

// reset re-assigns xx and yy data sets
pub fn (mut o DataInterp) reset(xx []f64, yy []f64) {
	if xx.len != yy.len {
		errors.vsl_panic('lengths of data sets must be the same. $xx.len != $yy.len',
			.efailed)
	}
	if xx.len < 2 {
		errors.vsl_panic('length of data sets must be at least 2. $xx.len is invalid',
			.efailed)
	}
	if xx.len < o.m {
		errors.vsl_panic('length of data sets must be greater than or equal to $o.m when using $o.itype interpolator\n',
			.efailed)
	}
	o.xx = xx
	o.yy = yy
	o.n = xx.len
	o.dj_hunt = math.min(1, int(math.pow(f64(o.n), 0.25)))
	o.use_hunt = false
	o.ascnd = o.xx[o.n - 1] >= o.xx[0]
}

// p computes p(x); i.e. performs the interpolation
pub fn (mut o DataInterp) p(x f64) f64 {
	mut jlo := 0
	if o.use_hunt && !o.disable_hunt {
		jlo = o.hunt(x)
	} else {
		jlo = o.locate(x)
	}
	interp := o.interp
	return interp(mut o, jlo, x)
}

// locate returns a value j such that x is (insofar as possible) centered in the subrange
// xx[j..j+mm-1], where xx is the stored pointer. the values in xx must be monotonic, either
// increasing or decreasing. the returned value is not less than 0, nor greater than n-1.
pub fn (mut o DataInterp) locate(x f64) int {
	// bisection
	mut jl := 0 // initialize lower
	mut ju := o.n - 1 // and upper limits.
	for ju - jl > 1 { // if not done yet done
		jm := (ju + jl) >> 1 // compute a midpoint
		if x >= o.xx[jm] == o.ascnd {
			jl = jm // replace the lower limit
		} else {
			ju = jm // replace the upper limit
		}
	}

	// set hunt flag
	if math.abs(jl - o.j_hunt) > o.dj_hunt {
		o.use_hunt = false // too large, use locate next time
	} else {
		o.use_hunt = true // ok, use hunt next time
	}
	o.j_hunt = jl

	// results
	return math.max(0, math.min(o.n - o.m, jl - ((o.m - 2) >> 1)))
}

// hunt returns a value j such that x is (insofar as possible) centered in the subrange
// xx[j..j+mm-1], where xx is the stored pointer. the values in xx must be monotonic, either
// increasing or decreasing. the returned value is not less than 0, nor greater than n-1.
pub fn (mut o DataInterp) hunt(x f64) int {
	// hunting
	mut jl := o.j_hunt
	mut inc := 1
	mut ju := 0
	mut jm := 0
	if jl < 0 || jl > o.n - 1 { // input guess not useful. skip hunting
		jl = 0
		ju = o.n - 1
	} else {
		if x >= o.xx[jl] == o.ascnd { // hunt up
			for {
				ju = jl + inc
				if ju >= o.n - 1 {
					ju = o.n - 1
					break // off end of table.
				} else if x < o.xx[ju] == o.ascnd {
					break // found bracket.
				} else { // not done, so double the increment and try again.
					jl = ju
					inc += inc
				}
			}
		} else { // hunt down
			ju = jl
			for {
				jl = jl - inc
				if jl <= 0 {
					jl = 0
					break // off end of table.
				} else if x >= o.xx[jl] == o.ascnd {
					break // found bracket.
				} else { // not done, so double the increment and try again.
					ju = jl
					inc += inc
				}
			}
		}
	}

	// hunt is done, so begin the final bisection phase:
	for ju - jl > 1 {
		jm = (ju + jl) >> 1
		if x >= o.xx[jm] == o.ascnd {
			jl = jm
		} else {
			ju = jm
		}
	}

	// set hunt flag
	if math.abs(jl - o.j_hunt) > o.dj_hunt {
		o.use_hunt = false
	} else {
		o.use_hunt = true
	}
	o.j_hunt = jl

	// results
	return math.max(0, math.min(o.n - o.m, jl - ((o.m - 2) >> 1)))
}

// lin_interp implements linear interpolator
pub fn lin_interp(mut o DataInterp, j int, x f64) f64 {
	if o.xx[j] == o.xx[j + 1] { // table is defective, but we can recover.
		return o.yy[j]
	}
	return o.yy[j] + (o.yy[j + 1] - o.yy[j]) * (x - o.xx[j]) / (o.xx[j + 1] - o.xx[j])
}

// poly_interp performs a polynomial interpolation. this routine returns an interpolated value y, and
// stores an error estimate dy. the returned value is obtained by m-point polynomial interpolation
// on the subrange xx[jl..jl+m-1].
pub fn poly_interp(mut o DataInterp, jl int, x f64) f64 {
	mut y := 0.0

	// allocate variables
	xa := o.xx[jl..]
	ya := o.yy[jl..]
	mut dif := math.abs(x - xa[0])
	mut c := []f64{len: o.m}
	mut d := []f64{len: o.m}

	// find the index ns of the closest table entry,
	mut ns := 0
	mut dift := 0.0
	for i in 0 .. o.m {
		dift = math.abs(x - xa[i])
		if dift < dif {
			ns = i
			dif = dift
		}
		c[i] = ya[i] // initialize the tableau of c's and d's.
		d[i] = ya[i]
	}

	// initial approximation to y.
	y = ya[ns]
	ns--

	// perform interpolation
	mut ho := 0.0
	mut hp := 0.0
	mut w := 0.0
	mut den := 0.0
	for m in 1 .. o.m { // for each column of the tableau,
		for i in 0 .. o.m - m { // loop over the current c's and d's and update them.
			ho = xa[i] - x
			hp = xa[i + m] - x
			w = c[i + 1] - d[i]
			den = ho - hp
			if den == 0.0 {
				errors.vsl_panic('poly_interp failed because two input x points are identical (within roundoff)',
					.efailed)
			}
			den = w / den
			d[i] = hp * den
			c[i] = ho * den
		}
		if 2 * (ns + 1) < (o.m - m) {
			o.dy = c[ns + 1]
		} else {
			o.dy = d[ns]
			ns--
		}
		y += o.dy
	}
	return y
}
