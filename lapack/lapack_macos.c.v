module lapack

fn C.LAPACKE_dlange(norm &char, m int, n int, a &f64, lda int, work &f64) f64

pub fn dlange(norm rune, m int, n int, a []f64, lda int, work []f64) f64 {
	return unsafe { C.LAPACKE_dlange(&char(norm.str().str), m, n, &a[0], lda, &work[0]) }
}
