module blas64

// Column-major minimal BLAS subset used by lapack64

pub fn cm_ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	if n <= 0 {
		return 0
	}
	mut sum := 0.0
	mut ix := 0
	mut iy := 0
	for _ in 0 .. n {
		sum += x[ix] * y[iy]
		ix += incx
		iy += incy
	}
	return sum
}

pub fn cm_dscal(n int, alpha f64, mut x []f64, incx int) {
	if n <= 0 {
		return
	}
	mut ix := 0
	for _ in 0 .. n {
		x[ix] *= alpha
		ix += incx
	}
}

pub fn cm_daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	if n <= 0 || alpha == 0 {
		return
	}
	mut ix := 0
	mut iy := 0
	for _ in 0 .. n {
		y[iy] += alpha * x[ix]
		ix += incx
		iy += incy
	}
}

pub fn cm_dgemv(trans Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if m == 0 || n == 0 {
		return
	}
	if beta != 1 {
		len := if trans == .no_trans { m } else { n }
		mut iy := 0
		for _ in 0 .. len {
			y[iy] *= beta
			iy += incy
		}
	}
	match trans {
		.no_trans {
			for j in 0 .. n {
				mut temp := alpha * x[j * incx]
				for i in 0 .. m {
					y[i * incy] += temp * a[i + j * lda]
				}
			}
		}
		else {
			for j in 0 .. m {
				mut temp := 0.0
				for i in 0 .. n {
					temp += a[j + i * lda] * x[i * incx]
				}
				y[j * incy] += alpha * temp
			}
		}
	}
}

pub fn cm_dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	if m == 0 || n == 0 || ((alpha == 0 || k == 0) && beta == 1) {
		return
	}
	// Scale C by beta
	if beta != 1 {
		for j in 0 .. n {
			for i in 0 .. m {
				c[i + j * ldc] *= beta
			}
		}
	}
	for j in 0 .. n {
		for l in 0 .. k {
			mut bval := b[l + j * ldb]
			if trans_b != .no_trans {
				bval = b[j + l * ldb]
			}
			if bval == 0 {
				continue
			}
			mut aval_idx := if trans_a == .no_trans { l * lda } else { l }
			for i in 0 .. m {
				mut aval := if trans_a == .no_trans { a[i + aval_idx] } else { a[aval_idx + i * lda] }
				c[i + j * ldc] += alpha * aval * bval
			}
		}
	}
}

pub fn cm_dsyrk(uplo Uplo, trans Transpose, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	if n == 0 {
		return
	}
	// Scale C triangle
	if uplo == .upper {
		for j in 0 .. n {
			for i in 0 .. j + 1 {
				c[i + j * ldc] *= beta
			}
		}
	} else {
		for j in 0 .. n {
			for i in j .. n {
				c[i + j * ldc] *= beta
			}
		}
	}
	if alpha == 0 || k == 0 {
		return
	}
	if trans == .no_trans {
		// C = alpha*A*Aᵀ + beta*C, A is n x k
		if uplo == .upper {
			for j in 0 .. n {
				for i in 0 .. j + 1 {
					mut sum := 0.0
					for l in 0 .. k {
						sum += a[i + l * lda] * a[j + l * lda]
					}
					c[i + j * ldc] += alpha * sum
				}
			}
		} else {
			for j in 0 .. n {
				for i in j .. n {
					mut sum := 0.0
					for l in 0 .. k {
						sum += a[i + l * lda] * a[j + l * lda]
					}
					c[i + j * ldc] += alpha * sum
				}
			}
		}
		return
	}
	// transposed: C = alpha*Aᵀ*A + beta*C, A is k x n
	if uplo == .upper {
		for j in 0 .. n {
			for i in 0 .. j + 1 {
				mut sum := 0.0
				for l in 0 .. k {
					sum += a[l + i * lda] * a[l + j * lda]
				}
				c[i + j * ldc] += alpha * sum
			}
		}
	} else {
		for j in 0 .. n {
			for i in j .. n {
				mut sum := 0.0
				for l in 0 .. k {
					sum += a[l + i * lda] * a[l + j * lda]
				}
				c[i + j * ldc] += alpha * sum
			}
		}
	}
}

pub fn cm_dtrsm(side Side, uplo Uplo, trans_a Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	if m == 0 || n == 0 {
		return
	}
	non_unit := diag == .non_unit
	if alpha != 1 {
		for j in 0 .. n {
			for i in 0 .. m {
				b[i + j * ldb] *= alpha
			}
		}
	}
	if side == .left {
		if trans_a == .no_trans {
			if uplo == .upper {
				for j in 0 .. n {
					for ii := m - 1; ii >= 0; ii-- {
						if non_unit {
							b[ii + j * ldb] /= a[ii + ii * lda]
						}
						mut tmp := b[ii + j * ldb]
						for k in 0 .. ii {
							b[k + j * ldb] -= tmp * a[k + ii * lda]
						}
					}
				}
			} else {
				for j in 0 .. n {
					for ii in 0 .. m {
						if non_unit {
							b[ii + j * ldb] /= a[ii + ii * lda]
						}
						mut tmp := b[ii + j * ldb]
						for k in ii + 1 .. m {
							b[k + j * ldb] -= tmp * a[k + ii * lda]
						}
					}
				}
			}
		} else {
			if uplo == .upper {
				for j in 0 .. n {
					for ii in 0 .. m {
						mut tmp := b[ii + j * ldb]
						for k in 0 .. ii {
							tmp -= a[ii + k * lda] * b[k + j * ldb]
						}
						if non_unit {
							tmp /= a[ii + ii * lda]
						}
						b[ii + j * ldb] = tmp
					}
				}
			} else {
				for j in 0 .. n {
					for ii := m - 1; ii >= 0; ii-- {
						mut tmp := b[ii + j * ldb]
						for k in ii + 1 .. m {
							tmp -= a[ii + k * lda] * b[k + j * ldb]
						}
						if non_unit {
							tmp /= a[ii + ii * lda]
						}
						b[ii + j * ldb] = tmp
					}
				}
			}
		}
		return
	}

	// side == right
	if trans_a == .no_trans {
		if uplo == .upper {
			for j in 0 .. n {
				if non_unit {
					diagv := a[j + j * lda]
					for i in 0 .. m {
						b[i + j * ldb] /= diagv
					}
				}
				for k in 0 .. j {
					mut a_val := a[k + j * lda]
					if a_val == 0 {
						continue
					}
					for i in 0 .. m {
						b[i + j * ldb] -= a_val * b[i + k * ldb]
					}
				}
			}
		} else {
			for j := n - 1; j >= 0; j-- {
				if non_unit {
					diagv := a[j + j * lda]
					for i in 0 .. m {
						b[i + j * ldb] /= diagv
					}
				}
				for k := j + 1; k < n; k++ {
					mut a_val := a[k + j * lda]
					if a_val == 0 {
						continue
					}
					for i in 0 .. m {
						b[i + j * ldb] -= a_val * b[i + k * ldb]
					}
				}
			}
		}
		return
	}

	// side == right, transposed
	if uplo == .upper {
		for j := n - 1; j >= 0; j-- {
			for i in 0 .. m {
				mut tmp := b[i + j * ldb]
				for k in j + 1 .. n {
					tmp -= b[i + k * ldb] * a[j + k * lda]
				}
				if non_unit {
					tmp /= a[j + j * lda]
				}
				b[i + j * ldb] = tmp
			}
		}
	} else {
		for j in 0 .. n {
			for i in 0 .. m {
				mut tmp := b[i + j * ldb]
				for k in 0 .. j {
					tmp -= b[i + k * ldb] * a[j + k * lda]
				}
				if non_unit {
					tmp /= a[j + j * lda]
				}
				b[i + j * ldb] = tmp
			}
		}
	}
}

