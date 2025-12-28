module lapack64

import math
import vsl.blas

// dtrtri computes the inverse of a triangular matrix, storing the result in place
// into a. This is the BLAS level 3 version of the algorithm which builds upon
// dtrti2 to operate on matrix blocks instead of only individual columns.
//
// dtrtri will not perform the inversion if the matrix is singular, and returns
// a boolean indicating whether the inversion was successful.
pub fn dtrtri(uplo blas.Uplo, diag blas.Diagonal, n int, mut a []f64, lda int) bool {
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
		return true
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}

	if diag == .non_unit {
		for i in 0 .. n {
			if a[i * lda + i] == 0.0 {
				return false
			}
		}
	}

	nb := ilaenv(1, 'DTRTRI', if uplo == .upper { 'U' } else { 'L' }, n, -1, -1, -1)
	if nb <= 1 || nb > n {
		dtrti2(uplo, diag, n, mut a, lda)
		return true
	}
	if uplo == .upper {
		for j := 0; j < n; j += nb {
			jb := math.min(nb, n - j)
			mut a_block := unsafe { a[j..] }
			mut a_diag := unsafe { a[j * lda + j..] }
			blas.dtrmm(.left, .upper, .no_trans, diag, j, jb, 1.0, a, lda, mut a_block, lda)
			blas.dtrsm(.right, .upper, .no_trans, diag, j, jb, -1.0, a_diag, lda, mut a_block,
				lda)
			dtrti2(.upper, diag, jb, mut a_diag, lda)
		}
		return true
	}
	nn := ((n - 1) / nb) * nb
	for j := nn; j >= 0; j -= nb {
		jb := math.min(nb, n - j)
		if j + jb <= n - 1 {
			mut a_right := unsafe { a[(j + jb) * lda + j + jb..] }
			mut a_block := unsafe { a[(j + jb) * lda + j..] }
			mut a_diag := unsafe { a[j * lda + j..] }
			blas.dtrmm(.left, .lower, .no_trans, diag, n - j - jb, jb, 1.0, a_right, lda,
				mut a_block, lda)
			blas.dtrsm(.right, .lower, .no_trans, diag, n - j - jb, jb, -1.0, a_diag, lda,
				mut a_block, lda)
		}
		mut a_diag := unsafe { a[j * lda + j..] }
		dtrti2(.lower, diag, jb, mut a_diag, lda)
	}
	return true
}

