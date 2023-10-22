module vlas

fn C.LAPACKE_dlange(norm byte, m int, n int, a &f64, lda int, work &f64) f64

pub fn dlange(norm byte, m int, n int, a []f64, lda int, work []f64) f64 {
	return unsafe { C.LAPACKE_dlange(norm, m, n, &a[0], lda, &work[0]) }
}
