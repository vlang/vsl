module lapack64

import math
import vsl.blas

pub fn dlatrd(uplo blas.Uplo, n int, nb int, mut a []f64, lda int, mut e []f64, mut tau []f64, mut w []f64, ldw int) {
	if uplo != .upper && uplo != .lower {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if nb < 0 {
		panic(nb_lt0)
	}
	if nb > n {
		panic(nb_gtn)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if ldw < math.max(1, nb) {
		panic(bad_ld_w)
	}

	if n == 0 {
		return
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}
	if w.len < (n - 1) * ldw + nb {
		panic(short_w)
	}
	if e.len < n - 1 {
		panic(short_e)
	}
	if tau.len < n - 1 {
		panic(short_tau)
	}

	if uplo == .upper {
		for i := n - 1; i >= n - nb; i-- {
			iw := i - n + nb
			if i < n - 1 {
				// Update A(0:i, i).
				blas.dgemv(.no_trans, i + 1, n - i - 1, -1, a[i + 1..], lda, w[i * ldw + iw + 1..],
					1, 1, mut a[i..], lda)
				blas.dgemv(.no_trans, i + 1, n - i - 1, -1, w[iw + 1..], ldw, a[i * lda + i + 1..],
					1, 1, mut a[i..], lda)
			}
			if i > 0 {
				// Generate elementary reflector H_i to annihilate A(0:i-2,i).
				e[i - 1], tau[i - 1] = dlarfg(i, a[(i - 1) * lda + i], mut a[i..], lda)
				a[(i - 1) * lda + i] = 1

				// Compute W(0:i-1, i).
				blas.dsymv(.upper, i, 1, a, lda, a[i..], lda, 0, mut w[iw..], ldw)
				if i < n - 1 {
					blas.dgemv(.trans, i, n - i - 1, 1, w[iw + 1..], ldw, a[i..], lda,
						0, mut w[(i + 1) * ldw + iw..], ldw)
					blas.dgemv(.no_trans, i, n - i - 1, -1, a[i + 1..], lda, w[(i + 1) * ldw + iw..],
						ldw, 1, mut w[iw..], ldw)
					blas.dgemv(.trans, i, n - i - 1, 1, a[i + 1..], lda, a[i..], lda,
						0, mut w[(i + 1) * ldw + iw..], ldw)
					blas.dgemv(.no_trans, i, n - i - 1, -1, w[iw + 1..], ldw, w[(i + 1) * ldw + iw..],
						ldw, 1, mut w[iw..], ldw)
				}
				blas.dscal(i, tau[i - 1], mut w[iw..], ldw)
				alpha := -0.5 * tau[i - 1] * blas.ddot(i, w[iw..], ldw, a[i..], lda)
				blas.daxpy(i, alpha, a[i..], lda, mut w[iw..], ldw)
			}
		}
	} else {
		// Reduce first nb columns of lower triangle.
		for i := 0; i < nb; i++ {
			// Update A(i:n, i)
			blas.dgemv(.no_trans, n - i, i, -1, a[i * lda..], lda, w[i * ldw..], 1, 1, mut
				a[i * lda + i..], lda)
			blas.dgemv(.no_trans, n - i, i, -1, w[i * ldw..], ldw, a[i * lda..], 1, 1, mut
				a[i * lda + i..], lda)
			if i < n - 1 {
				// Generate elementary reflector H_i to annihilate A(i+2:n,i).
				e[i], tau[i] = dlarfg(n - i - 1, a[(i + 1) * lda + i], mut a[math.min(i +
					2, n - 1) * lda + i..], lda)
				a[(i + 1) * lda + i] = 1

				// Compute W(i+1:n,i).
				blas.dsymv(.lower, n - i - 1, 1, a[(i + 1) * lda + i + 1..], lda, a[(i + 1) * lda +
					i..], lda, 0, mut w[(i + 1) * ldw + i..], ldw)
				blas.dgemv(.trans, n - i - 1, i, 1, w[(i + 1) * ldw..], ldw, a[(i + 1) * lda + i..],
					lda, 0, mut w[i..], ldw)
				blas.dgemv(.no_trans, n - i - 1, i, -1, a[(i + 1) * lda..], lda, w[i..],
					ldw, 1, mut w[(i + 1) * ldw + i..], ldw)
				blas.dgemv(.trans, n - i - 1, i, 1, a[(i + 1) * lda..], lda, a[(i + 1) * lda + i..],
					lda, 0, mut w[i..], ldw)
				blas.dgemv(.no_trans, n - i - 1, i, -1, w[(i + 1) * ldw..], ldw, w[i..],
					ldw, 1, mut w[(i + 1) * ldw + i..], ldw)
				blas.dscal(n - i - 1, tau[i], mut w[(i + 1) * ldw + i..], ldw)
				alpha := -0.5 * tau[i] * blas.ddot(n - i - 1, w[(i + 1) * ldw + i..],
					ldw, a[(i + 1) * lda + i..], lda)
				blas.daxpy(n - i - 1, alpha, a[(i + 1) * lda + i..], lda, mut w[(i + 1) * ldw + i..],
					ldw)
			}
		}
	}
}
