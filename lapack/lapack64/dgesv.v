module lapack64

import math
import vsl.blas

// dgesv computes the solution to a real system of linear equations
//
//	A * X = B
//
// where A is an n×n matrix and X and B are n×nrhs matrices.
//
// The LU decomposition with partial pivoting and row interchanges is used to
// factor A as
//
//	A = P * L * U
//
// where P is a permutation matrix, L is unit lower triangular, and U is upper
// triangular. On return, the factors L and U are stored in a; the unit diagonal
// elements of L are not stored. The row pivot indices that define the
// permutation matrix P are stored in ipiv.
//
// The factored form of A is then used to solve the system of equations A * X =
// B. On entry, b contains the right hand side matrix B. On return, if ok is
// true, b contains the solution matrix X.
pub fn dgesv(n int, nrhs int, mut a []f64, lda int, mut ipiv []int, mut b []f64, ldb int) {
	if n < 0 {
		panic(n_lt0)
	}
	if nrhs < 0 {
		panic(nrhs_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if ldb < math.max(1, nrhs) {
		panic(bad_ld_b)
	}

	// Quick return if possible.
	if n == 0 || nrhs == 0 {
		return
	}

	if a.len < (n - 1) * lda + n {
		panic(short_ab)
	}
	if ipiv.len < n {
		panic(bad_len_ipiv)
	}
	if b.len < (n - 1) * ldb + nrhs {
		panic(short_b)
	}

	dgetrf(n, n, mut a, lda, mut ipiv)
	dgetrs(.no_trans, n, nrhs, mut a, lda, mut ipiv, mut b, ldb)
}
