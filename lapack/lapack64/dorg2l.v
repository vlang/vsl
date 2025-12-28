module lapack64

import math
import vsl.blas

// dorg2l generates an m×n matrix Q with orthonormal columns which is defined
// as the last n columns of a product of k elementary reflectors of order m.
//
//  Q = H_{k-1} * ... * H_1 * H_0
//
// See dgelqf for more information. It must be that m >= n >= k.
//
// tau contains the scalar reflectors computed by dgeqlf. tau must have length
// at least k, and dorg2l will panic otherwise.
//
// work contains temporary memory, and must have length at least n. dorg2l will
// panic otherwise.
//
// dorg2l is an internal routine. It is exported for testing purposes.
pub fn dorg2l(m int, n int, k int, mut a []f64, lda int, tau []f64, mut work []f64) {
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if n > m {
		panic(n_gtm)
	}
	if k < 0 {
		panic(k_lt0)
	}
	if k > n {
		panic(k_gtn)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	if n == 0 {
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}
	if tau.len < k {
		panic(short_tau)
	}
	if work.len < n {
		panic(short_work)
	}

	// Initialize columns 0:n-k to columns of the unit matrix.
	for j := 0; j < n - k; j++ {
		for l := 0; l < m; l++ {
			a[l * lda + j] = 0
		}
		a[(m - n + j) * lda + j] = 1
	}

	for i := 0; i < k; i++ {
		ii := n - k + i

		// Apply H_i to A[0:m-k+i, 0:n-k+i] from the left.
		a[(m - n + ii) * lda + ii] = 1
		dlarf(.left, m - n + ii + 1, ii, a[ii..], lda, tau[i], mut a, lda, mut work)
		blas.dscal(m - n + ii, -tau[i], mut a[ii..], lda)
		a[(m - n + ii) * lda + ii] = 1 - tau[i]

		// Set A[m-k+i:m, n-k+i+1] to zero.
		for l := m - n + ii + 1; l < m; l++ {
			a[l * lda + ii] = 0
		}
	}
}
