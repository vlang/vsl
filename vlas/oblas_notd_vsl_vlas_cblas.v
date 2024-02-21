module vlas

import vsl.vlas.internal.blas

// set_num_threads sets the number of threads in VLAS
pub fn set_num_threads(n int) {}

@[inline]
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return blas.ddot(n, x, incx, y, incy)
}

@[inline]
pub fn dasum(n int, x []f64, incx int) f64 {
	return blas.dasum(n, x, incx)
}

@[inline]
pub fn dnrm2(n int, x []f64, incx int) f64 {
	return blas.dnrm2(n, x, incx)
}

@[inline]
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	blas.daxpy(n, alpha, x, incx, mut y, incy)
}

@[inline]
pub fn dcopy(n int, x []f64, incx int, mut y []f64, incy int) {
	blas.dcopy(n, x, incx, mut y, incy)
}

@[inline]
pub fn dswap(n int, mut x []f64, incx int, mut y []f64, incy int) {
	blas.dswap(n, mut x, incx, mut y, incy)
}

@[inline]
pub fn drot(n int, mut x []f64, incx int, mut y []f64, incy int, c f64, s f64) {
	blas.drot(n, mut x, incx, mut y, incy, c, s)
}

@[inline]
pub fn dscal(n int, alpha f64, mut x []f64, incx int) {
	blas.dscal(n, alpha, mut x, incx)
}

@[inline]
pub fn dgemv(trans bool, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas.dgemv(c_trans(trans), m, n, alpha, a, lda, x, incx, beta, mut y, incy)
}

@[inline]
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas.dger(m, n, alpha, x, incx, y, incy, mut a, lda)
}

@[inline]
pub fn dtrsv(uplo bool, trans_a bool, diag blas.Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas.dtrsv(c_uplo(uplo), c_trans(trans_a), diag, n, a, lda, mut x, incx)
}

@[inline]
pub fn dtrmv(uplo bool, trans_a bool, diag blas.Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas.dtrmv(c_uplo(uplo), c_trans(trans_a), diag, n, a, lda, mut x, incx)
}

@[inline]
pub fn dsyr(uplo bool, n int, alpha f64, x []f64, incx int, mut a []f64, lda int) {
	blas.dsyr(c_uplo(uplo), n, alpha, x, incx, mut a, lda)
}

@[inline]
pub fn dsyr2(uplo bool, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas.dsyr2(c_uplo(uplo), n, alpha, x, incx, y, incy, mut a, lda)
}

@[inline]
pub fn dgemm(trans_a bool, trans_b bool, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut cc []f64, ldc int) {
	blas.dgemm(c_trans(trans_a), c_trans(trans_b), m, n, k, alpha, a, lda, b, ldb, beta, mut
		cc, ldc)
}
