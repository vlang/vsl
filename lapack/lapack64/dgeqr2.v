module lapack64

import math

// dgeqr2 computes a QR factorization of the m×n matrix A.
//
// In a QR factorization, Q is an m×m orthonormal matrix, and R is an
// upper triangular m×n matrix.
//
// A is modified to contain the information to construct Q and R.
// The upper triangle of a contains the matrix R. The lower triangular elements
// (not including the diagonal) contain the elementary reflectors. tau is modified
// to contain the reflector scales. tau must have length min(m,n), and
// this function will panic otherwise.
//
// The ith elementary reflector can be explicitly constructed by first extracting
// the
//
//	v[j] = 0           j < i
//	v[j] = 1           j == i
//	v[j] = a[j*lda+i]  j > i
//
// and computing H_i = I - tau[i] * v * vᵀ.
//
// The orthonormal matrix Q can be constructed from a product of these elementary
// reflectors, Q = H_0 * H_1 * ... * H_{k-1}, where k = min(m,n).
//
// work is temporary storage of length at least n and this function will panic otherwise.
//
// dgeqr2 is an internal routine. It is exported for testing purposes.
pub fn dgeqr2(m int, n int, mut a []f64, lda int, mut tau []f64, mut work []f64) {
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if work.len < n {
		panic(short_work)
	}

	// Quick return if possible.
	k := math.min(m, n)
	if k == 0 {
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}
	if tau.len != k {
		panic(bad_len_tau)
	}

	for i := 0; i < k; i++ {
		// Generate elementary reflector H_i.
		mut aii := a[i * lda + i]
		start_row := math.min(i + 1, m - 1)
		start_idx := start_row * lda + i
		mut x_slice := unsafe { a[start_idx..] }
		beta, tau_val := dlarfg(m - i, aii, mut x_slice, lda)
		a[i * lda + i] = beta
		tau[i] = tau_val
		if i < n - 1 {
			aii = a[i * lda + i]
			a[i * lda + i] = 1.0
			mut a_slice := unsafe { a[i * lda + i..] }
			mut a_right := unsafe { a[i * lda + i + 1..] }
			dlarf(.left, m - i, n - i - 1, a_slice, lda, tau[i], mut a_right, lda, mut
				work)
			a[i * lda + i] = aii
		}
	}
}
