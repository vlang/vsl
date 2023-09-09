module vblas

import vsl.float.float64
import math

// dsyrk performs one of the symmetric rank-k operations
//  C = alpha * A * Aᵀ + beta * C  if trans_a == .no_trans
//  C = alpha * Aᵀ * A + beta * C  if trans_a == .trans or trans_a == .conj_trans
// where A is an n×k or k×n matrix, C is an n×n symmetric matrix, and alpha and
// beta are scalars.
pub fn dsyrk(ul Uplo, trans_a Transpose, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
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
				mut ctmp := unsafe { c[i * ldc + i..i * ldc + n] }
				atmp := a[i * lda..i * lda + k]
				if beta == 0 {
					for jc in 0 .. ctmp.len {
						j := jc + i
						ctmp[int(jc)] = alpha * float64.dot_unitary(atmp, a[j * lda..j * lda + k])
					}
				} else {
					for jc, vc in ctmp {
						j := jc + i
						ctmp[int(jc)] = vc * beta +
							alpha * float64.dot_unitary(atmp, a[j * lda..j * lda + k])
					}
				}
			}
			return
		}
		for i in 0 .. n {
			mut ctmp := unsafe { c[i * ldc..i * ldc + i + 1] }
			atmp := a[i * lda..i * lda + k]
			if beta == 0 {
				for j in 0 .. ctmp.len {
					ctmp[j] = alpha * float64.dot_unitary(a[j * lda..j * lda + k], atmp)
				}
			} else {
				for j, vc in ctmp {
					ctmp[j] = vc * beta + alpha * float64.dot_unitary(a[j * lda..j * lda + k], atmp)
				}
			}
		}
		return
	}
	// Cases where a is transposed.
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
			for l := 0; l < k; l++ {
				tmp := alpha * a[l * lda + i]
				if tmp != 0 {
					float64.axpy_unitary(tmp, a[l * lda + i..l * lda + n], mut ctmp)
				}
			}
		}
		return
	}
	for i in 0 .. n {
		mut ctmp := unsafe { c[i * ldc..i * ldc + i + 1] }
		if beta != 1 {
			for j in 0 .. ctmp.len {
				ctmp[j] *= beta
			}
		}
		for l := 0; l < k; l++ {
			tmp := alpha * a[l * lda + i]
			if tmp != 0 {
				float64.axpy_unitary(tmp, a[l * lda..l * lda + i + 1], mut ctmp)
			}
		}
	}
}
