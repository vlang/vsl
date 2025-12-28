module lapack64

import math
import vsl.blas

// dlacpy copies the elements of A specified by uplo into B. Uplo can specify
// a triangular portion with blas.Uplo.upper or blas.Uplo.lower, or can specify all of the
// elements with blas.Uplo.all.
//
// dlacpy is an internal routine. It is exported for testing purposes.
pub fn dlacpy(uplo blas.Uplo, m int, n int, a []f64, lda int, mut b []f64, ldb int) {
	if uplo != .upper && uplo != .lower && uplo != .all {
		panic(bad_uplo)
	}
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if ldb < math.max(1, n) {
		panic(bad_ld_b)
	}

	if m == 0 || n == 0 {
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}
	if b.len < (m - 1) * ldb + n {
		panic(short_b)
	}

	match uplo {
		.upper {
			for i in 0 .. m {
				for j in i .. n {
					b[i * ldb + j] = a[i * lda + j]
				}
			}
		}
		.lower {
			for i in 0 .. m {
				for j in 0 .. math.min(i + 1, n) {
					b[i * ldb + j] = a[i * lda + j]
				}
			}
		}
		.all {
			for i in 0 .. m {
				for j in 0 .. n {
					b[i * ldb + j] = a[i * lda + j]
				}
			}
		}
	}
}
