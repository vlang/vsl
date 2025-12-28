module blas

import vsl.blas.blas64

@[inline]
pub fn cm_ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return blas64.cm_ddot(n, x, incx, y, incy)
}

@[inline]
pub fn cm_dscal(n int, alpha f64, mut x []f64, incx int) {
	blas64.cm_dscal(n, alpha, mut x, incx)
}

@[inline]
pub fn cm_daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	blas64.cm_daxpy(n, alpha, x, incx, mut y, incy)
}

@[inline]
pub fn cm_dgemv(trans Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.cm_dgemv(to_blas64_transpose(trans), m, n, alpha, a, lda, x, incx, beta, mut y, incy)
}

@[inline]
pub fn cm_dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	blas64.cm_dgemm(to_blas64_transpose(trans_a), to_blas64_transpose(trans_b), m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
}

@[inline]
pub fn cm_dsyrk(uplo Uplo, trans Transpose, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	blas64.cm_dsyrk(to_blas64_uplo(uplo), to_blas64_transpose(trans), n, k, alpha, a, lda, beta, mut c, ldc)
}

@[inline]
pub fn cm_dtrsm(side Side, uplo Uplo, trans_a Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	blas64.cm_dtrsm(to_blas64_side(side), to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag), m, n, alpha, a, lda, mut b, ldb)
}

