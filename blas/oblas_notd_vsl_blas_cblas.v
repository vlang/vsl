module blas

import vsl.blas.blas64

// set_num_threads sets the number of threads in BLAS
@[inline]
pub fn set_num_threads(n int) {}

@[inline]
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return blas64.ddot(n, x, incx, y, incy)
}

@[inline]
pub fn dasum(n int, x []f64, incx int) f64 {
	return blas64.dasum(n, x, incx)
}

@[inline]
pub fn dnrm2(n int, x []f64, incx int) f64 {
	return blas64.dnrm2(n, x, incx)
}

@[inline]
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	blas64.daxpy(n, alpha, x, incx, mut y, incy)
}

@[inline]
pub fn dcopy(n int, x []f64, incx int, mut y []f64, incy int) {
	blas64.dcopy(n, x, incx, mut y, incy)
}

@[inline]
pub fn dswap(n int, mut x []f64, incx int, mut y []f64, incy int) {
	blas64.dswap(n, mut x, incx, mut y, incy)
}

@[inline]
pub fn drot(n int, mut x []f64, incx int, mut y []f64, incy int, c f64, s f64) {
	blas64.drot(n, mut x, incx, mut y, incy, c, s)
}

@[inline]
pub fn dscal(n int, alpha f64, mut x []f64, incx int) {
	blas64.dscal(n, alpha, mut x, incx)
}

@[inline]
pub fn dgemv(trans Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dgemv(trans, m, n, alpha, a, lda, x, incx, beta, mut y, incy)
}

@[inline]
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas64.dger(m, n, alpha, x, incx, y, incy, mut a, lda)
}

@[inline]
pub fn dtrsv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtrsv(uplo, trans_a, diag, n, a, lda, mut x, incx)
}

@[inline]
pub fn dtrmv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtrmv(uplo, trans_a, diag, n, a, lda, mut x, incx)
}

@[inline]
pub fn dsyr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut a []f64, lda int) {
	blas64.dsyr(uplo, n, alpha, x, incx, mut a, lda)
}

@[inline]
pub fn dsyr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas64.dsyr2(uplo, n, alpha, x, incx, y, incy, mut a, lda)
}

@[inline]
pub fn dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut cc []f64, ldc int) {
	blas64.dgemm(trans_a, trans_b, m, n, k, alpha, a, lda, b, ldb, beta, mut cc, ldc)
}
