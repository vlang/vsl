module vlas

import vsl.float.float64
import vsl.util

// dgemv computes
//  y = alpha * A * x + beta * y   if trans_a = blas_no_trans
//  y = alpha * Aᵀ * x + beta * y  if trans_a = blas_trans or blas_conj_trans
// where A is an m×n dense matrix, x and y are vectors, and alpha and beta are scalars.
pub fn dgemv(trans_a Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if m < 0 {
		panic(mlt0)
	}
	if n < 0 {
		panic(nlt0)
	}
	if lda < util.imax(1, n) {
		panic(bad_ld_a)
	}
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}
	// Set up indexes
	mut len_x := m
	mut len_y := n
	if trans_a == blas_no_trans {
		len_x = n
		len_y = m
	}

	// Quick return if possible
	if m == 0 || n == 0 {
		return
	}

	if (incx > 0 && (len_x - 1) * incx >= x.len) || (incx < 0 && (1 - len_x) * incx >= x.len) {
		panic(short_x)
	}
	if (incy > 0 && (len_y - 1) * incy >= y.len) || (incy < 0 && (1 - len_y) * incy >= y.len) {
		panic(short_y)
	}
	if a.len < lda * (m - 1) + n {
		panic(short_a)
	}

	// Quick return if possible
	if alpha == 0.0 && beta == 1 {
		return
	}

	if alpha == 0.0 {
		// First form y = beta * y
		if incy > 0 {
			dscal(len_y, beta, mut y, incy)
		} else {
			dscal(len_y, beta, mut y, -incy)
		}
		return
	}

	// Form y = alpha * A * x + y
	if trans_a == blas_no_trans {
		float64.gemv_n(u32(m), u32(n), alpha, a, u32(lda), x, u32(incx), beta, mut y,
			u32(incy))
		return
	}
	// Cases where a is transposed.
	float64.gemv_t(u32(m), u32(n), alpha, a, u32(lda), x, u32(incx), beta, mut y, u32(incy))
}
