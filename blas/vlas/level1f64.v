module vlas

import vsl.blas.vlas.internal.float64
import vsl.vmath as math

// dnrm2 computes the Euclidean norm of a vector,
//  sqrt(\sum_i x[i] * x[i]).
// This function returns 0 if incx is negative.
pub fn dnrm2(n int, x []f64, incx int) f64 {
        if incx < 1 {
                if incx == 0 {
                        panic(zero_incx)
                }
                return 0.0
        }
        if x.len <= (n-1)*incx {
                panic(short_x)
        }
        if n < 2 {
                if n == 1 {
                        return math.abs(x[0])
                }
                if n == 0 {
                        return 0.0
                }
                panic(nlt0)
        }
        if incx == 1 {
                return float64.l2_norm_unitary(x[..n])
        }
        return float64.l2_norm_inc(x, u32(n), u32(incx))
}

// dasum computes the sum of the absolute values of the elements of x.
//  \sum_i |x[i]|
// dasum returns 0 if incx is negative.
pub fn dasum(n int, x []f64, incx int) f64 {
        mut sum := 0.0
        if n < 0 {
                panic(nlt0)
        }
        if incx < 1 {
                if incx == 0 {
                        panic(zero_incx)
                }
                return 0.0
        }
        if x.len <= (n-1)*incx {
                panic(short_x)
        }
        if incx == 1 {
                for v in x[..n] {
                        sum += math.abs(v)
                }
                return sum
        }
        for i in 0 .. n {
                sum += math.abs(x[i*incx])
        }
        return sum
}

// idamax returns the index of an element of x with the largest absolute value.
// If there are multiple such indices the earliest is returned.
// idamax returns -1 if n == 0.
pub fn idamax(n int, x []f64, incx int) int {
        if incx < 1 {
                if incx == 0 {
                        panic(zero_incx)
                }
                return 0
        }
        if x.len <= (n-1)*incx {
                panic(short_x)
        }
        if n < 2 {
		if n == 1 {
			return 0
		}
		if n == 0 {
			return -1 // Netlib returns invalid index when n == 0.
		}
		panic(nlt0)
	}
        mut idx := 0
	mut max := math.abs(x[0])
	if incx == 1 {
		for i, v in x[..n] {
			abs_v := math.abs(v)
			if abs_v > max {
				max = abs_v
				idx = i
			}
		}
		return idx
	}
	mut ix := incx
	for i in 1 .. n {
		v := x[ix]
		abs_v := math.abs(v)
		if abs_v > max {
			max = abs_v
			idx = i
		}
		ix += incx
	}
	return idx
}

// dswap exchanges the elements of two vectors.
//  x[i], y[i] = y[i], x[i] for all i
pub fn dswap(n int, mut x []f64, incx int, mut y []f64, incy int) {
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (incx > 0 && x.len <= (n-1)*incx) || (incx < 0 && x.len <= (1-n)*incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n-1)*incy) || (incy < 0 && y.len <= (1-n)*incy) {
		panic(short_y)
	}
	if incx == 1 && incy == 1 {
		for i, v in x[..n] {
			x[i], y[i] = y[i], v
		}
		return
	}
	mut ix := 0
        mut iy := 0
	if incx < 0 {
		ix = (-n + 1) * incx
	}
	if incy < 0 {
		iy = (-n + 1) * incy
	}
	for i := 0; i < n; i++ {
                tmp := x[ix]
		x[ix] = y[iy]
                y[iy] = tmp
		ix += incx
		iy += incy
	}
}

// dcopy copies the elements of x into the elements of y.
//  y[i] = x[i] for all i
pub fn dcopy(n int, x []f64, incx int, mut y []f64, incy int) {
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (incx > 0 && x.len <= (n-1)*incx) || (incx < 0 && x.len <= (1-n)*incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n-1)*incy) || (incy < 0 && y.len <= (1-n)*incy) {
		panic(short_y)
	}
	if incx == 1 && incy == 1 {
                for i, v in x[..n] {
                        y[i] = x[i]
                }
		return
	}
	mut ix := 0
        mut iy := 0
	if incx < 0 {
		ix = (-n + 1) * incx
	}
	if incy < 0 {
		iy = (-n + 1) * incy
	}
	for i := 0; i < n; i++ {
		y[iy] = x[ix]
		ix += incx
		iy += incy
	}
}

// daxpy adds alpha times x to y
//  y[i] += alpha * x[i] for all i
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (incx > 0 && x.len <= (n-1)*incx) || (incx < 0 && x.len <= (1-n)*incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n-1)*incy) || (incy < 0 && y.len <= (1-n)*incy) {
		panic(short_y)
	}
	if alpha == 0 {
		return
	}
	if incx == 1 && incy == 1 {
		float64.axpy_unitary(alpha, x[..n], mut y[..n])
		return
	}
	mut ix := 0
        mut iy := 0
	if incx < 0 {
		ix = (-n + 1) * incx
	}
	if incy < 0 {
		iy = (-n + 1) * incy
	}
	float64.axpy_inc(alpha, x, mut y, u32(n), u32(incx), u32(incy), u32(ix), u32(iy))
}

// drotg computes the plane rotation
//   _    _      _ _       _ _
//  |  c s |    | a |     | r |
//  | -s c |  * | b |   = | 0 |
//   ‾    ‾      ‾ ‾       ‾ ‾
// where
//  r = ±√(a^2 + b^2)
//  c = a/r, the cosine of the plane rotation
//  s = b/r, the sine of the plane rotation
//
// NOTE: There is a discrepancy between the reference implementation and the BLAS
// technical manual regarding the sign for r when a or b are zero.
// drotg agrees with the definition in the manual and other
// common BLAS implementations.
pub fn drotg(a f64, b f64) (f64, f64, f64, f64) {
	if b == 0 && a == 0 {
		return 1.0, 0.0, a, 0.0
	}
	abs_a := math.abs(a)
	abs_b := math.abs(b)
	agtb := abs_a > abs_b
	mut r := math.hypot(a, b)
	if agtb {
		r = math.copysign(r, a)
	} else {
		r = math.copysign(r, b)
	}
	mut c := a / r
	mut s := b / r
        mut z := 0.0
	if agtb {
		z = s
	} else if c != 0 {
                // r == 0 case handled above
		z = 1 / c
	} else {
		z = 1
	}
	return c, s, r, z
}

// drot applies a plane transformation.
//  x[i] = c * x[i] + s * y[i]
//  y[i] = c * y[i] - s * x[i]
pub fn drot(n int, mut x []f64, incx int, mut y []f64, incy int, c f64, s f64) {
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (incx > 0 && x.len <= (n-1)*incx) || (incx < 0 && x.len <= (1-n)*incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n-1)*incy) || (incy < 0 && y.len <= (1-n)*incy) {
		panic(short_y)
	}
	if incx == 1 && incy == 1 {
		for i, vx in x[..n] {
			vy := y[i]
			x[i] = c*vx+s*vy
                        y[i] = c*vy-s*vx
		}
		return
	}
	mut ix := 0
        mut iy := 0
	if incx < 0 {
		ix = (-n + 1) * incx
	}
	if incy < 0 {
		iy = (-n + 1) * incy
	}
	for i in 0 .. n {
		vx := x[ix]
		vy := y[iy]
                x[i] = c*vx+s*vy
                y[i] = c*vy-s*vx
		ix += incx
		iy += incy
	}
}

// dscal scales x by alpha.
//  x[i] *= alpha
// dscal has no effect if incx < 0.
pub fn dscal(n int, alpha f64, mut x []f64, incx int) {
	if incx < 1 {
		if incx == 0 {
			panic(zero_incx)
		}
		return
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (n-1)*incx >= x.len {
		panic(short_x)
	}
	if alpha == 0 {
		if incx == 1 {
			for i in 0 .. n {
				x[i] = 0
			}
			return
		}
		for ix := 0; ix < n*incx; ix += incx {
			x[ix] = 0
		}
		return
	}
	if incx == 1 {
		float64.scal_unitary(alpha, mut x[..n])
		return
	}
	float64.scal_inc(alpha, mut x, u32(n), u32(incx))
}
