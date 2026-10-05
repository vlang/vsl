module float32

// ger performs the rank-one operation
//  A += alpha * x * yᵀ
// where A is an m×n dense matrix, x and y are vectors, and alpha is a scalar.
pub fn ger(m u32, n u32, alpha f32, x []f32, incx u32, y []f32, incy u32, mut a []f32, lda u32) {
	if incx == 1 && incy == 1 {
		for i, xv in x[..m] {
			axpy_unitary(alpha * xv, y[..n], mut a[u32(i) * lda..u32(i) * lda + n])
		}
		return
	}

	mut ky := u32(0)
	mut kx := u32(0)
	if int(incy) < 0 {
		ky = u32(-int(n - 1) * int(incy))
	}
	if int(incx) < 0 {
		kx = u32(-int(m - 1) * int(incx))
	}

	mut ix := kx
	for i := 0; i < int(m); i++ {
		axpy_inc(alpha * x[ix], y, mut a[u32(i) * lda..u32(i) * lda + n], n, incy, 1, ky, 0)
		ix += incx
	}
}

// gemv_n computes
//  y = alpha * A * x + beta * y
// where A is an m×n dense matrix, x and y are vectors, and alpha and beta are scalars.
pub fn gemv_n(m u32, n u32, alpha f32, a []f32, lda u32, x []f32, incx int, beta f32, mut y []f32, incy int) {
	if m == 0 || n == 0 {
		return
	}
	if incx == 1 && incy == 1 {
		for i in 0 .. m {
			sum := dot_unitary(a[lda * i..lda * i + n], x)
			if beta == 0 {
				y[i] = alpha * sum
			} else {
				y[i] = beta * y[i] + alpha * sum
			}
		}
		return
	}
	if incx > 0 && incy > 0 {
		mut iy := 0
		for i in 0 .. int(m) {
			sum := dot_inc(x, a[int(lda) * i..int(lda) * i + int(n)], n, u32(incx), 1, 0, 0)
			if beta == 0 {
				y[iy] = alpha * sum
			} else {
				y[iy] = beta * y[iy] + alpha * sum
			}
			iy += incy
		}
		return
	}
	start_x := if incx < 0 { (int(n) - 1) * -incx } else { 0 }
	start_y := if incy < 0 { (int(m) - 1) * -incy } else { 0 }
	for i in 0 .. int(m) {
		mut sum := f32(0)
		mut ix := start_x
		for j in 0 .. int(n) {
			sum += a[int(lda) * i + j] * x[ix]
			ix += incx
		}
		iy := start_y + i * incy
		if beta == 0 {
			y[iy] = alpha * sum
		} else {
			y[iy] = beta * y[iy] + alpha * sum
		}
	}
}

// gemv_t computes
//  y = alpha * Aᵀ * x + beta * y
// where A is an m×n dense matrix, x and y are vectors, and alpha and beta are scalars.
pub fn gemv_t(m u32, n u32, alpha f32, a []f32, lda u32, x []f32, incx int, beta f32, mut y []f32, incy int) {
	if m == 0 || n == 0 {
		return
	}
	if incx == 1 && incy == 1 {
		if beta == 0 {
			for j in 0 .. n {
				y[j] = 0
			}
		} else {
			scal_unitary(beta, mut y[..n])
		}
		for i in 0 .. m {
			axpy_unitary_to(mut y[..n], alpha * x[i], a[lda * i..lda * i + n], y[..n])
		}
		return
	}
	if incx > 0 && incy > 0 {
		for j in 0 .. int(n) {
			iy := j * incy
			if beta == 0 {
				y[iy] = 0
			} else {
				y[iy] *= beta
			}
		}
		for i in 0 .. int(m) {
			axpy_inc(alpha * x[i * incx], a[int(lda) * i..int(lda) * i + int(n)], mut y, n, 1,
				u32(incy), 0, 0)
		}
		return
	}
	start_x := if incx < 0 { (int(m) - 1) * -incx } else { 0 }
	start_y := if incy < 0 { (int(n) - 1) * -incy } else { 0 }
	for j in 0 .. int(n) {
		mut sum := f32(0)
		mut ix := start_x
		for i in 0 .. int(m) {
			sum += a[int(lda) * i + j] * x[ix]
			ix += incx
		}
		iy := start_y + j * incy
		if beta == 0 {
			y[iy] = alpha * sum
		} else {
			y[iy] = beta * y[iy] + alpha * sum
		}
	}
}
