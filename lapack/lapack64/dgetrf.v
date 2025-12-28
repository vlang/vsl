module lapack64

import math
import vsl.blas

// dgetrf computes the LU decomposition of an m×n matrix A using partial
// pivoting with row interchanges.
//
// The LU decomposition is a factorization of A into
//
//	A = P * L * U
//
// where P is a permutation matrix, L is a lower triangular with unit diagonal
// elements (lower trapezoidal if m > n), and U is upper triangular (upper
// trapezoidal if m < n).
//
// On entry, a contains the matrix A. On return, L and U are stored in place
// into a, and P is represented by ipiv.
//
// ipiv contains a sequence of row interchanges. It indicates that row i of the
// matrix was interchanged with ipiv[i]. ipiv must have length min(m,n), and
// Dgetrf will panic otherwise. ipiv is zero-indexed.
//
// Dgetrf returns whether the matrix A is nonsingular. The LU decomposition will
// be computed regardless of the singularity of A, but the result should not be
// used to solve a system of equation.
pub fn dgetrf(m int, n int, mut a []f64, lda int, mut ipiv []int) bool {
	mn := math.min(m, n)

	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	// quick return if possible
	if mn == 0 {
		return true
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}
	if ipiv.len < mn {
		panic(bad_len_ipiv)
	}

	// Use unblocked path to simplify pivot handling and avoid large workspace needs.
	nb := 1
	if nb <= 1 || nb >= mn {
		return dgetf2(m, n, mut a, lda, mut ipiv)
	}

	mut ok := true
	for j := 0; j < mn; j += nb {
		jb := math.min(mn - j, nb)

		// factor diagonal and subdiagonal blocks and test for exact singularity.
		mut slice1 := unsafe { ipiv[j..j + jb] }
		block_ok := dgetf2(m - j, jb, mut a[j * lda + j..], lda, mut slice1)
		if !block_ok {
			ok = false
		}

		for i := j; i <= math.min(m - 1, j + jb - 1); i++ {
			ipiv[i] = j + ipiv[i]  // Convert from relative to absolute 0-based indices
		}

		// apply interchanges to columns 1..j-1.
		mut slice_ipiv1 := unsafe { ipiv[..j + jb] }
		dlaswp(j, mut a, lda, j, j + jb - 1, mut slice_ipiv1, 1)

		if j + jb < n {
			// apply interchanges to columns 1..j-1.
			mut slice2 := unsafe { a[j + jb..] }
			mut slice_ipiv2 := unsafe { ipiv[..j + jb] }
			dlaswp(j, mut slice2, lda, j, j + jb, mut slice_ipiv2, 1)

			mut slice3 := unsafe { a[j * lda + j + jb..] }
			blas.cm_dtrsm(.left, .lower, .no_trans, .unit, jb, n - j - jb, 1, a[j * lda + j..],
				lda, mut slice3, lda)

			if j + jb < m {
				mut slice4 := unsafe { a[(j + jb) * lda + j + jb..] }
				blas.cm_dgemm(.no_trans, .no_trans, m - j - jb, n - j - jb, jb, -1, a[(j + jb) * lda +
					j..], lda, a[j * lda + j + jb..], lda, 1, mut slice4, lda)
			}
		}
	}

	return ok
}
