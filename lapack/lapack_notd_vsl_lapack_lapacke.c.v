module lapack

import vsl.blas

fn C.LAPACKE_dlange(matrix_layout int, norm &char, m int, n int, a &f64, lda int, work &f64) f64

pub fn dlange(norm rune, m int, n int, a []f64, lda int, work []f64) f64 {
	return unsafe {
		C.LAPACKE_dlange(int(blas.MemoryLayout.row_major), &char(norm.str().str), m, n, &a[0], lda,
			&work[0])
	}
}
