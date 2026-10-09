module blas

import math
import vsl.blas.blas64
import vsl.float.float32

$if vsl_blas_generic_cblas ? {
	fn C.cblas_sgemm(order int, trans_a int, trans_b int, m int, n int, k int, alpha f32, const_a &f32, lda int, const_b &f32, ldb int, beta f32, c &f32, ldc int)
	fn C.cblas_dgemm(order int, trans_a int, trans_b int, m int, n int, k int, alpha f64, const_a &f64, lda int, const_b &f64, ldb int, beta f64, c &f64, ldc int)
	fn C.cblas_sgemv(order int, trans int, m int, n int, alpha f32, const_a &f32, lda int, const_x &f32, incx int, beta f32, y &f32, incy int)
	fn C.cblas_dgemv(order int, trans int, m int, n int, alpha f64, const_a &f64, lda int, const_x &f64, incx int, beta f64, y &f64, incy int)
}

// set_num_threads sets the number of threads in BLAS

// set_num_threads exposes this operation as part of the public API.

// set_num_threads exposes this operation as part of the public API.
@[inline]
pub fn set_num_threads(n int) {}

// ddot computes the dot product of two vectors.

// ddot exposes this operation as part of the public API.

// ddot exposes this operation as part of the public API.
@[inline]
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return blas64.ddot(n, x, incx, y, incy)
}

// dasum computes the sum of the absolute values of elements in a vector.

// dasum exposes this operation as part of the public API.

// dasum exposes this operation as part of the public API.
@[inline]
pub fn dasum(n int, x []f64, incx int) f64 {
	return blas64.dasum(n, x, incx)
}

// dnrm2 computes the Euclidean norm of a vector.

// dnrm2 exposes this operation as part of the public API.

// dnrm2 exposes this operation as part of the public API.
@[inline]
pub fn dnrm2(n int, x []f64, incx int) f64 {
	return blas64.dnrm2(n, x, incx)
}

// daxpy computes y := alpha * x + y.

// daxpy exposes this operation as part of the public API.

// daxpy exposes this operation as part of the public API.
@[inline]
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	blas64.daxpy(n, alpha, x, incx, mut y, incy)
}

// dcopy copies a vector x to a vector y.

// dcopy exposes this operation as part of the public API.

// dcopy exposes this operation as part of the public API.
@[inline]
pub fn dcopy(n int, x []f64, incx int, mut y []f64, incy int) {
	blas64.dcopy(n, x, incx, mut y, incy)
}

// dswap swaps the elements of two vectors.

// dswap exposes this operation as part of the public API.

// dswap exposes this operation as part of the public API.
@[inline]
pub fn dswap(n int, mut x []f64, incx int, mut y []f64, incy int) {
	blas64.dswap(n, mut x, incx, mut y, incy)
}

// drot applies a plane rotation to points in the plane.

// drot exposes this operation as part of the public API.

// drot exposes this operation as part of the public API.
@[inline]
pub fn drot(n int, mut x []f64, incx int, mut y []f64, incy int, c f64, s f64) {
	blas64.drot(n, mut x, incx, mut y, incy, c, s)
}

// dscal scales a vector by a constant.

// dscal exposes this operation as part of the public API.

// dscal exposes this operation as part of the public API.
@[inline]
pub fn dscal(n int, alpha f64, mut x []f64, incx int) {
	blas64.dscal(n, alpha, mut x, incx)
}

// idamax finds the index of the element with the maximum absolute value.

// idamax exposes this operation as part of the public API.

// idamax exposes this operation as part of the public API.
@[inline]
pub fn idamax(n int, x []f64, incx int) int {
	return blas64.idamax(n, x, incx)
}

// dgemv performs matrix-vector multiplication.
// Input matrices are expected in row-major format (as used by la/ module and tests).
// The Pure V backend (blas64) also expects row-major format, so no conversion is needed.

// dgemv exposes this operation as part of the public API.

// dgemv exposes this operation as part of the public API.
@[inline]
pub fn dgemv(trans Transpose, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	validate_gemv_arguments(trans, m, n, lda, a.len, incx, x.len, incy, y.len)
	if m == 0 || n == 0 || (alpha == 0 && beta == 1) {
		return
	}
	$if vsl_blas_generic_cblas ? {
		if incx > 0 && incy > 0 && alpha != 0 {
			C.cblas_dgemv(int(MemoryLayout.row_major), cblas_gemv_transpose(trans), m, n, alpha,
				unsafe { &a[0] }, lda, unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
			return
		}
	}
	blas64.dgemv(to_blas64_transpose(trans), m, n, alpha, a, lda, x, incx, beta, mut y, incy)
}

// sgemv computes y = alpha * op(A) * x + beta * y for row-major f32 matrices.
pub fn sgemv(trans Transpose, m int, n int, alpha f32, a []f32, lda int, x []f32, incx int, beta f32, mut y []f32, incy int) {
	validate_gemv_arguments(trans, m, n, lda, a.len, incx, x.len, incy, y.len)
	if m == 0 || n == 0 || (alpha == 0 && beta == 1) {
		return
	}
	$if vsl_blas_generic_cblas ? {
		if incx > 0 && incy > 0 && alpha != 0 {
			C.cblas_sgemv(int(MemoryLayout.row_major), cblas_gemv_transpose(trans), m, n, alpha,
				unsafe { &a[0] }, lda, unsafe { &x[0] }, incx, beta, unsafe { &y[0] }, incy)
			return
		}
	}
	len_y := if trans == .no_trans || trans == .conj_no_trans { m } else { n }
	if alpha == 0 {
		start_y := if incy < 0 { (len_y - 1) * -incy } else { 0 }
		for i in 0 .. len_y {
			index := start_y + i * incy
			if beta == 0 {
				y[index] = 0
			} else {
				y[index] *= beta
			}
		}
		return
	}
	if trans == .no_trans || trans == .conj_no_trans {
		float32.gemv_n(u32(m), u32(n), alpha, a, u32(lda), x, incx, beta, mut y, incy)
	} else {
		float32.gemv_t(u32(m), u32(n), alpha, a, u32(lda), x, incx, beta, mut y, incy)
	}
}

fn validate_gemv_arguments(trans Transpose, m int, n int, lda int, a_len int, incx int, x_len int, incy int, y_len int) {
	if m < 0 {
		panic(blas64.mlt0)
	}
	if n < 0 {
		panic(blas64.nlt0)
	}
	if lda < math.max(1, n) {
		panic(blas64.bad_ld_a)
	}
	if incx == 0 {
		panic(blas64.zero_incx)
	}
	if incy == 0 {
		panic(blas64.zero_incy)
	}
	if m == 0 || n == 0 {
		return
	}
	len_x := if trans == .no_trans || trans == .conj_no_trans { n } else { m }
	len_y := if trans == .no_trans || trans == .conj_no_trans { m } else { n }
	if (incx > 0 && (len_x - 1) * incx >= x_len) || (incx < 0 && (1 - len_x) * incx >= x_len) {
		panic(blas64.short_x)
	}
	if (incy > 0 && (len_y - 1) * incy >= y_len) || (incy < 0 && (1 - len_y) * incy >= y_len) {
		panic(blas64.short_y)
	}
	if a_len < lda * (m - 1) + n {
		panic(blas64.short_a)
	}
}

fn cblas_gemv_transpose(trans Transpose) int {
	return if trans == .conj_no_trans { int(Transpose.no_trans) } else { int(trans) }
}

// dger performs the rank-1 update of a matrix.
// Input matrix is expected in row-major format (as used by la/ module and tests).
// The Pure V backend (blas64) also expects row-major format, so no conversion is needed.

// dger exposes this operation as part of the public API.

// dger exposes this operation as part of the public API.
@[inline]
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas64.dger(m, n, alpha, x, incx, y, incy, mut a, lda)
}

// dtrsv solves a system of linear equations with a triangular matrix.

// dtrsv exposes this operation as part of the public API.

// dtrsv exposes this operation as part of the public API.
@[inline]
pub fn dtrsv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtrsv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag), n,
		a, lda, mut x, incx)
}

// dtrmv performs matrix-vector operations using a triangular matrix.

// dtrmv exposes this operation as part of the public API.

// dtrmv exposes this operation as part of the public API.
@[inline]
pub fn dtrmv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtrmv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag), n,
		a, lda, mut x, incx)
}

// dsyr performs a symmetric rank-1 update of a matrix.

// dsyr exposes this operation as part of the public API.

// dsyr exposes this operation as part of the public API.
@[inline]
pub fn dsyr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut a []f64, lda int) {
	blas64.dsyr(to_blas64_uplo(uplo), n, alpha, x, incx, mut a, lda)
}

// dsyr2 performs a symmetric rank-2 update of a matrix.

// dsyr2 exposes this operation as part of the public API.

// dsyr2 exposes this operation as part of the public API.
@[inline]
pub fn dsyr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	blas64.dsyr2(to_blas64_uplo(uplo), n, alpha, x, incx, y, incy, mut a, lda)
}

// dgemm performs matrix-matrix multiplication.
// Input matrices are expected in row-major format (as used by la/ module and tests).
// The Pure V backend (blas64) also expects row-major format, so no conversion is needed.

// sgemm computes a row-major single-precision matrix multiplication.
pub fn sgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut c []f32, ldc int) {
	$if vsl_blas_generic_cblas ? {
		a_trans := trans_a == .trans || trans_a == .conj_trans
		b_trans := trans_b == .trans || trans_b == .conj_trans
		a_required := if a_trans { (k - 1) * lda + m } else { (m - 1) * lda + k }
		b_required := if b_trans { (n - 1) * ldb + k } else { (k - 1) * ldb + n }
		c_required := (m - 1) * ldc + n
		if m <= 0 || n <= 0 || k <= 0 || lda < if a_trans { m } else { k }
			|| ldb < if b_trans { k } else { n } || ldc < n || a.len < a_required || b.len < b_required
			|| c.len < c_required || alpha == 0 || beta != 0 {
			sgemm_pure(trans_a, trans_b, m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
			return
		}
		C.cblas_sgemm(101, int(trans_a), int(trans_b), m, n, k, alpha, unsafe { &a[0] }, lda,
			unsafe { &b[0] }, ldb, beta, unsafe { &c[0] }, ldc)
	} $else {
		sgemm_pure(trans_a, trans_b, m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
	}
}

// dgemm exposes this operation as part of the public API.

// dgemm exposes this operation as part of the public API.
@[inline]
pub fn dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut cc []f64, ldc int) {
	$if vsl_blas_generic_cblas ? {
		// Keep the pure V validation and edge-case behavior. Valid dense matrix
		// multiplication uses the system CBLAS implementation.
		a_trans := trans_a == .trans || trans_a == .conj_trans
		b_trans := trans_b == .trans || trans_b == .conj_trans
		a_required := if a_trans { (k - 1) * lda + m } else { (m - 1) * lda + k }
		b_required := if b_trans { (n - 1) * ldb + k } else { (k - 1) * ldb + n }
		c_required := (m - 1) * ldc + n
		if m <= 0 || n <= 0 || k <= 0 || lda < if a_trans { m } else { k }
			|| ldb < if b_trans { k } else { n } || ldc < n || a.len < a_required || b.len < b_required
			|| cc.len < c_required || alpha == 0 || beta != 0 {
			blas64.dgemm(to_blas64_transpose(trans_a), to_blas64_transpose(trans_b), m, n, k,
				alpha, a, lda, b, ldb, beta, mut cc, ldc)
			return
		}
		C.cblas_dgemm(101, int(trans_a), int(trans_b), m, n, k, alpha, unsafe { &a[0] }, lda,
			unsafe { &b[0] }, ldb, beta, unsafe { &cc[0] }, ldc)
	} $else {
		blas64.dgemm(to_blas64_transpose(trans_a), to_blas64_transpose(trans_b), m, n, k,
			alpha, a, lda, b, ldb, beta, mut cc, ldc)
	}
}

// dgbmv performs a matrix-vector multiplication with a band matrix.

// dgbmv exposes this operation as part of the public API.

// dgbmv exposes this operation as part of the public API.
@[inline]
pub fn dgbmv(trans_a Transpose, m int, n int, kl int, ku int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dgbmv(to_blas64_transpose(trans_a), m, n, kl, ku, alpha, a, lda, x, incx, beta, mut y,
		incy)
}

// dsymv performs a matrix-vector multiplication for a symmetric matrix.

// dsymv exposes this operation as part of the public API.

// dsymv exposes this operation as part of the public API.
@[inline]
pub fn dsymv(uplo Uplo, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dsymv(to_blas64_uplo(uplo), n, alpha, a, lda, x, incx, beta, mut y, incy)
}

// dsbmv performs a matrix-vector multiplication with a symmetric band matrix.

// dsbmv exposes this operation as part of the public API.

// dsbmv exposes this operation as part of the public API.
@[inline]
pub fn dsbmv(uplo Uplo, n int, k int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dsbmv(to_blas64_uplo(uplo), n, k, alpha, a, lda, x, incx, beta, mut y, incy)
}

// dtbmv performs a matrix-vector multiplication with a triangular band matrix.

// dtbmv exposes this operation as part of the public API.

// dtbmv exposes this operation as part of the public API.
@[inline]
pub fn dtbmv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtbmv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag), n,
		k, a, lda, mut x, incx)
}

// dtbsv solves a system of linear equations with a triangular band matrix.

// dtbsv exposes this operation as part of the public API.

// dtbsv exposes this operation as part of the public API.
@[inline]
pub fn dtbsv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, k int, a []f64, lda int, mut x []f64, incx int) {
	blas64.dtbsv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag), n,
		k, a, lda, mut x, incx)
}

// dtpmv performs a matrix-vector multiplication with a triangular packed matrix.

// dtpmv exposes this operation as part of the public API.

// dtpmv exposes this operation as part of the public API.
@[inline]
pub fn dtpmv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	blas64.dtpmv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag), n,
		ap, mut x, incx)
}

// dtpsv solves a system of linear equations with a triangular packed matrix.

// dtpsv exposes this operation as part of the public API.

// dtpsv exposes this operation as part of the public API.
@[inline]
pub fn dtpsv(uplo Uplo, trans_a Transpose, diag Diagonal, n int, ap []f64, mut x []f64, incx int) {
	blas64.dtpsv(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), to_blas64_diagonal(diag), n,
		ap, mut x, incx)
}

// dspmv performs a matrix-vector multiplication with a symmetric packed matrix.

// dspmv exposes this operation as part of the public API.

// dspmv exposes this operation as part of the public API.
@[inline]
pub fn dspmv(uplo Uplo, n int, alpha f64, ap []f64, x []f64, incx int, beta f64, mut y []f64, incy int) {
	blas64.dspmv(to_blas64_uplo(uplo), n, alpha, ap, x, incx, beta, mut y, incy)
}

// dspr performs a symmetric rank-1 update for a packed matrix.

// dspr exposes this operation as part of the public API.

// dspr exposes this operation as part of the public API.
@[inline]
pub fn dspr(uplo Uplo, n int, alpha f64, x []f64, incx int, mut ap []f64) {
	blas64.dspr(to_blas64_uplo(uplo), n, alpha, x, incx, mut ap)
}

// dspr2 performs a symmetric rank-2 update for a packed matrix.

// dspr2 exposes this operation as part of the public API.

// dspr2 exposes this operation as part of the public API.
@[inline]
pub fn dspr2(uplo Uplo, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut ap []f64) {
	blas64.dspr2(to_blas64_uplo(uplo), n, alpha, x, incx, y, incy, mut ap)
}

// dsyrk performs a symmetric rank-k update.

// dsyrk exposes this operation as part of the public API.

// dsyrk exposes this operation as part of the public API.
@[inline]
pub fn dsyrk(uplo Uplo, trans_a Transpose, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	blas64.dsyrk(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), n, k, alpha, a, lda, beta, mut
		c, ldc)
}

// dsyr2k performs a symmetric rank-2k update.

// dsyr2k exposes this operation as part of the public API.

// dsyr2k exposes this operation as part of the public API.
@[inline]
pub fn dsyr2k(uplo Uplo, trans_a Transpose, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	blas64.dsyr2k(to_blas64_uplo(uplo), to_blas64_transpose(trans_a), n, k, alpha, a, lda, b, ldb,
		beta, mut c, ldc)
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

// dtrsm exposes this operation as part of the public API.

// dtrsm exposes this operation as part of the public API.
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
