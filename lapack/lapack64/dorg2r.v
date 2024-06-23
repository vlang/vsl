module lapack64

import math
import vsl.blas

pub fn dorg2r(m int, n int, k int, mut a []f64, lda int, tau []f64, mut work []f64) {
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
	if tau.len != k {
		panic(bad_len_tau)
	}
	if work.len < n {
		panic(short_work)
	}

	// Initialize columns k+1:n to columns of the unit matrix.
	for l := 0; l < m; l++ {
		for j := k; j < n; j++ {
			a[l * lda + j] = 0.0
		}
	}
	for j := k; j < n; j++ {
		a[j * lda + j] = 1.0
	}
	for i := k - 1; i >= 0; i-- {
		for mut elem in work {
			elem = 0.0
		}
		if i < n - 1 {
			a[i * lda + i] = 1.0
			dlarf(.left, m - i, n - i - 1, a[(i * lda + i)..], lda, tau[i], mut a[(i * lda + i + 1)..],
				lda, mut work)
		}
		if i < m - 1 {
			blas.dscal(m - i - 1, -tau[i], mut a[(i + 1) * lda + i..], lda)
		}
		a[i * lda + i] = 1.0 - tau[i]
		for l := 0; l < i; l++ {
			a[l * lda + i] = 0.0
		}
	}
}
