module lapack64

import math
import vsl.blas

pub fn dgetf2(m int, n int, mut a []f64, lda int, mut ipiv []int) {
	mn := math.min(m, n)
	if m < 0 {
		panic(m_lt0)
	} else if n < 0 {
		panic(n_lt0)
	} else if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	// Quick return if possible.
	if mn == 0 {
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	} else if ipiv.len != mn {
		panic(bad_len_ipiv)
	}

	sfmin := dlamch_s

	for j := 0; j < mn; j++ {
		// Find a pivot and test for singularity.
		jp := j + blas.idamax(m - j, a[j * lda + j..], lda)
		ipiv[j] = jp
		if a[jp * lda + j] == 0.0 {
			panic('lapack: matrix is singular')
		} else {
			// Swap the rows if necessary.
			if jp != j {
				mut slice1 := unsafe { a[j * lda..] }
				mut slice2 := unsafe { a[jp * lda..] }
				blas.dswap(n, mut slice1, 1, mut slice2, 1)
			}
			if j < m - 1 {
				aj := a[j * lda + j]
				if math.abs(aj) >= sfmin {
					mut slice3 := unsafe { a[(j + 1) * lda + j..] }
					blas.dscal(m - j - 1, 1.0 / aj, mut slice3, lda)
				} else {
					for i := 0; i < m - j - 1; i++ {
						a[(j + 1) * lda + j] /= aj
					}
				}
			}
		}
		if j < mn - 1 {
			mut slice4 := unsafe { a[(j + 1) * lda + j + 1..] }
			blas.dger(m - j - 1, n - j - 1, -1.0, a[(j + 1) * lda + j..], lda, a[j * lda + j + 1..],
				1, mut slice4, lda)
		}
	}
}
