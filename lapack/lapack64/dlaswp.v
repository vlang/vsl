module lapack64

import math
import vsl.blas

pub fn dlaswp(n int, mut a []f64, lda int, k1 int, k2 int, mut ipiv []int, incx int) {
	if n < 0 {
		panic(n_lt0)
	} else if k1 < 0 {
		panic(bad_k1)
	} else if k2 < k1 {
		panic(bad_k2)
	} else if lda < math.max(1, n) {
		panic(bad_ld_a)
	} else if a.len < k2 * lda + n {
		// A must have at least k2+1 rows.
		panic(short_a)
	} else if ipiv.len != k2 + 1 {
		panic(bad_len_ipiv)
	} else if incx != 1 && incx != -1 {
		panic(abs_inc_not_one)
	}

	if n == 0 {
		return
	}

	if incx == 1 {
		for k := k1; k <= k2; k++ {
			if k == ipiv[k] {
				continue
			}
			blas.dswap(n, mut a[k * lda..], 1, mut a[ipiv[k] * lda..], 1)
		}
		return
	}

	for k := k2; k >= k1; k-- {
		if k == ipiv[k] {
			continue
		}
		blas.dswap(n, mut a[k * lda..], 1, mut a[ipiv[k] * lda..], 1)
	}
}
