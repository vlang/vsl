module lapack64

import vsl.blas
import math

// dlaset sets the off-diagonal elements of A to alpha, and the diagonal
// elements to beta. If uplo == blas.upper, only the elements in the upper
// triangular part are set. If uplo == blas.lower, only the elements in the
// lower triangular part are set. If uplo is otherwise, all of the elements of A
// are set.
//
// dlaset is an internal routine. It is exported for testing purposes.
pub fn dlaset(uplo blas.Uplo, m int, n int, alpha f64, beta f64, mut a []f64, lda int) {
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	minmn := math.min(m, n)
	if minmn == 0 {
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}

	match uplo {
		.upper {
			for i in 0 .. m {
				for j in i + 1 .. n {
					a[i * lda + j] = alpha
				}
			}
		}
		.lower {
			for i in 0 .. m {
				for j in 0 .. math.min(i, n) {
					a[i * lda + j] = alpha
				}
			}
		}
		else {
			for i in 0 .. m {
				for j in 0 .. n {
					a[i * lda + j] = alpha
				}
			}
		}
	}
	for i in 0 .. minmn {
		a[i * lda + i] = beta
	}
}
