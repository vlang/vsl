module vlas

import vsl.vlas.internal.vblas

fn C.LAPACKE_dlange(matrix_layout vblas.MemoryLayout, norm byte, m int, n int, a &f64, lda int, work &f64) f64

pub fn dlange(norm byte, m int, n int, a []f64, lda int, work []f64) f64 {
	return unsafe { C.LAPACKE_dlange(.row_major, norm, m, n, &a[0], lda, &work[0]) }
}
