module lapack64

import math
import vsl.blas

// dgetrs solves a system of equations using an LU factorization.
// The system of equations solved is
//
//	A * X = B  if trans == blas.Trans
//	Aᵀ * X = B if trans == blas.NoTrans
//
// A is a general n×n matrix with stride lda. B is a general matrix of size n×nrhs.
//
// On entry b contains the elements of the matrix B. On exit, b contains the
// elements of X, the solution to the system of equations.
//
// a and ipiv contain the LU factorization of A and the permutation indices as
// computed by Dgetrf. ipiv is zero-indexed.
pub fn dgetrs(trans blas.Transpose, n int, nrhs int, mut a []f64, lda int, mut ipiv []int, mut b []f64, ldb int) {
	if trans != .no_trans && trans != .trans && trans != .conj_trans {
		panic(bad_trans)
	}
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
	if b.len < (n - 1) * ldb + nrhs {
		panic(short_b)
	}
	if ipiv.len != n {
		panic(bad_len_ipiv)
	}

	if trans == .no_trans {
		// Solve A * X = B.
		dlaswp(nrhs, mut b, ldb, 0, n - 1, mut ipiv, 1)
		// Solve L * X = B, overwriting B with X.
		blas.dtrsm(.left, .lower, .no_trans, .unit, n, nrhs, 1, a, lda, mut b, ldb)
		// Solve U * X = B, overwriting B with X.
		blas.dtrsm(.left, .upper, .no_trans, .non_unit, n, nrhs, 1, a, lda, mut b, ldb)
		return
	}

	// Solve Aᵀ * X = B.
	// Solve Uᵀ * X = B, overwriting B with X.
	blas.dtrsm(.left, .upper, .trans, .non_unit, n, nrhs, 1, a, lda, mut b, ldb)
	// Solve Lᵀ * X = B, overwriting B with X.
	blas.dtrsm(.left, .lower, .trans, .unit, n, nrhs, 1, a, lda, mut b, ldb)
	dlaswp(nrhs, mut b, ldb, 0, n - 1, mut ipiv, -1)
}
