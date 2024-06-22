module lapack64

import math

// dlassq updates a sum of squares represented in scaled form. It returns
// the values scl and smsq such that
//
// 	scl^2*smsq = X[0]^2 + ... + X[n-1]^2 + scale^2*sumsq
//
// The value of sumsq is assumed to be non-negative.
pub fn dlassq(n int, x []f64, incx int, scale f64, sumsq f64) (f64, f64) {
	if n < 0 {
		panic('lapack: n < 0')
	}
	if incx <= 0 {
		panic('lapack: increment not one or negative one')
	}
	if x.len < 1 + (n - 1) * incx {
		panic('lapack: insufficient length of x')
	}

	if math.is_nan(scale) || math.is_nan(sumsq) {
		return scale, sumsq
	}

	mut scl := scale
	mut smsq := sumsq

	if smsq == 0.0 {
		scl = 1.0
	}
	if scl == 0.0 {
		scl = 1.0
		smsq = 0.0
	}

	if n == 0 {
		return scl, smsq
	}

	// Compute the sum of squares in 3 accumulators:
	//  - abig: sum of squares scaled down to avoid overflow
	//  - asml: sum of squares scaled up to avoid underflow
	//  - amed: sum of squares that do not require scaling
	// The thresholds and multipliers are:
	//  - values bigger than dtbig are scaled down by dsbig
	//  - values smaller than dtsml are scaled up by dssml
	mut is_big := false
	mut asml, mut amed, mut abig := 0.0, 0.0, 0.0
	mut ix := 0
	for _ in 0 .. n {
		mut ax := math.abs(x[ix])
		if ax > dtbig {
			ax *= dsbig
			abig += ax * ax
			is_big = true
		} else if ax < dtsml {
			if !is_big {
				ax *= dssml
				asml += ax * ax
			}
		} else {
			amed += ax * ax
		}
		ix += incx
	}
	// Put the existing sum of squares into one of the accumulators.
	if smsq > 0.0 {
		ax := scl * math.sqrt(smsq)
		if ax > dtbig {
			if scl > 1.0 {
				scl *= dsbig
				abig += scl * scl * smsq
			} else {
				// sumsq > dtbig^2 => (dsbig * (dsbig * sumsq)) is representable.
				abig += scl * scl * dsbig * dsbig * smsq
			}
		} else if ax < dtsml {
			if !is_big {
				if scl < 1.0 {
					scl *= dssml
					asml += scl * scl * smsq
				} else {
					// sumsq < dtsml^2 => (dssml * (dssml * sumsq)) is representable.
					asml += scl * scl * dssml * dssml * smsq
				}
			}
		} else {
			amed += scl * scl * smsq
		}
	}
	// Combine abig and amed or amed and asml if more than one accumulator was used.
	if abig > 0.0 {
		// Combine abig and amed:
		if amed > 0.0 || math.is_nan(amed) {
			abig += amed * dsbig * dsbig
		}
		scl = 1.0 / dsbig
		smsq = abig
	} else if asml > 0.0 {
		// Combine amed and asml:
		if amed > 0.0 || math.is_nan(amed) {
			amed = math.sqrt(amed)
			asml = math.sqrt(asml) / dssml
			mut ymin, mut ymax := asml, amed
			if asml > amed {
				ymin, ymax = amed, asml
			}
			scl = 1.0
			smsq = ymax * ymax * (1.0 + (ymin / ymax) * (ymin / ymax))
		} else {
			scl = 1.0 / dssml
			smsq = asml
		}
	} else {
		scl = 1.0
		smsq = amed
	}
	return scl, smsq
}
