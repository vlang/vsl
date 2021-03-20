module vlas

import vsl.blas.vlas.internal.float64
import vsl.util
import vsl.vmath as math

// dnrm2 computes the Euclidean norm of a vector,
//  sqrt(\sum_i x[i] * x[i]).
// This function returns 0 if inc_x is negative.
pub fn dnrm2(n int, x []f64, inc_x int) f64 {
        if inc_x < 1 {
                if inc_x == 0 {
                        panic(zero_inc_x)
                }
                return 0.0
        }
        if x.len <= (n-1)*inc_x {
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
        if inc_x == 1 {
                return float64.l2_norm_unitary(x[..n])
        }
        return float64.l2_norm_inc(x, u32(n), u32(inc_x))
}

// dasum computes the sum of the absolute values of the elements of x.
//  \sum_i |x[i]|
// dasum returns 0 if inc_x is negative.
pub fn dasum(n int, x []f64, inc_x int) f64 {
        mut sum := 0.0
        if n < 0 {
                panic(nlt0)
        }
        if inc_x < 1 {
                if inc_x == 0 {
                        panic(zero_inc_x)
                }
                return 0.0
        }
        if x.len <= (n-1)*inc_x {
                panic(short_x)
        }
        if inc_x == 1 {
                for v in x[..n] {
                        sum += math.abs(v)
                }
                return sum
        }
        for i in 0 .. n {
                sum += math.abs(x[i*inc_x])
        }
        return sum
}

// idamax returns the index of an element of x with the largest absolute value.
// If there are multiple such indices the earliest is returned.
// idamax returns -1 if n == 0.
pub fn idamax(n int, x []f64, inc_x int) int {
        if inc_x < 1 {
                if inc_x == 0 {
                        panic(zero_inc_x)
                }
                return 0
        }
        if x.len <= (n-1)*inc_x {
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
	if inc_x == 1 {
		for i, v in x[..n] {
			abs_v := math.abs(v)
			if abs_v > max {
				max = abs_v
				idx = i
			}
		}
		return idx
	}
	mut ix := inc_x
	for i in 1 .. n {
		v := x[ix]
		abs_v := math.abs(v)
		if abs_v > max {
			max = abs_v
			idx = i
		}
		ix += inc_x
	}
	return idx
}

// dswap exchanges the elements of two vectors.
//  x[i], y[i] = y[i], x[i] for all i
pub fn dswap(n int, mut x []f64, inc_x int, mut y []f64, inc_y int) {
	if inc_x == 0 {
		panic(zero_inc_x)
	}
	if inc_y == 0 {
		panic(zero_inc_y)
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (inc_x > 0 && x.len <= (n-1)*inc_x) || (inc_x < 0 && x.len <= (1-n)*inc_x) {
		panic(short_x)
	}
	if (inc_y > 0 && y.len <= (n-1)*inc_y) || (inc_y < 0 && y.len <= (1-n)*inc_y) {
		panic(short_y)
	}
	if inc_x == 1 && inc_y == 1 {
		for i, v in x[..n] {
			x[i], y[i] = y[i], v
		}
		return
	}
	mut ix := 0
        mut iy := 0
	if inc_x < 0 {
		ix = (-n + 1) * inc_x
	}
	if inc_y < 0 {
		iy = (-n + 1) * inc_y
	}
	for i := 0; i < n; i++ {
                tmp := x[ix]
		x[ix] = y[iy]
                y[iy] = tmp
		ix += inc_x
		iy += inc_y
	}
}

// dcopy copies the elements of x into the elements of y.
//  y[i] = x[i] for all i
pub fn dcopy(n int, x []f64, inc_x int, mut y []f64, inc_y int) {
	if inc_x == 0 {
		panic(zero_inc_x)
	}
	if inc_y == 0 {
		panic(zero_inc_y)
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (inc_x > 0 && x.len <= (n-1)*inc_x) || (inc_x < 0 && x.len <= (1-n)*inc_x) {
		panic(short_x)
	}
	if (inc_y > 0 && y.len <= (n-1)*inc_y) || (inc_y < 0 && y.len <= (1-n)*inc_y) {
		panic(short_y)
	}
	if inc_x == 1 && inc_y == 1 {
                for i, v in x[..n] {
                        y[i] = x[i]
                }
		return
	}
	mut ix := 0
        mut iy := 0
	if inc_x < 0 {
		ix = (-n + 1) * inc_x
	}
	if inc_y < 0 {
		iy = (-n + 1) * inc_y
	}
	for i := 0; i < n; i++ {
		y[iy] = x[ix]
		ix += inc_x
		iy += inc_y
	}
}

// daxpy adds alpha times x to y
//  y[i] += alpha * x[i] for all i
pub fn daxpy(n int, alpha f64, x []f64, inc_x int, mut y []f64, inc_y int) {
	if inc_x == 0 {
		panic(zero_inc_x)
	}
	if inc_y == 0 {
		panic(zero_inc_y)
	}
	if n < 1 {
		if n == 0 {
			return
		}
		panic(nlt0)
	}
	if (inc_x > 0 && x.len <= (n-1)*inc_x) || (inc_x < 0 && x.len <= (1-n)*inc_x) {
		panic(short_x)
	}
	if (inc_y > 0 && y.len <= (n-1)*inc_y) || (inc_y < 0 && y.len <= (1-n)*inc_y) {
		panic(short_y)
	}
	if alpha == 0 {
		return
	}
	if inc_x == 1 && inc_y == 1 {
		float64.axpy_unitary(alpha, x[..n], mut y[..n])
		return
	}
	mut ix := 0
        mut iy := 0
	if inc_x < 0 {
		ix = (-n + 1) * inc_x
	}
	if inc_y < 0 {
		iy = (-n + 1) * inc_y
	}
	float64.axpy_inc(alpha, x, mut y, u32(n), u32(inc_x), u32(inc_y), u32(ix), u32(iy))
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
