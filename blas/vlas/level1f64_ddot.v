module vlas

import vsl.internal.float64

// ddot computes the dot product of the two vectors
//  \sum_i x[i]*y[i]
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}
	if n <= 0 {
		if n == 0 {
			return 0
		}
		panic(nlt0)
	}
	if incx == 1 && incy == 1 {
		if x.len < n {
			panic(short_x)
		}
		if y.len < n {
			panic(short_y)
		}
		return float64.dot_unitary(x[..n], y[..n])
	}
	mut ix := 0
	mut iy := 0
	if incx < 0 {
		ix = (-n + 1) * incx
	}
	if incy < 0 {
		iy = (-n + 1) * incy
	}
	if ix >= x.len || ix + (n - 1) * incx >= x.len {
		panic(short_x)
	}
	if iy >= y.len || iy + (n - 1) * incy >= y.len {
		panic(short_y)
	}
	return float64.dot_inc(x, y, u32(n), u32(incx), u32(incy), u32(ix), u32(iy))
}
