module lapack64

import math
import vsl.blas

// dpotf2 computes the Cholesky decomposition of the symmetric positive definite
// matrix a. If ul == .upper, then a is stored as an upper-triangular matrix,
// and a = Uᵀ U is stored in place into a. If ul == .lower, then a = L Lᵀ
// is computed and stored in-place into a. If a is not positive definite, false
// is returned. This is the unblocked version of the algorithm.
//
// dpotf2 is an internal routine. It is exported for testing purposes.
pub fn dpotf2(ul blas.Uplo, n int, mut a []f64, lda int) bool {
	if ul != .upper && ul != .lower {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	// Quick return if possible.
	if n == 0 {
		return true
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}

	if ul == .upper {
		for j := 0; j < n; j++ {
			mut ajj := a[j * lda + j]
			if j != 0 {
				ajj -= blas.ddot(j, a[j..], lda, a[j..], lda)
			}
			if ajj <= 0 || math.is_nan(ajj) {
				a[j * lda + j] = ajj
				return false
			}
			ajj = math.sqrt(ajj)
			a[j * lda + j] = ajj
			if j < n - 1 {
				blas.dgemv(.trans, j, n - j - 1, -1, a[j + 1..], lda, a[j..], lda, 1, mut
					a[j * lda + j + 1..], 1)
				blas.dscal(n - j - 1, 1 / ajj, mut a[j * lda + j + 1..], 1)
			}
		}
		return true
	}
	for j := 0; j < n; j++ {
		mut ajj := a[j * lda + j]
		if j != 0 {
			ajj -= blas.ddot(j, a[j * lda..], 1, a[j * lda..], 1)
		}
		if ajj <= 0 || math.is_nan(ajj) {
			a[j * lda + j] = ajj
			return false
		}
		ajj = math.sqrt(ajj)
		a[j * lda + j] = ajj
		if j < n - 1 {
			blas.dgemv(.no_trans, n - j - 1, j, -1, a[(j + 1) * lda..], lda, a[j * lda..],
				1, 1, mut a[(j + 1) * lda + j..], lda)
			blas.dscal(n - j - 1, 1 / ajj, mut a[(j + 1) * lda + j..], lda)
		}
	}
	return true
}
