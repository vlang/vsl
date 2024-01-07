module lapack

import math
import vsl.blas.blas64

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
pub fn dgetrf(m int, n int, mut a []f64, lda int, ipiv []int) {
	mn := math.min(m, n)

	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_lda)
	}

	// quick return if possible
	if mn == 0 {
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}
	if ipiv.len < mn {
		panic(bad_len_ipiv)
	}
}
