module lapack64

import math
import vsl.blas

// dtrti2 computes the inverse of a triangular matrix, storing the result in place
// into a. This is the BLAS level 2 version of the algorithm.
//
// dtrti2 is an internal routine. It is exported for testing purposes.
pub fn dtrti2(uplo blas.Uplo, diag blas.Diagonal, n int, mut a []f64, lda int) {
	if uplo != .upper && uplo != .lower {
		panic(bad_uplo)
	}
	if diag != .non_unit && diag != .unit {
		panic(bad_diag)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	if n == 0 {
		return
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}

	non_unit := diag == .non_unit
	if uplo == .upper {
		for j := 0; j < n; j++ {
			mut ajj := 0.0
			if non_unit {
				if a[j * lda + j] == 0.0 {
					return
				}
				ajj = 1.0 / a[j * lda + j]
				a[j * lda + j] = ajj
				ajj *= -1.0
			} else {
				ajj = -1.0
			}
			mut a_col := unsafe { a[j..] }
			blas.dtrmv(.upper, .no_trans, diag, j, a, lda, mut a_col, lda)
			blas.dscal(j, ajj, mut a_col, lda)
		}
		return
	}
	for j := n - 1; j >= 0; j-- {
		mut ajj := 0.0
		if non_unit {
			if a[j * lda + j] == 0.0 {
				return
			}
			ajj = 1.0 / a[j * lda + j]
			a[j * lda + j] = ajj
			ajj *= -1.0
		} else {
			ajj = -1.0
		}
		if j < n - 1 {
			mut a_sub := unsafe { a[(j + 1) * lda + j + 1..] }
			mut a_col := unsafe { a[(j + 1) * lda + j..] }
			blas.dtrmv(.lower, .no_trans, diag, n - j - 1, a_sub, lda, mut a_col, lda)
			blas.dscal(n - j - 1, ajj, mut a_col, lda)
		}
	}
}

