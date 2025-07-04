module lapack64

import math

// iladlr scans a matrix for its last non-zero row. Returns -1 if the matrix
// is all zeros.
pub fn iladlr(m int, n int, a []f64, lda int) int {
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	if n == 0 || m == 0 {
		return -1
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}

	// Check the common case where the corner is non-zero
	if a[(m - 1) * lda] != 0 || a[(m - 1) * lda + n - 1] != 0 {
		return m - 1
	}
	for i := m - 1; i >= 0; i-- {
		for j := 0; j < n; j++ {
			if a[i * lda + j] != 0 {
				return i
			}
		}
	}
	return -1
}
