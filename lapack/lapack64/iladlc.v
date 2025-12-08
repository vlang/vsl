module lapack64

import math

// iladlc scans a matrix for its last non-zero column. Returns -1 if the matrix
// is all zeros.
pub fn iladlc(m int, n int, a []f64, lda int) int {
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

	// Test common case where corner is non-zero.
	if a[n - 1] != 0 || a[(m - 1) * lda + (n - 1)] != 0 {
		return n - 1
	}

	// Scan each row tracking the highest column seen.
	mut highest := -1
	for i := 0; i < m; i++ {
		for j := n - 1; j >= 0; j-- {
			if a[i * lda + j] != 0 {
				highest = math.max(highest, j)
				break
			}
		}
	}
	return highest
}
