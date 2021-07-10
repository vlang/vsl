module vlas

import vsl.internal.float64
import vsl.util

// dger performs the rank-one operation
//  A += alpha * x * yᵀ
// where A is an m×n dense matrix, x and y are vectors, and alpha is a scalar.
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
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

	// Quick return if possible.
	if m == 0 || n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if (incx > 0 && x.len <= (m - 1) * incx) || (incx < 0 && x.len <= (1 - m) * incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n - 1) * incy) || (incy < 0 && y.len <= (1 - n) * incy) {
		panic(short_y)
	}
	if a.len < lda * (m - 1) + n {
		panic(short_a)
	}

	// Quick return if possible.
	if alpha == 0 {
		return
	}
	float64.ger(u32(m), u32(n), alpha, x, u32(incx), y, u32(incy), mut a, u32(lda))
}

// dgbmv performs one of the matrix-vector operations
//  y = alpha * A * x + beta * y   if trans_a == blas_no_trans
//  y = alpha * Aᵀ * x + beta * y  if trans_a == blas_trans or blas_conj_trans
// where A is an m×n band matrix with kl sub-diagonals and ku super-diagonals,
// x and y are vectors, and alpha and beta are scalars.
pub fn dgbmv(trans_a Transpose, m int, n int, kl int, ku int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if m < 0 {
		panic(mlt0)
	}
	if n < 0 {
		panic(nlt0)
	}
	if kl < 0 {
		panic(kllt0)
	}
	if ku < 0 {
		panic(kult0)
	}
	if lda < kl + ku + 1 {
		panic(bad_ld_a)
	}
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}

	// Quick return if possible.
	if m == 0 || n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (util.imin(m, n + kl) - 1) + kl + ku + 1 {
		panic(short_a)
	}
	mut len_x := m
	mut len_y := n
	if trans_a == blas_no_trans {
		len_x = n
		len_y = m
	}
	if (incx > 0 && x.len <= (len_x - 1) * incx) || (incx < 0 && x.len <= (1 - len_x) * incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (len_y - 1) * incy) || (incy < 0 && y.len <= (1 - len_y) * incy) {
		panic(short_y)
	}

	// Quick return if possible.
	if alpha == 0 && beta == 1 {
		return
	}

	mut kx := 0
	mut ky := 0
	if incx < 0 {
		kx = -(len_x - 1) * incx
	}
	if incy < 0 {
		ky = -(len_y - 1) * incy
	}

	// Form y = beta * y.
	if beta != 1 {
		if incy == 1 {
			if beta == 0 {
				for i in 0 .. len_y {
					y[i] = 0
				}
			} else {
				float64.scal_unitary(beta, mut y[..len_y])
			}
		} else {
			mut iy := ky
			if beta == 0 {
				for _ in 0 .. len_y {
					y[iy] = 0
					iy += incy
				}
			} else {
				if incy > 0 {
					float64.scal_inc(beta, mut y, u32(len_y), u32(incy))
				} else {
					float64.scal_inc(beta, mut y, u32(len_y), u32(-incy))
				}
			}
		}
	}

	if alpha == 0 {
		return
	}

	// i and j are indices of the compacted banded matrix.
	// off is the offset into the dense matrix (off + j = densej)
	n_col := ku + 1 + kl
	if trans_a == blas_no_trans {
		mut iy := ky
		if incx == 1 {
			for i in 0 .. util.imin(m, n + kl) {
				l := util.imax(0, kl - i)
				u := util.imin(n_col, n + kl - i)
				off := util.imax(0, i - kl)
				atmp := a[i * lda + l..i * lda + u]
				xtmp := x[off..off + u - l]
				mut sum := 0.0
				for j, v in atmp {
					sum += xtmp[j] * v
				}
				y[iy] += sum * alpha
				iy += incy
			}
			return
		}
		for i in 0 .. util.imin(m, n + kl) {
			l := util.imax(0, kl - i)
			u := util.imin(n_col, n + kl - i)
			off := util.imax(0, i - kl)
			atmp := a[i * lda + l..i * lda + u]
			mut jx := kx
			mut sum := 0.0
			for v in atmp {
				sum += x[off * incx + jx] * v
				jx += incx
			}
			y[iy] += sum * alpha
			iy += incy
		}
		return
	}
	if incx == 1 {
		for i in 0 .. util.imin(m, n + kl) {
			l := util.imax(0, kl - i)
			u := util.imin(n_col, n + kl - i)
			off := util.imax(0, i - kl)
			atmp := a[i * lda + l..i * lda + u]
			tmp := alpha * x[i]
			mut jy := ky
			for v in atmp {
				y[jy + off * incy] += tmp * v
				jy += incy
			}
		}
		return
	}
	mut ix := kx
	for i in 0 .. util.imin(m, n + kl) {
		l := util.imax(0, kl - i)
		u := util.imin(n_col, n + kl - i)
		off := util.imax(0, i - kl)
		atmp := a[i * lda + l..i * lda + u]
		tmp := alpha * x[ix]
		mut jy := ky
		for v in atmp {
			y[jy + off * incy] += tmp * v
			jy += incy
		}
		ix += incx
	}
}

// dtrmv performs one of the matrix-vector operations
//  x = A * x   if trans_a == blas_no_trans
//  x = Aᵀ * x  if trans_a == blas_trans or blas_conj_trans
// where A is an n×n triangular matrix, and x is a vector.
pub fn dtrmv(ul Uplo, trans_a Transpose, d Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if d != blas_non_unit && d != blas_unit {
		panic(bad_diag)
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

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (n - 1) + n {
		panic(short_a)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}

	non_unit := d != blas_unit
	if n == 1 {
		if non_unit {
			x[0] *= a[0]
		}
		return
	}
	mut kx := 0
	if incx <= 0 {
		kx = -(n - 1) * incx
	}
	if trans_a == blas_no_trans {
		if ul == blas_upper {
			if incx == 1 {
				for i in 0 .. n {
					ilda := i * lda
					mut tmp := 0.0
					if non_unit {
						tmp = a[ilda + i] * x[i]
					} else {
						tmp = x[i]
					}
					x[i] = tmp + float64.dot_unitary(a[ilda + i + 1..ilda + n], x[i + 1..n])
				}
				return
			}
			mut ix := kx
			for i in 0 .. n {
				ilda := i * lda
				mut tmp := 0.0
				if non_unit {
					tmp = a[ilda + i] * x[ix]
				} else {
					tmp = x[ix]
				}
				x[ix] = tmp + float64.dot_inc(x, a[ilda + i + 1..ilda +
					n], u32(n - i - 1), u32(incx), 1, u32(ix + incx), 0)
				ix += incx
			}
			return
		}
		if incx == 1 {
			for i := n - 1; i >= 0; i-- {
				ilda := i * lda
				mut tmp := 0.0
				if non_unit {
					tmp += a[ilda + i] * x[i]
				} else {
					tmp = x[i]
				}
				x[i] = tmp + float64.dot_unitary(a[ilda..ilda + i], x[..i])
			}
			return
		}
		mut ix := kx + (n - 1) * incx
		for i := n - 1; i >= 0; i-- {
			ilda := i * lda
			mut tmp := 0.0
			if non_unit {
				tmp = a[ilda + i] * x[ix]
			} else {
				tmp = x[ix]
			}
			x[ix] = tmp + float64.dot_inc(x, a[ilda..ilda + i], u32(i), u32(incx), 1, u32(kx), 0)
			ix -= incx
		}
		return
	}
	// Cases where a is transposed.
	if ul == blas_upper {
		if incx == 1 {
			for i := n - 1; i >= 0; i-- {
				ilda := i * lda
				xi := x[i]
				float64.axpy_unitary(xi, a[ilda + i + 1..ilda + n], mut x[i + 1..n])
				if non_unit {
					x[i] *= a[ilda + i]
				}
			}
			return
		}
		mut ix := kx + (n - 1) * incx
		for i := n - 1; i >= 0; i-- {
			ilda := i * lda
			xi := x[ix]
			float64.axpy_inc(xi, a[ilda + i + 1..ilda + n], mut x, u32(n - i - 1), 1,
				u32(incx), 0, u32(kx + (i + 1) * incx))
			if non_unit {
				x[ix] *= a[ilda + i]
			}
			ix -= incx
		}
		return
	}
	if incx == 1 {
		for i in 0 .. n {
			ilda := i * lda
			xi := x[i]
			float64.axpy_unitary(xi, a[ilda..ilda + i], mut x[..i])
			if non_unit {
				x[i] *= a[i * lda + i]
			}
		}
		return
	}
	mut ix := kx
	for i in 0 .. n {
		ilda := i * lda
		xi := x[ix]
		float64.axpy_inc(xi, a[ilda..ilda + i], mut x, u32(i), 1, u32(incx), 0, u32(kx))
		if non_unit {
			x[ix] *= a[ilda + i]
		}
		ix += incx
	}
}

// dtrsv solves one of the systems of equations
//  A * x = b   if trans_a == blas_no_trans
//  Aᵀ * x = b  if trans_a == blas_trans or blas_conj_trans
// where A is an n×n triangular matrix, and x and b are vectors.
//
// At entry to the function, x contains the values of b, and the result is
// stored in-place into x.
//
// No test for singularity or near-singularity is included in this
// routine. Such tests must be performed before calling this routine.
pub fn dtrsv(ul Uplo, trans_a Transpose, d Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if d != blas_non_unit && d != blas_unit {
		panic(bad_diag)
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

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (n - 1) + n {
		panic(short_a)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}

	if n == 1 {
		if d == blas_non_unit {
			x[0] /= a[0]
		}
		return
	}

	mut kx := 0
	if incx < 0 {
		kx = -(n - 1) * incx
	}
	non_unit := d == blas_non_unit
	if trans_a == blas_no_trans {
		if ul == blas_upper {
			if incx == 1 {
				for i := n - 1; i >= 0; i-- {
					mut sum := 0.0
					atmp := a[i * lda + i + 1..i * lda + n]
					for j, v in atmp {
						jv := i + j + 1
						sum += x[jv] * v
					}
					x[i] -= sum
					if non_unit {
						x[i] /= a[i * lda + i]
					}
				}
				return
			}
			mut ix := kx + (n - 1) * incx
			for i := n - 1; i >= 0; i-- {
				mut sum := 0.0
				mut jx := ix + incx
				atmp := a[i * lda + i + 1..i * lda + n]
				for v in atmp {
					sum += x[jx] * v
					jx += incx
				}
				x[ix] -= sum
				if non_unit {
					x[ix] /= a[i * lda + i]
				}
				ix -= incx
			}
			return
		}
		if incx == 1 {
			for i in 0 .. n {
				mut sum := 0.0
				atmp := a[i * lda..i * lda + i]
				for j, v in atmp {
					sum += x[j] * v
				}
				x[i] -= sum
				if non_unit {
					x[i] /= a[i * lda + i]
				}
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			mut jx := kx
			mut sum := 0.0
			atmp := a[i * lda..i * lda + i]
			for v in atmp {
				sum += x[jx] * v
				jx += incx
			}
			x[ix] -= sum
			if non_unit {
				x[ix] /= a[i * lda + i]
			}
			ix += incx
		}
		return
	}
	// Cases where a is transposed.
	if ul == blas_upper {
		if incx == 1 {
			for i in 0 .. n {
				if non_unit {
					x[i] /= a[i * lda + i]
				}
				xi := x[i]
				atmp := a[i * lda + i + 1..i * lda + n]
				for j, v in atmp {
					jv := j + i + 1
					x[jv] -= v * xi
				}
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			if non_unit {
				x[ix] /= a[i * lda + i]
			}
			xi := x[ix]
			mut jx := kx + (i + 1) * incx
			atmp := a[i * lda + i + 1..i * lda + n]
			for v in atmp {
				x[jx] -= v * xi
				jx += incx
			}
			ix += incx
		}
		return
	}
	if incx == 1 {
		for i := n - 1; i >= 0; i-- {
			if non_unit {
				x[i] /= a[i * lda + i]
			}
			xi := x[i]
			atmp := a[i * lda..i * lda + i]
			for j, v in atmp {
				x[j] -= v * xi
			}
		}
		return
	}
	mut ix := kx + (n - 1) * incx
	for i := n - 1; i >= 0; i-- {
		if non_unit {
			x[ix] /= a[i * lda + i]
		}
		xi := x[ix]
		mut jx := kx
		atmp := a[i * lda..i * lda + i]
		for v in atmp {
			x[jx] -= v * xi
			jx += incx
		}
		ix -= incx
	}
}

// dsymv performs the matrix-vector operation
//  y = alpha * A * x + beta * y
// where A is an n×n symmetric matrix, x and y are vectors, and alpha and
// beta are scalars.
pub fn dsymv(ul Uplo, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
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

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (n - 1) + n {
		panic(short_a)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n - 1) * incy) || (incy < 0 && y.len <= (1 - n) * incy) {
		panic(short_y)
	}

	// Quick return if possible.
	if alpha == 0 && beta == 1 {
		return
	}

	// Set up start points
	mut kx := 0
	mut ky := 0
	if incx < 0 {
		kx = -(n - 1) * incx
	}
	if incy < 0 {
		ky = -(n - 1) * incy
	}

	// Form y = beta * y
	if beta != 1 {
		if incy == 1 {
			if beta == 0 {
				for i in 0 .. n {
					y[i] = 0
				}
			} else {
				float64.scal_unitary(beta, mut y[..n])
			}
		} else {
			mut iy := ky
			if beta == 0 {
				for _ in 0 .. n {
					y[iy] = 0
					iy += incy
				}
			} else {
				if incy > 0 {
					float64.scal_inc(beta, mut y, u32(n), u32(incy))
				} else {
					float64.scal_inc(beta, mut y, u32(n), u32(-incy))
				}
			}
		}
	}

	if alpha == 0 {
		return
	}

	if n == 1 {
		y[0] += alpha * a[0] * x[0]
		return
	}

	if ul == blas_upper {
		if incx == 1 {
			mut iy := ky
			for i in 0 .. n {
				xv := x[i] * alpha
				mut sum := x[i] * a[i * lda + i]
				mut jy := ky + (i + 1) * incy
				atmp := a[i * lda + i + 1..i * lda + n]
				for j, v in atmp {
					jp := j + i + 1
					sum += x[jp] * v
					y[jy] += xv * v
					jy += incy
				}
				y[iy] += alpha * sum
				iy += incy
			}
			return
		}
		mut ix := kx
		mut iy := ky
		for i in 0 .. n {
			xv := x[ix] * alpha
			mut sum := x[ix] * a[i * lda + i]
			mut jx := kx + (i + 1) * incx
			mut jy := ky + (i + 1) * incy
			atmp := a[i * lda + i + 1..i * lda + n]
			for v in atmp {
				sum += x[jx] * v
				y[jy] += xv * v
				jx += incx
				jy += incy
			}
			y[iy] += alpha * sum
			ix += incx
			iy += incy
		}
		return
	}
	// Cases where a is lower triangular.
	if incx == 1 {
		mut iy := ky
		for i in 0 .. n {
			mut jy := ky
			xv := alpha * x[i]
			atmp := a[i * lda..i * lda + i]
			mut sum := 0.0
			for j, v in atmp {
				sum += x[j] * v
				y[jy] += xv * v
				jy += incy
			}
			sum += x[i] * a[i * lda + i]
			sum *= alpha
			y[iy] += sum
			iy += incy
		}
		return
	}
	mut ix := kx
	mut iy := ky
	for i in 0 .. n {
		mut jx := kx
		mut jy := ky
		xv := alpha * x[ix]
		atmp := a[i * lda..i * lda + i]
		mut sum := 0.0
		for v in atmp {
			sum += x[jx] * v
			y[jy] += xv * v
			jx += incx
			jy += incy
		}
		sum += x[ix] * a[i * lda + i]
		sum *= alpha
		y[iy] += sum
		ix += incx
		iy += incy
	}
}

// dtbmv performs one of the matrix-vector operations
//  x = A * x   if trans_a == blas_no_trans
//  x = Aᵀ * x  if trans_a == blas_trans or blas_conj_trans
// where A is an n×n triangular band matrix with k+1 diagonals, and x is a vector.
pub fn dtbmv(ul Uplo, trans_a Transpose, d Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if d != blas_non_unit && d != blas_unit {
		panic(bad_diag)
	}
	if n < 0 {
		panic(nlt0)
	}
	if k < 0 {
		panic(klt0)
	}
	if lda < k + 1 {
		panic(bad_ld_a)
	}
	if incx == 0 {
		panic(zero_incx)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (n - 1) + k + 1 {
		panic(short_a)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}

	mut kx := 0
	if incx < 0 {
		kx = -(n - 1) * incx
	}

	nonunit := d != blas_unit

	if trans_a == blas_no_trans {
		if ul == blas_upper {
			if incx == 1 {
				for i in 0 .. n {
					u := util.imin(1 + k, n - i)
					mut sum := 0.0
					mut atmp := a[i * lda..]
					xtmp := x[i..]
					for j := 1; j < u; j++ {
						sum += xtmp[j] * atmp[j]
					}
					if nonunit {
						sum += xtmp[0] * atmp[0]
					} else {
						sum += xtmp[0]
					}
					x[i] = sum
				}
				return
			}
			mut ix := kx
			for i in 0 .. n {
				u := util.imin(1 + k, n - i)
				mut sum := 0.0
				atmp := a[i * lda..]
				mut jx := incx
				for j := 1; j < u; j++ {
					sum += x[ix + jx] * atmp[j]
					jx += incx
				}
				if nonunit {
					sum += x[ix] * atmp[0]
				} else {
					sum += x[ix]
				}
				x[ix] = sum
				ix += incx
			}
			return
		}
		if incx == 1 {
			for i := n - 1; i >= 0; i-- {
				l := util.imax(0, k - i)
				atmp := a[i * lda..]
				mut sum := 0.0
				for j := l; j < k; j++ {
					sum += x[i - k + j] * atmp[j]
				}
				if nonunit {
					sum += x[i] * atmp[k]
				} else {
					sum += x[i]
				}
				x[i] = sum
			}
			return
		}
		mut ix := kx + (n - 1) * incx
		for i := n - 1; i >= 0; i-- {
			l := util.imax(0, k - i)
			atmp := a[i * lda..]
			mut sum := 0.0
			mut jx := l * incx
			for j := l; j < k; j++ {
				sum += x[ix - k * incx + jx] * atmp[j]
				jx += incx
			}
			if nonunit {
				sum += x[ix] * atmp[k]
			} else {
				sum += x[ix]
			}
			x[ix] = sum
			ix -= incx
		}
		return
	}
	if ul == blas_upper {
		if incx == 1 {
			for i := n - 1; i >= 0; i-- {
				mut u := k + 1
				if i < u {
					u = i + 1
				}
				mut sum := 0.0
				for j := 1; j < u; j++ {
					sum += x[i - j] * a[(i - j) * lda + j]
				}
				if nonunit {
					sum += x[i] * a[i * lda]
				} else {
					sum += x[i]
				}
				x[i] = sum
			}
			return
		}
		mut ix := kx + (n - 1) * incx
		for i := n - 1; i >= 0; i-- {
			mut u := k + 1
			if i < u {
				u = i + 1
			}
			mut sum := 0.0
			mut jx := incx
			for j := 1; j < u; j++ {
				sum += x[ix - jx] * a[(i - j) * lda + j]
				jx += incx
			}
			if nonunit {
				sum += x[ix] * a[i * lda]
			} else {
				sum += x[ix]
			}
			x[ix] = sum
			ix -= incx
		}
		return
	}
	if incx == 1 {
		for i in 0 .. n {
			mut u := k
			if i + k >= n {
				u = n - i - 1
			}
			mut sum := 0.0
			for j := 0; j < u; j++ {
				sum += x[i + j + 1] * a[(i + j + 1) * lda + k - j - 1]
			}
			if nonunit {
				sum += x[i] * a[i * lda + k]
			} else {
				sum += x[i]
			}
			x[i] = sum
		}
		return
	}
	mut ix := kx
	for i in 0 .. n {
		mut u := k
		if i + k >= n {
			u = n - i - 1
		}
		mut sum := 0.0
		mut jx := 0
		for j := 0; j < u; j++ {
			sum += x[ix + jx + incx] * a[(i + j + 1) * lda + k - j - 1]
			jx += incx
		}
		if nonunit {
			sum += x[ix] * a[i * lda + k]
		} else {
			sum += x[ix]
		}
		x[ix] = sum
		ix += incx
	}
}

// dtpmv performs one of the matrix-vector operations
//  x = A * x   if trans_a == blas_no_trans
//  x = Aᵀ * x  if trans_a == blas_trans or blas_conj_trans
// where A is an n×n triangular matrix in packed format, and x is a vector.
pub fn dtpmv(ul Uplo, trans_a Transpose, d Diagonal, n int, ap []f64, mut x []f64, incx int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if d != blas_non_unit && d != blas_unit {
		panic(bad_diag)
	}
	if n < 0 {
		panic(nlt0)
	}
	if incx == 0 {
		panic(zero_incx)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if ap.len < n * (n + 1) / 2 {
		panic(short_ap)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}

	mut kx := 0
	if incx < 0 {
		kx = -(n - 1) * incx
	}

	non_unit := d == blas_non_unit
	mut offset := 0 // Offset is the index of (i,i)
	if trans_a == blas_no_trans {
		if ul == blas_upper {
			if incx == 1 {
				for i in 0 .. n {
					mut xi := x[i]
					if non_unit {
						xi *= ap[offset]
					}
					atmp := ap[offset + 1..offset + n - i]
					xtmp := x[i + 1..]
					for j, v in atmp {
						xi += v * xtmp[j]
					}
					x[i] = xi
					offset += n - i
				}
				return
			}
			mut ix := kx
			for i in 0 .. n {
				mut xix := x[ix]
				if non_unit {
					xix *= ap[offset]
				}
				atmp := ap[offset + 1..offset + n - i]
				mut jx := kx + (i + 1) * incx
				for v in atmp {
					xix += v * x[jx]
					jx += incx
				}
				x[ix] = xix
				offset += n - i
				ix += incx
			}
			return
		}
		if incx == 1 {
			offset = n * (n + 1) / 2 - 1
			for i := n - 1; i >= 0; i-- {
				mut xi := x[i]
				if non_unit {
					xi *= ap[offset]
				}
				atmp := ap[offset - i..offset]
				for j, v in atmp {
					xi += v * x[j]
				}
				x[i] = xi
				offset -= i + 1
			}
			return
		}
		mut ix := kx + (n - 1) * incx
		offset = n * (n + 1) / 2 - 1
		for i := n - 1; i >= 0; i-- {
			mut xix := x[ix]
			if non_unit {
				xix *= ap[offset]
			}
			atmp := ap[offset - i..offset]
			mut jx := kx
			for v in atmp {
				xix += v * x[jx]
				jx += incx
			}
			x[ix] = xix
			offset -= i + 1
			ix -= incx
		}
		return
	}
	// Cases where ap is transposed.
	if ul == blas_upper {
		if incx == 1 {
			offset = n * (n + 1) / 2 - 1
			for i := n - 1; i >= 0; i-- {
				xi := x[i]
				atmp := ap[offset + 1..offset + n - i]
				mut xtmp := x[i + 1..]
				for j, v in atmp {
					xtmp[j] += v * xi
				}
				if non_unit {
					x[i] *= ap[offset]
				}
				offset -= n - i + 1
			}
			return
		}
		mut ix := kx + (n - 1) * incx
		offset = n * (n + 1) / 2 - 1
		for i := n - 1; i >= 0; i-- {
			xix := x[ix]
			mut jx := kx + (i + 1) * incx
			atmp := ap[offset + 1..offset + n - i]
			for v in atmp {
				x[jx] += v * xix
				jx += incx
			}
			if non_unit {
				x[ix] *= ap[offset]
			}
			offset -= n - i + 1
			ix -= incx
		}
		return
	}
	if incx == 1 {
		for i in 0 .. n {
			xi := x[i]
			atmp := ap[offset - i..offset]
			for j, v in atmp {
				x[j] += v * xi
			}
			if non_unit {
				x[i] *= ap[offset]
			}
			offset += i + 2
		}
		return
	}
	mut ix := kx
	for i in 0 .. n {
		xix := x[ix]
		mut jx := kx
		atmp := ap[offset - i..offset]
		for v in atmp {
			x[jx] += v * xix
			jx += incx
		}
		if non_unit {
			x[ix] *= ap[offset]
		}
		ix += incx
		offset += i + 2
	}
}

// dtbsv solves one of the systems of equations
//  A * x = b   if trans_a == blas_no_trans
//  Aᵀ * x = b  if trans_a == blas_trans or trans_a == blas_conj_trans
// where A is an n×n triangular band matrix with k+1 diagonals,
// and x and b are vectors.
//
// At entry to the function, x contains the values of b, and the result is
// stored in-place into x.
//
// No test for singularity or near-singularity is included in this
// routine. Such tests must be performed before calling this routine.
pub fn dtbsv(ul Uplo, trans_a Transpose, d Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if d != blas_non_unit && d != blas_unit {
		panic(bad_diag)
	}
	if n < 0 {
		panic(nlt0)
	}
	if k < 0 {
		panic(klt0)
	}
	if lda < k + 1 {
		panic(bad_ld_a)
	}
	if incx == 0 {
		panic(zero_incx)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (n - 1) + k + 1 {
		panic(short_a)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}

	mut kx := 0
	if incx < 0 {
		kx = -(n - 1) * incx
	}
	non_unit := d == blas_non_unit
	// Form x = A^-1 x.
	// Several cases below use subslices for speed improvement.
	// The incx != 1 cases usually do not because incx may be negative.
	if trans_a == blas_no_trans {
		if ul == blas_upper {
			if incx == 1 {
				for i := n - 1; i >= 0; i-- {
					mut bands := k
					if i + bands >= n {
						bands = n - i - 1
					}
					atmp := a[i * lda + 1..]
					xtmp := x[i + 1..i + bands + 1]
					mut sum := 0.0
					for j, v in xtmp {
						sum += v * atmp[j]
					}
					x[i] -= sum
					if non_unit {
						x[i] /= a[i * lda]
					}
				}
				return
			}
			mut ix := kx + (n - 1) * incx
			for i := n - 1; i >= 0; i-- {
				mut max := k + 1
				if i + max > n {
					max = n - i
				}
				atmp := a[i * lda..]
				mut sum := 0.0
				mut jx := 0
				for j := 1; j < max; j++ {
					jx += incx
					sum += x[ix + jx] * atmp[j]
				}
				x[ix] -= sum
				if non_unit {
					x[ix] /= atmp[0]
				}
				ix -= incx
			}
			return
		}
		if incx == 1 {
			for i in 0 .. n {
				mut bands := k
				if i - k < 0 {
					bands = i
				}
				atmp := a[i * lda + k - bands..]
				xtmp := x[i - bands..i]
				mut sum := 0.0
				for j, v in xtmp {
					sum += v * atmp[j]
				}
				x[i] -= sum
				if non_unit {
					x[i] /= atmp[bands]
				}
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			mut bands := k
			if i - k < 0 {
				bands = i
			}
			atmp := a[i * lda + k - bands..]
			mut sum := 0.0
			mut jx := 0
			for j := 0; j < bands; j++ {
				sum += x[ix - bands * incx + jx] * atmp[j]
				jx += incx
			}
			x[ix] -= sum
			if non_unit {
				x[ix] /= atmp[bands]
			}
			ix += incx
		}
		return
	}
	// Cases where a is transposed.
	if ul == blas_upper {
		if incx == 1 {
			for i in 0 .. n {
				mut bands := k
				if i - k < 0 {
					bands = i
				}
				mut sum := 0.0
				for j := 0; j < bands; j++ {
					sum += x[i - bands + j] * a[(i - bands + j) * lda + bands - j]
				}
				x[i] -= sum
				if non_unit {
					x[i] /= a[i * lda]
				}
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			mut bands := k
			if i - k < 0 {
				bands = i
			}
			mut sum := 0.0
			mut jx := 0
			for j := 0; j < bands; j++ {
				sum += x[ix - bands * incx + jx] * a[(i - bands + j) * lda + bands - j]
				jx += incx
			}
			x[ix] -= sum
			if non_unit {
				x[ix] /= a[i * lda]
			}
			ix += incx
		}
		return
	}
	if incx == 1 {
		for i := n - 1; i >= 0; i-- {
			mut bands := k
			if i + bands >= n {
				bands = n - i - 1
			}
			mut sum := 0.0
			xtmp := x[i + 1..i + 1 + bands]
			for j, v in xtmp {
				sum += v * a[(i + j + 1) * lda + k - j - 1]
			}
			x[i] -= sum
			if non_unit {
				x[i] /= a[i * lda + k]
			}
		}
		return
	}
	mut ix := kx + (n - 1) * incx
	for i := n - 1; i >= 0; i-- {
		mut bands := k
		if i + bands >= n {
			bands = n - i - 1
		}
		mut sum := 0.0
		mut jx := 0
		for j := 0; j < bands; j++ {
			sum += x[ix + jx + incx] * a[(i + j + 1) * lda + k - j - 1]
			jx += incx
		}
		x[ix] -= sum
		if non_unit {
			x[ix] /= a[i * lda + k]
		}
		ix -= incx
	}
}

// dsbmv performs the matrix-vector operation
//  y = alpha * A * x + beta * y
// where A is an n×n symmetric band matrix with k super-diagonals, x and y are
// vectors, and alpha and beta are scalars.
pub fn dsbmv(ul Uplo, n int, k int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(nlt0)
	}
	if k < 0 {
		panic(klt0)
	}
	if lda < k + 1 {
		panic(bad_ld_a)
	}
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (n - 1) + k + 1 {
		panic(short_a)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n - 1) * incy) || (incy < 0 && y.len <= (1 - n) * incy) {
		panic(short_y)
	}

	// Quick return if possible.
	if alpha == 0 && beta == 1 {
		return
	}

	// Set up indexes
	len_x := n
	len_y := n
	mut kx := 0
	mut ky := 0
	if incx < 0 {
		kx = -(len_x - 1) * incx
	}
	if incy < 0 {
		ky = -(len_y - 1) * incy
	}

	// Form y = beta * y.
	if beta != 1 {
		if incy == 1 {
			if beta == 0 {
				for i in 0 .. n {
					y[i] = 0
				}
			} else {
				float64.scal_unitary(beta, mut y[..n])
			}
		} else {
			mut iy := ky
			if beta == 0 {
				for _ in 0 .. n {
					y[iy] = 0
					iy += incy
				}
			} else {
				if incy > 0 {
					float64.scal_inc(beta, mut y, u32(n), u32(incy))
				} else {
					float64.scal_inc(beta, mut y, u32(n), u32(-incy))
				}
			}
		}
	}

	if alpha == 0 {
		return
	}

	if ul == blas_upper {
		if incx == 1 {
			mut iy := ky
			for i in 0 .. n {
				atmp := a[i * lda..]
				tmp := alpha * x[i]
				mut sum := tmp * atmp[0]
				u := util.imin(k, n - i - 1)
				mut jy := incy
				for j := 1; j <= u; j++ {
					v := atmp[j]
					sum += alpha * x[i + j] * v
					y[iy + jy] += tmp * v
					jy += incy
				}
				y[iy] += sum
				iy += incy
			}
			return
		}
		mut ix := kx
		mut iy := ky
		for i in 0 .. n {
			atmp := a[i * lda..]
			tmp := alpha * x[ix]
			mut sum := tmp * atmp[0]
			u := util.imin(k, n - i - 1)
			mut jx := incx
			mut jy := incy
			for j := 1; j <= u; j++ {
				v := atmp[j]
				sum += alpha * x[ix + jx] * v
				y[iy + jy] += tmp * v
				jx += incx
				jy += incy
			}
			y[iy] += sum
			ix += incx
			iy += incy
		}
		return
	}

	// Casses where a has bands below the diagonal.
	if incx == 1 {
		mut iy := ky
		for i in 0 .. n {
			l := util.imax(0, k - i)
			tmp := alpha * x[i]
			mut jy := l * incy
			atmp := a[i * lda..]
			for j := l; j < k; j++ {
				v := atmp[j]
				y[iy] += alpha * v * x[i - k + j]
				y[iy - k * incy + jy] += tmp * v
				jy += incy
			}
			y[iy] += tmp * atmp[k]
			iy += incy
		}
		return
	}
	mut ix := kx
	mut iy := ky
	for i in 0 .. n {
		l := util.imax(0, k - i)
		tmp := alpha * x[ix]
		mut jx := l * incx
		mut jy := l * incy
		atmp := a[i * lda..]
		for j := l; j < k; j++ {
			v := atmp[j]
			y[iy] += alpha * v * x[ix - k * incx + jx]
			y[iy - k * incy + jy] += tmp * v
			jx += incx
			jy += incy
		}
		y[iy] += tmp * atmp[k]
		ix += incx
		iy += incy
	}
}

// dsyr performs the symmetric rank-one update
//  A += alpha * x * xᵀ
// where A is an n×n symmetric matrix, and x is a vector.
pub fn dsyr(ul Uplo, n int, alpha f64, x []f64, incx int, mut a []f64, lda int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
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

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}
	if a.len < lda * (n - 1) + n {
		panic(short_a)
	}

	// Quick return if possible.
	if alpha == 0 {
		return
	}

	len_x := n
	mut kx := 0
	if incx < 0 {
		kx = -(len_x - 1) * incx
	}
	if ul == blas_upper {
		if incx == 1 {
			for i in 0 .. n {
				tmp := x[i] * alpha
				if tmp != 0 {
					mut atmp := a[i * lda + i..i * lda + n]
					xtmp := x[i..n]
					for j, v in xtmp {
						atmp[j] += v * tmp
					}
				}
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			tmp := x[ix] * alpha
			if tmp != 0 {
				mut jx := ix
				mut atmp := a[i * lda..]
				for j := i; j < n; j++ {
					atmp[j] += x[jx] * tmp
					jx += incx
				}
			}
			ix += incx
		}
		return
	}
	// Cases where a is lower triangular.
	if incx == 1 {
		for i in 0 .. n {
			tmp := x[i] * alpha
			if tmp != 0 {
				mut atmp := a[i * lda..]
				xtmp := x[..i + 1]
				for j, v in xtmp {
					atmp[j] += tmp * v
				}
			}
		}
		return
	}
	mut ix := kx
	for i in 0 .. n {
		tmp := x[ix] * alpha
		if tmp != 0 {
			mut atmp := a[i * lda..]
			mut jx := kx
			for j := 0; j < i + 1; j++ {
				atmp[j] += tmp * x[jx]
				jx += incx
			}
		}
		ix += incx
	}
}

// dsyr2 performs the symmetric rank-two update
//  A += alpha * x * yᵀ + alpha * y * xᵀ
// where A is an n×n symmetric matrix, x and y are vectors, and alpha is a scalar.
pub fn dsyr2(ul Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
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

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n - 1) * incy) || (incy < 0 && y.len <= (1 - n) * incy) {
		panic(short_y)
	}
	if a.len < lda * (n - 1) + n {
		panic(short_a)
	}

	// Quick return if possible.
	if alpha == 0 {
		return
	}

	mut ky := 0
	mut kx := 0
	if incy < 0 {
		ky = -(n - 1) * incy
	}
	if incx < 0 {
		kx = -(n - 1) * incx
	}
	if ul == blas_upper {
		if incx == 1 && incy == 1 {
			for i in 0 .. n {
				xi := x[i]
				yi := y[i]
				mut atmp := a[i * lda..]
				for j := i; j < n; j++ {
					atmp[j] += alpha * (xi * y[j] + x[j] * yi)
				}
			}
			return
		}
		mut ix := kx
		mut iy := ky
		for i in 0 .. n {
			mut jx := kx + i * incx
			mut jy := ky + i * incy
			xi := x[ix]
			yi := y[iy]
			mut atmp := a[i * lda..]
			for j := i; j < n; j++ {
				atmp[j] += alpha * (xi * y[jy] + x[jx] * yi)
				jx += incx
				jy += incy
			}
			ix += incx
			iy += incy
		}
		return
	}
	if incx == 1 && incy == 1 {
		for i in 0 .. n {
			xi := x[i]
			yi := y[i]
			mut atmp := a[i * lda..]
			for j := 0; j <= i; j++ {
				atmp[j] += alpha * (xi * y[j] + x[j] * yi)
			}
		}
		return
	}
	mut ix := kx
	mut iy := ky
	for i in 0 .. n {
		mut jx := kx
		mut jy := ky
		xi := x[ix]
		yi := y[iy]
		mut atmp := a[i * lda..]
		for j := 0; j <= i; j++ {
			atmp[j] += alpha * (xi * y[jy] + x[jx] * yi)
			jx += incx
			jy += incy
		}
		ix += incx
		iy += incy
	}
}

// dtpsv solves one of the systems of equations
//  A * x = b   if trans_a == blas_no_trans
//  Aᵀ * x = b  if trans_a == blas_trans or blas_conj_trans
// where A is an n×n triangular matrix in packed format, and x and b are vectors.
//
// At entry to the function, x contains the values of b, and the result is
// stored in-place into x.
//
// No test for singularity or near-singularity is included in this
// routine. Such tests must be performed before calling this routine.
pub fn dtpsv(ul Uplo, trans_a Transpose, d Diagonal, n int, ap []f64, mut x []f64, incx int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if trans_a != blas_no_trans && trans_a != blas_trans && trans_a != blas_conj_trans {
		panic(bad_transpose)
	}
	if d != blas_non_unit && d != blas_unit {
		panic(bad_diag)
	}
	if n < 0 {
		panic(nlt0)
	}
	if incx == 0 {
		panic(zero_incx)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if ap.len < n * (n + 1) / 2 {
		panic(short_ap)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}

	mut kx := 0
	if incx < 0 {
		kx = -(n - 1) * incx
	}

	non_unit := d == blas_non_unit
	mut offset := 0 // Offset is the index of (i,i)
	if trans_a == blas_no_trans {
		if ul == blas_upper {
			offset = n * (n + 1) / 2 - 1
			if incx == 1 {
				for i := n - 1; i >= 0; i-- {
					atmp := ap[offset + 1..offset + n - i]
					xtmp := x[i + 1..]
					mut sum := 0.0
					for j, v in atmp {
						sum += v * xtmp[j]
					}
					x[i] -= sum
					if non_unit {
						x[i] /= ap[offset]
					}
					offset -= n - i + 1
				}
				return
			}
			mut ix := kx + (n - 1) * incx
			for i := n - 1; i >= 0; i-- {
				atmp := ap[offset + 1..offset + n - i]
				mut jx := kx + (i + 1) * incx
				mut sum := 0.0
				for v in atmp {
					sum += v * x[jx]
					jx += incx
				}
				x[ix] -= sum
				if non_unit {
					x[ix] /= ap[offset]
				}
				ix -= incx
				offset -= n - i + 1
			}
			return
		}
		if incx == 1 {
			for i in 0 .. n {
				atmp := ap[offset - i..offset]
				mut sum := 0.0
				for j, v in atmp {
					sum += v * x[j]
				}
				x[i] -= sum
				if non_unit {
					x[i] /= ap[offset]
				}
				offset += i + 2
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			mut jx := kx
			atmp := ap[offset - i..offset]
			mut sum := 0.0
			for v in atmp {
				sum += v * x[jx]
				jx += incx
			}
			x[ix] -= sum
			if non_unit {
				x[ix] /= ap[offset]
			}
			ix += incx
			offset += i + 2
		}
		return
	}
	// Cases where ap is transposed.
	if ul == blas_upper {
		if incx == 1 {
			for i in 0 .. n {
				if non_unit {
					x[i] /= ap[offset]
				}
				xi := x[i]
				atmp := ap[offset + 1..offset + n - i]
				mut xtmp := x[i + 1..]
				for j, v in atmp {
					xtmp[j] -= v * xi
				}
				offset += n - i
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			if non_unit {
				x[ix] /= ap[offset]
			}
			xix := x[ix]
			atmp := ap[offset + 1..offset + n - i]
			mut jx := kx + (i + 1) * incx
			for v in atmp {
				x[jx] -= v * xix
				jx += incx
			}
			ix += incx
			offset += n - i
		}
		return
	}
	if incx == 1 {
		offset = n * (n + 1) / 2 - 1
		for i := n - 1; i >= 0; i-- {
			if non_unit {
				x[i] /= ap[offset]
			}
			xi := x[i]
			atmp := ap[offset - i..offset]
			for j, v in atmp {
				x[j] -= v * xi
			}
			offset -= i + 1
		}
		return
	}
	mut ix := kx + (n - 1) * incx
	offset = n * (n + 1) / 2 - 1
	for i := n - 1; i >= 0; i-- {
		if non_unit {
			x[ix] /= ap[offset]
		}
		xix := x[ix]
		atmp := ap[offset - i..offset]
		mut jx := kx
		for v in atmp {
			x[jx] -= v * xix
			jx += incx
		}
		ix -= incx
		offset -= i + 1
	}
}

// dspmv performs the matrix-vector operation
//  y = alpha * A * x + beta * y
// where A is an n×n symmetric matrix in packed format, x and y are vectors,
// and alpha and beta are scalars.
pub fn dspmv(ul Uplo, n int, alpha f64, ap []f64, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(nlt0)
	}
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if ap.len < n * (n + 1) / 2 {
		panic(short_ap)
	}
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n - 1) * incy) || (incy < 0 && y.len <= (1 - n) * incy) {
		panic(short_y)
	}

	// Quick return if possible.
	if alpha == 0 && beta == 1 {
		return
	}

	// Set up start points
	mut kx := 0
	mut ky := 0
	if incx < 0 {
		kx = -(n - 1) * incx
	}
	if incy < 0 {
		ky = -(n - 1) * incy
	}

	// Form y = beta * y.
	if beta != 1 {
		if incy == 1 {
			if beta == 0 {
				for i in 0 .. n {
					y[i] = 0
				}
			} else {
				float64.scal_unitary(beta, mut y[..n])
			}
		} else {
			mut iy := ky
			if beta == 0 {
				for _ in 0 .. n {
					y[iy] = 0
					iy += incy
				}
			} else {
				if incy > 0 {
					float64.scal_inc(beta, mut y, u32(n), u32(incy))
				} else {
					float64.scal_inc(beta, mut y, u32(n), u32(-incy))
				}
			}
		}
	}

	if alpha == 0 {
		return
	}

	if n == 1 {
		y[0] += alpha * ap[0] * x[0]
		return
	}
	mut offset := 0 // Offset is the index of (i,i).
	if ul == blas_upper {
		if incx == 1 {
			mut iy := ky
			for i in 0 .. n {
				xv := x[i] * alpha
				mut sum := ap[offset] * x[i]
				atmp := ap[offset + 1..offset + n - i]
				xtmp := x[i + 1..]
				mut jy := ky + (i + 1) * incy
				for j, v in atmp {
					sum += v * xtmp[j]
					y[jy] += v * xv
					jy += incy
				}
				y[iy] += alpha * sum
				iy += incy
				offset += n - i
			}
			return
		}
		mut ix := kx
		mut iy := ky
		for i in 0 .. n {
			xv := x[ix] * alpha
			mut sum := ap[offset] * x[ix]
			atmp := ap[offset + 1..offset + n - i]
			mut jx := kx + (i + 1) * incx
			mut jy := ky + (i + 1) * incy
			for v in atmp {
				sum += v * x[jx]
				y[jy] += v * xv
				jx += incx
				jy += incy
			}
			y[iy] += alpha * sum
			ix += incx
			iy += incy
			offset += n - i
		}
		return
	}
	if incx == 1 {
		mut iy := ky
		for i in 0 .. n {
			xv := x[i] * alpha
			atmp := ap[offset - i..offset]
			mut jy := ky
			mut sum := 0.0
			for j, v in atmp {
				sum += v * x[j]
				y[jy] += v * xv
				jy += incy
			}
			sum += ap[offset] * x[i]
			y[iy] += alpha * sum
			iy += incy
			offset += i + 2
		}
		return
	}
	mut ix := kx
	mut iy := ky
	for i in 0 .. n {
		xv := x[ix] * alpha
		atmp := ap[offset - i..offset]
		mut jx := kx
		mut jy := ky
		mut sum := 0.0
		for v in atmp {
			sum += v * x[jx]
			y[jy] += v * xv
			jx += incx
			jy += incy
		}

		sum += ap[offset] * x[ix]
		y[iy] += alpha * sum
		ix += incx
		iy += incy
		offset += i + 2
	}
}

// dspr performs the symmetric rank-one operation
//  A += alpha * x * xᵀ
// where A is an n×n symmetric matrix in packed format, x is a vector, and
// alpha is a scalar.
pub fn dspr(ul Uplo, n int, alpha f64, x []f64, incx int, mut ap []f64) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(nlt0)
	}
	if incx == 0 {
		panic(zero_incx)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}
	if ap.len < n * (n + 1) / 2 {
		panic(short_ap)
	}

	// Quick return if possible.
	if alpha == 0 {
		return
	}

	len_x := n
	mut kx := 0
	if incx < 0 {
		kx = -(len_x - 1) * incx
	}
	mut offset := 0 // Offset is the index of (i,i).
	if ul == blas_upper {
		if incx == 1 {
			for i in 0 .. n {
				mut atmp := ap[offset..]
				xv := alpha * x[i]
				xtmp := x[i..n]
				for j, v in xtmp {
					atmp[j] += xv * v
				}
				offset += n - i
			}
			return
		}
		mut ix := kx
		for i in 0 .. n {
			mut jx := kx + i * incx
			mut atmp := ap[offset..]
			xv := alpha * x[ix]
			for j := 0; j < n - i; j++ {
				atmp[j] += xv * x[jx]
				jx += incx
			}
			ix += incx
			offset += n - i
		}
		return
	}
	if incx == 1 {
		for i in 0 .. n {
			mut atmp := ap[offset - i..]
			xv := alpha * x[i]
			xtmp := x[..i + 1]
			for j, v in xtmp {
				atmp[j] += xv * v
			}
			offset += i + 2
		}
		return
	}
	mut ix := kx
	for i in 0 .. n {
		mut jx := kx
		mut atmp := ap[offset - i..]
		xv := alpha * x[ix]
		for j := 0; j <= i; j++ {
			atmp[j] += xv * x[jx]
			jx += incx
		}
		ix += incx
		offset += i + 2
	}
}

// dspr2 performs the symmetric rank-2 update
//  A += alpha * x * yᵀ + alpha * y * xᵀ
// where A is an n×n symmetric matrix in packed format, x and y are vectors,
// and alpha is a scalar.
pub fn dspr2(ul Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut ap []f64) {
	if ul != blas_lower && ul != blas_upper {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(nlt0)
	}
	if incx == 0 {
		panic(zero_incx)
	}
	if incy == 0 {
		panic(zero_incy)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if (incx > 0 && x.len <= (n - 1) * incx) || (incx < 0 && x.len <= (1 - n) * incx) {
		panic(short_x)
	}
	if (incy > 0 && y.len <= (n - 1) * incy) || (incy < 0 && y.len <= (1 - n) * incy) {
		panic(short_y)
	}
	if ap.len < n * (n + 1) / 2 {
		panic(short_ap)
	}

	// Quick return if possible.
	if alpha == 0 {
		return
	}

	mut ky := 0
	mut kx := 0
	if incy < 0 {
		ky = -(n - 1) * incy
	}
	if incx < 0 {
		kx = -(n - 1) * incx
	}
	mut offset := 0 // Offset is the index of (i,i).
	if ul == blas_upper {
		if incx == 1 && incy == 1 {
			for i in 0 .. n {
				mut atmp := ap[offset..]
				xi := x[i]
				yi := y[i]
				xtmp := x[i..n]
				ytmp := y[i..n]
				for j, v in xtmp {
					atmp[j] += alpha * (xi * ytmp[j] + v * yi)
				}
				offset += n - i
			}
			return
		}
		mut ix := kx
		mut iy := ky
		for i in 0 .. n {
			mut jx := kx + i * incx
			mut jy := ky + i * incy
			mut atmp := ap[offset..]
			xi := x[ix]
			yi := y[iy]
			for j := 0; j < n - i; j++ {
				atmp[j] += alpha * (xi * y[jy] + x[jx] * yi)
				jx += incx
				jy += incy
			}
			ix += incx
			iy += incy
			offset += n - i
		}
		return
	}
	if incx == 1 && incy == 1 {
		for i in 0 .. n {
			mut atmp := ap[offset - i..]
			xi := x[i]
			yi := y[i]
			xtmp := x[..i + 1]
			for j, v in xtmp {
				atmp[j] += alpha * (xi * y[j] + v * yi)
			}
			offset += i + 2
		}
		return
	}
	mut ix := kx
	mut iy := ky
	for i in 0 .. n {
		mut jx := kx
		mut jy := ky
		mut atmp := ap[offset - i..]
		for j := 0; j <= i; j++ {
			atmp[j] += alpha * (x[ix] * y[jy] + x[jx] * y[iy])
			jx += incx
			jy += incy
		}
		ix += incx
		iy += incy
		offset += i + 2
	}
}
