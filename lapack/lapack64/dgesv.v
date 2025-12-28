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
pub fn dgesv(n int, nrhs int, mut a []f64, lda int, mut ipiv []int, mut b []f64, ldb int) int {
	if n < 0 {
		panic(n_lt0)
	}
	if nrhs < 0 {
		panic(nrhs_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	// For column-major format: ldb is the leading dimension (number of rows)
	// We need ldb >= n (number of rows) and ldb >= nrhs (number of columns)
	// because dgetrs will call dlaswp with nrhs columns and requires lda >= nrhs
	if ldb < math.max(1, math.max(n, nrhs)) {
		panic(bad_ld_b)
	}

	// Quick return if possible.
	if n == 0 || nrhs == 0 {
		return 0
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

	ok := dgetrf(n, n, mut a, lda, mut ipiv)
	if ok {
		dgetrs(.no_trans, n, nrhs, mut a, lda, mut ipiv, mut b, ldb)
		return 0
	} else {
		// Matrix is singular, return error code
		// In LAPACK, info > 0 indicates the pivot index where singularity was detected
		// For simplicity, we return 1 to indicate general singularity
		return 1
	}
}
