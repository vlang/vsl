module blas

import math
import vsl.blas.blas64

// set_num_threads sets the number of threads in BLAS
@[inline]
pub fn set_num_threads(n int) {}

// ddot computes the dot product of two vectors.
@[inline]
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return blas64.ddot(n, x, incx, y, incy)
}

// dasum computes the sum of the absolute values of elements in a vector.
@[inline]
pub fn dasum(n int, x []f64, incx int) f64 {
	return blas64.dasum(n, x, incx)
}

// dnrm2 computes the Euclidean norm of a vector.
@[inline]
pub fn dnrm2(n int, x []f64, incx int) f64 {
	return blas64.dnrm2(n, x, incx)
}

// daxpy computes y := alpha * x + y.
@[inline]
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	blas64.daxpy(n, alpha, x, incx, mut y, incy)
}

// dcopy copies a vector x to a vector y.
@[inline]
pub fn dcopy(n int, x []f64, incx int, mut y []f64, incy int) {
	blas64.dcopy(n, x, incx, mut y, incy)
}

// dswap swaps the elements of two vectors.
@[inline]
pub fn dswap(n int, mut x []f64, incx int, mut y []f64, incy int) {
	blas64.dswap(n, mut x, incx, mut y, incy)
}

// drot applies a plane rotation to points in the plane.
@[inline]
pub fn drot(n int, mut x []f64, incx int, mut y []f64, incy int, c f64, s f64) {
	blas64.drot(n, mut x, incx, mut y, incy, c, s)
}

// dscal scales a vector by a constant.
@[inline]
pub fn dscal(n int, alpha f64, mut x []f64, incx int) {
	blas64.dscal(n, alpha, mut x, incx)
}

// idamax finds the index of the element with the maximum absolute value.
@[inline]
pub fn idamax(n int, x []f64, incx int) int {
	return blas64.idamax(n, x, incx)
}

// dgemv performs matrix-vector multiplication.
// Input matrices are expected in row-major format (as used by la/ module and tests).
// The Pure V backend (blas64) also expects row-major format, so no conversion is needed.
@[inline]
pub fn dgemv(trans Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dgemv(to_blas64_transpose(trans), m, n, alpha, a, lda, x, incx, beta, mut y,
		incy)
}

// dger performs the rank-1 update of a matrix.
// Input matrix is expected in row-major format (as used by la/ module and tests).
// The Pure V backend (blas64) also expects row-major format, so no conversion is needed.
@[inline]
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas64.dger(m, n, alpha, x, incx, y, incy, mut a, lda)
}

// dtrsv solves a system of linear equations with a triangular matrix.
@[inline]
pub fn dtrsv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtrsv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag),
		n, a, lda, mut x, incx)
}

// dtrmv performs matrix-vector operations using a triangular matrix.
@[inline]
pub fn dtrmv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtrmv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag),
		n, a, lda, mut x, incx)
}

// dsyr performs a symmetric rank-1 update of a matrix.
@[inline]
pub fn dsyr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut a []f64, lda int) {
	blas64.dsyr(to_blas64_uplo(uplo), n, alpha, x, incx, mut a, lda)
}

// dsyr2 performs a symmetric rank-2 update of a matrix.
@[inline]
pub fn dsyr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas64.dsyr2(to_blas64_uplo(uplo), n, alpha, x, incx, y, incy, mut a, lda)
}

// dgemm performs matrix-matrix multiplication.
// Input matrices are expected in row-major format (as used by la/ module and tests).
// The Pure V backend (blas64) also expects row-major format, so no conversion is needed.
@[inline]
pub fn dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut cc []f64, ldc int) {
	blas64.dgemm(to_blas64_transpose(trans_a), to_blas64_transpose(trans_b), m, n, k,
		alpha, a, lda, b, ldb, beta, mut cc, ldc)
}

// dgbmv performs a matrix-vector multiplication with a band matrix.
@[inline]
pub fn dgbmv(trans_a Transpose, m int, n int, kl int, ku int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dgbmv(to_blas64_transpose(trans_a), m, n, kl, ku, alpha, a, lda, x, incx, beta, mut
		y, incy)
}

// dsymv performs a matrix-vector multiplication for a symmetric matrix.
@[inline]
pub fn dsymv(uplo Uplo, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dsymv(to_blas64_uplo(uplo), n, alpha, a, lda, x, incx, beta, mut y, incy)
}

// dsbmv performs a matrix-vector multiplication with a symmetric band matrix.
@[inline]
pub fn dsbmv(uplo Uplo, n int, k int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dsbmv(to_blas64_uplo(uplo), n, k, alpha, a, lda, x, incx, beta, mut y, incy)
}

// dtbmv performs a matrix-vector multiplication with a triangular band matrix.
@[inline]
pub fn dtbmv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtbmv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag),
		n, k, a, lda, mut x, incx)
}

// dtbsv solves a system of linear equations with a triangular band matrix.
@[inline]
pub fn dtbsv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtbsv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag),
		n, k, a, lda, mut x, incx)
}

// dtpmv performs a matrix-vector multiplication with a triangular packed matrix.
@[inline]
pub fn dtpmv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	blas64.dtpmv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag),
		n, ap, mut x, incx)
}

// dtpsv solves a system of linear equations with a triangular packed matrix.
@[inline]
pub fn dtpsv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	blas64.dtpsv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag),
		n, ap, mut x, incx)
}

// dspmv performs a matrix-vector multiplication with a symmetric packed matrix.
@[inline]
pub fn dspmv(uplo Uplo, n int, alpha f64, ap []f64, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dspmv(to_blas64_uplo(uplo), n, alpha, ap, x, incx, beta, mut y, incy)
}

// dspr performs a symmetric rank-1 update for a packed matrix.
@[inline]
pub fn dspr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut ap []f64) {
	blas64.dspr(to_blas64_uplo(uplo), n, alpha, x, incx, mut ap)
}

// dspr2 performs a symmetric rank-2 update for a packed matrix.
@[inline]
pub fn dspr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut ap []f64) {
	blas64.dspr2(to_blas64_uplo(uplo), n, alpha, x, incx, y, incy, mut ap)
}

// dsyrk performs a symmetric rank-k update.
@[inline]
pub fn dsyrk(uplo Uplo, trans_a Transpose, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	blas64.dsyrk(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), n, k, alpha, a, lda,
		beta, mut c, ldc)
}

// dsyr2k performs a symmetric rank-2k update.
@[inline]
pub fn dsyr2k(uplo Uplo, trans_a Transpose, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	blas64.dsyr2k(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), n, k, alpha, a,
		lda, b, ldb, beta, mut c, ldc)
}

// dtrmm performs triangular matrix multiplication.
// Input matrices are expected in row-major format (as used by la/ module and tests).
// blas64.dtrmm uses row-major access pattern but validates ldb >= m (inconsistent).
// We pass matrices directly but ensure ldb >= m for validation.
pub fn dtrmm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	// blas64.dtrmm validates ldb >= m, but uses row-major access b[i*ldb..i*ldb+n]
	// Since we're using row-major and ldb is typically n (number of columns),
	// we need to ensure ldb >= m. If not, we pad.
	effective_ldb := math.max(ldb, m)
	if effective_ldb > ldb {
		// Need to create a padded version of b with ldb >= m
		// Maximum index accessed: (m-1)*effective_ldb + (n-1)
		b_padded_len := (m - 1) * effective_ldb + n
		mut b_padded := []f64{len: b_padded_len}
		for i in 0 .. m {
			for j in 0 .. n {
				idx_padded := i * effective_ldb + j
				idx_orig := i * ldb + j
				if idx_padded < b_padded.len && idx_orig < b.len {
					b_padded[idx_padded] = b[idx_orig]
				}
			}
		}
		blas64.dtrmm(to_blas64_side(side), to_blas64_uplo(uplo), to_blas64_transpose(trans),
			to_blas64_diagonal(diag), m, n, alpha, a, lda, mut b_padded, effective_ldb)
		// Copy back
		for i in 0 .. m {
			for j in 0 .. n {
				idx_padded := i * effective_ldb + j
				idx_orig := i * ldb + j
				if idx_padded < b_padded.len && idx_orig < b.len {
					b[idx_orig] = b_padded[idx_padded]
				}
			}
		}
	} else {
		blas64.dtrmm(to_blas64_side(side), to_blas64_uplo(uplo), to_blas64_transpose(trans),
			to_blas64_diagonal(diag), m, n, alpha, a, lda, mut b, ldb)
	}
}

// dtrsm solves triangular system of equations with multiple right-hand sides.
@[inline]
pub fn dtrsm(side Side, uplo Uplo, trans Transpose, diag Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	k := if side == .left { m } else { n }
	// Convert A (row-major) to column-major buffer of size k x k
	mut a_col := []f64{len: k * k}
	for i in 0 .. k {
		for j in 0 .. k {
			a_col[i + j * k] = a[i * lda + j]
		}
	}
	// Convert B (row-major) to column-major buffer of size m x n
	mut b_col := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			b_col[i + j * m] = b[i * ldb + j]
		}
	}
	blas64.cm_dtrsm(to_blas64_side(side), to_blas64_uplo(uplo), to_blas64_transpose(trans),
		to_blas64_diagonal(diag), m, n, alpha, a_col, k, mut b_col, m)
	// Convert back to row-major
	for i in 0 .. m {
		for j in 0 .. n {
			b[i * ldb + j] = b_col[i + j * m]
		}
	}
}
