module blas64

import math

// dsyr2k performs one of the symmetric rank 2k operations
//  C = alpha * A * Bᵀ + alpha * B * Aᵀ + beta * C  if trans_a == .no_trans
//  C = alpha * Aᵀ * B + alpha * Bᵀ * A + beta * C  if trans_a == .trans or .conj_trans
// where A and B are n×k or k×n matrices, C is an n×n symmetric matrix, and
// alpha and beta are scalars.
pub fn dsyr2k(ul Uplo, trans_a Transpose, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	if ul != .lower && ul != .upper {
		panic(bad_uplo)
	}
	if trans_a != .trans && trans_a != .no_trans && trans_a != .conj_trans {
		panic(bad_transpose)
	}
	if n < 0 {
		panic(nlt0)
	}
	if k < 0 {
		panic(klt0)
	}
	mut row := k
	mut col := n
	if trans_a == .no_trans {
		row = n
		col = k
	}
	if lda < math.max(1, col) {
		panic(bad_ld_a)
	}
	if ldb < math.max(1, col) {
		panic(bad_ld_b)
	}
	if ldc < math.max(1, n) {
		panic(bad_ld_c)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (row - 1) + col {
		panic(short_a)
	}
	if b.len < ldb * (row - 1) + col {
		panic(short_b)
	}
	if c.len < ldc * (n - 1) + n {
		panic(short_c)
	}

	if alpha == 0 {
		if beta == 0 {
			if ul == .upper {
				for i in 0 .. n {
					mut ctmp := unsafe { c[i * ldc + i..i * ldc + n] }
					for j in 0 .. ctmp.len {
						ctmp[j] = 0
					}
				}
				return
			}
			for i in 0 .. n {
				mut ctmp := unsafe { c[i * ldc..i * ldc + i + 1] }
				for j in 0 .. ctmp.len {
					ctmp[j] = 0
				}
			}
			return
		}
		if ul == .upper {
			for i in 0 .. n {
				mut ctmp := unsafe { c[i * ldc + i..i * ldc + n] }
				for j in 0 .. ctmp.len {
					ctmp[j] *= beta
				}
			}
			return
		}
		for i in 0 .. n {
			mut ctmp := unsafe { c[i * ldc..i * ldc + i + 1] }
			for j in 0 .. ctmp.len {
				ctmp[j] *= beta
			}
		}
		return
	}
	if trans_a == .no_trans {
		if ul == .upper {
			for i in 0 .. n {
				atmp := a[i * lda..i * lda + k]
				btmp := b[i * ldb..i * ldb + k]
				mut ctmp := unsafe { c[i * ldc + i..i * ldc + n] }
				if beta == 0 {
					for jc in 0 .. ctmp.len {
						j := i + jc
						binner := b[j * ldb..j * ldb + k]
						mut tmp1 := 0.0
						mut tmp2 := 0.0
						ajump := a[j * lda..j * lda + k]
						for l, v in ajump {
							tmp1 += v * btmp[l]
						}
						for l, v in atmp {
							tmp2 += v * binner[l]
						}
						ctmp[jc] = alpha * (tmp1 + tmp2)
					}
				} else {
					for jc in 0 .. ctmp.len {
						j := i + jc
						binner := b[j * ldb..j * ldb + k]
						mut tmp1 := 0.0
						mut tmp2 := 0.0
						ajump := a[j * lda..j * lda + k]
						for l, v in ajump {
							tmp1 += v * btmp[l]
						}
						for l, v in atmp {
							tmp2 += v * binner[l]
						}
						ctmp[jc] *= beta
						ctmp[jc] += alpha * (tmp1 + tmp2)
					}
				}
			}
			return
		}
		for i in 0 .. n {
			atmp := a[i * lda..i * lda + k]
			btmp := b[i * ldb..i * ldb + k]
			mut ctmp := unsafe { c[i * ldc..i * ldc + i + 1] }
			if beta == 0 {
				for j in 0 .. ctmp.len {
					binner := b[j * ldb..j * ldb + k]
					mut tmp1 := 0.0
					mut tmp2 := 0.0
					ajump := a[j * lda..j * lda + k]
					for l, v in ajump {
						tmp1 += v * btmp[l]
					}
					for l, v in atmp {
						tmp2 += v * binner[l]
					}
					ctmp[j] = alpha * (tmp1 + tmp2)
				}
			} else {
				for j in 0 .. ctmp.len {
					binner := b[j * ldb..j * ldb + k]
					mut tmp1 := 0.0
					mut tmp2 := 0.0
					ajump := a[j * lda..j * lda + k]
					for l, v in ajump {
						tmp1 += v * btmp[l]
					}
					for l, v in atmp {
						tmp2 += v * binner[l]
					}
					ctmp[j] *= beta
					ctmp[j] += alpha * (tmp1 + tmp2)
				}
			}
		}
		return
	}
	if ul == .upper {
		for i in 0 .. n {
			mut ctmp := unsafe { c[i * ldc + i..i * ldc + n] }
			if beta == 0 {
				for j in 0 .. ctmp.len {
					ctmp[j] = 0
				}
			} else if beta != 1 {
				for j in 0 .. ctmp.len {
					ctmp[j] *= beta
				}
			}
			for l in 0 .. k {
				tmp1 := alpha * b[l * ldb + i]
				tmp2 := alpha * a[l * lda + i]
				btmp := b[l * ldb + i..l * ldb + n]
				if tmp1 != 0 || tmp2 != 0 {
					atmp := a[l * lda + i..l * lda + n]
					for j, v in atmp {
						ctmp[j] += v * tmp1 + btmp[j] * tmp2
					}
				}
			}
		}
		return
	}
	for i in 0 .. n {
		mut ctmp := unsafe { c[i * ldc..i * ldc + i + 1] }
		if beta == 0 {
			for j in 0 .. ctmp.len {
				ctmp[j] = 0
			}
		} else if beta != 1 {
			for j in 0 .. ctmp.len {
				ctmp[j] *= beta
			}
		}
		for l in 0 .. k {
			tmp1 := alpha * b[l * ldb + i]
			tmp2 := alpha * a[l * lda + i]
			btmp := b[l * ldb..l * ldb + i + 1]
			if tmp1 != 0 || tmp2 != 0 {
				atmp := a[l * lda..l * lda + i + 1]
				for j, v in atmp {
					ctmp[j] += v * tmp1 + btmp[j] * tmp2
				}
			}
		}
	}
}
