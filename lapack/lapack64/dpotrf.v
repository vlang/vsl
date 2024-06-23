module lapack64

import math
import vsl.blas

pub fn dpotrf(ul blas.Uplo, n int, mut a []f64, lda int) bool {
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

	nb := ilaenv(1, 'DPOTRF', ul.str(), n, -1, -1, -1)
	if nb <= 1 || n <= nb {
		return dpotf2(ul, n, mut a, lda)
	}

	if ul == .upper {
		for j := 0; j < n; j += nb {
			jb := math.min(nb, n - j)
			blas.dsyrk(.upper, .trans, jb, j, -1, a[j..], lda, 1, mut a[j * lda + j..],
				lda)
			ok := dpotf2(.upper, jb, mut a[j * lda + j..], lda)
			if !ok {
				return false
			}
			if j + jb < n {
				blas.dgemm(.trans, .no_trans, jb, n - j - jb, j, -1, a[j..], lda, a[j + jb..],
					lda, 1, mut a[j * lda + j + jb..], lda)
				blas.dtrsm(.left, .upper, .trans, .non_unit, jb, n - j - jb, 1, a[j * lda + j..],
					lda, mut a[j * lda + j + jb..], lda)
			}
		}
		return true
	}

	for j := 0; j < n; j += nb {
		jb := math.min(nb, n - j)
		blas.dsyrk(.lower, .no_trans, jb, j, -1, a[j * lda..], lda, 1, mut a[j * lda + j..],
			lda)
		ok := dpotf2(.lower, jb, mut a[j * lda + j..], lda)
		if !ok {
			return false
		}
		if j + jb < n {
			blas.dgemm(.no_trans, .trans, n - j - jb, jb, j, -1, a[(j + jb) * lda..],
				lda, a[j * lda..], lda, 1, mut a[(j + jb) * lda + j..], lda)
			blas.dtrsm(.right, .lower, .trans, .non_unit, n - j - jb, jb, 1, a[j * lda + j..],
				lda, mut a[(j + jb) * lda + j..], lda)
		}
	}
	return true
}
