module float64

// ger performs the rank-one operation
//  A += alpha * x * yᵀ
// where A is an m×n dense matrix, x and y are vectors, and alpha is a scalar.
pub fn ger(m, n u32, alpha f64, x []f64, inc_x u32, y []f64, inc_y u32, a []f64, lda u32) {
	if inc_x == 1 && inc_y == 1 {
		x = x[..m]
		y = y[..n]
		for i, xv := range x {
			axpy_unitary(alpha*xv, y, mut a[i*lda:i*lda+n])
		}
		return
	}

	var ky, kx u32
	if int(inc_y) < 0 {
		ky = u32(-int(n-1) * int(inc_y))
	}
	if int(inc_x) < 0 {
		kx = u32(-int(m-1) * int(inc_x))
	}

	ix := kx
	for i := 0; i < int(m); i++ {
		axpy_inc(alpha*x[ix], y, mut a[i*lda..i*lda+n], n, inc_y, 1, ky, 0)
		ix += inc_x
	}
}

// gemv_n computes
//  y = alpha * A * x + beta * y
// where A is an m×n dense matrix, x and y are vectors, and alpha and beta are scalars.
pub fn gemv_n(m, n u32, alpha f64, a []f64, lda u32, x []f64, inc_x u32, beta f64, y []f64, inc_y u32) {
	mut kx := u32(0)
        mut ky := u32(0)
	if int(inc_x) < 0 {
		kx = u32(-int(n-1) * int(inc_x))
	}
	if int(inc_y) < 0 {
		ky = u32(-int(m-1) * int(inc_y))
	}

	if inc_x == 1 && inc_y == 1 {
		if beta == 0 {
			for i := 0; i < m; i++ {
				y[i] = alpha * dot_unitary(a[lda*i..lda*i+n], x)
			}
			return
		}
		for i := 0; i < m; i++ {
			y[i] = y[i]*beta + alpha*dot_unitary(a[lda*i..lda*i+n], x)
		}
		return
	}
	iy := ky
	if beta == 0 {
		for i := 0; i < m; i++ {
			y[iy] = alpha * dot_inc(x, a[lda*i..lda*i+n], n, inc_x, 1, kx, 0)
			iy += inc_y
		}
		return
	}
	for i := 0; i < m; i++ {
		y[iy] = y[iy]*beta + alpha*dot_inc(x, a[lda*i..lda*i+n], n, inc_x, 1, kx, 0)
		iy += inc_y
	}
}

// gemv_t computes
//  y = alpha * Aᵀ * x + beta * y
// where A is an m×n dense matrix, x and y are vectors, and alpha and beta are scalars.
pub fn gemv_t(m, n u32, alpha f64, a []f64, lda u32, x []f64, inc_x u32, beta f64, y []f64, inc_y u32) {
	mut kx := u32(0)
        mut ky := u32(0)
	if int(inc_x) < 0 {
		kx = u32(-int(m-1) * int(inc_x))
	}
	if int(inc_y) < 0 {
		ky = u32(-int(n-1) * int(inc_y))
	}
	if beta == 0 {
                // beta == 0 is special-cased to memclear
		if inc_y == 1 {
			for i := range y {
				y[i] = 0
			}
		} else {
			iy := ky
			for i := 0; i < int(n); i++ {
				y[iy] = 0
				iy += inc_y
			}
		}
	} else if int(inc_y) < 0 {
		scal_inc(beta, mut y, n, u32(int(-inc_y)))
        } else if inc_y == 1 {
		scal_unitary(beta, mut y[..n])
        } else {
		scal_inc(beta, mut y, n, inc_y)
	}

	if inc_x == 1 && inc_y == 1 {
		for i := 0; i < m; i++ {
			axpy_unitary_to(mut y, alpha*x[i], a[lda*i..lda*i+n], y)
		}
		return
	}
	ix := kx
	for i := 0; i < m; i++ {
		axpy_inc(alpha*x[ix], a[lda*i..lda*i+n], mut y, n, 1, inc_y, 0, ky)
		ix += inc_x
	}
}
