// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module blas

import vsl.errno

#include <cblas.h>
#include <lapacke.h>
fn C.openblas_set_num_threads(n int)

fn C.cblas_ddot(n int, dx &f64, incx int, dy &f64, incy int) f64

fn C.cblas_dscal(n int, alpha f64, x []f64, incx int) f64

fn C.cblas_dger(m int, n int, alpha f64, x &f64, incx int, y &f64, incy int, a &f64, lda int)

fn C.cblas_dnrm2(n int, x &f64, incx int) f64

fn C.cblas_idamax(n int, x &f64, incx int) int

fn C.cblas_daxpy(n int, alpha f64, x &f64, incx int, y &f64, incy int)

fn C.cblas_dgemv(trans byte, m int, n int, alpha f64, a &f64, lda int, x &f64, incx int, beta f64, y &f64, incy int)

fn C.cblas_dgemm(trans byte, m int, n int, k int, alpha f64, a &f64, lda int, b &f64, ldb int, c &f64, ldc int)

fn C.cblas_dsyrk(cblas_col_major u32, up u32, trans u32, n int, k int, alpha f64, a &f64, lda int, beta f64, c &f64, ldc int)

fn C.LAPACKE_dgesv(n int, nrhs int, a &f64, lda int, ipiv &int, b &f64, ldb int) int

fn C.LAPACKE_dgesvd(jobu byte, jobvt byte, m int, n int, a &f64, lda int, s &f64, u &f64, ldu int, vt &f64, ldvt int, superb &f64) int

fn C.LAPACKE_dgetrf(m int, n int, a &f64, lda int, ipiv &int) int

fn C.LAPACKE_dgetri(n int, a &f64, lda int, ipiv &int) int

fn C.LAPACKE_dpotrf(lapack_col_major int, up u32, n int, a &f64, lda int) int

fn C.LAPACKE_dgeev(lapack_col_major int, calcVl byte, calcVr byte, n int, a &f64, lda int, wr &f64, wi &f64, vl &f64, ldvl_ int, vr &f64, ldvr_ int) int

fn C.LAPACKE_dlange(norm byte, m int, n int, a &f64, lda int, work &f64) f64

fn C.LAPACKE_dsyev(jobz byte, uplo byte, n int, a &f64, lda int, w &f64, work &f64, lwork int, info &int)

fn C.LAPACKE_dgebal(job byte, n int, a &f64, lda int, ilo int, ihi int, scale &f64, info &int)

fn C.LAPACKE_dgehrd(n int, ilo int, ihi int, a &f64, lda int, tau &f64, work &f64, lwork int, info &int)

// set_num_threads sets the number of threads in OpenBLAS
pub fn set_num_threads(n int) {
	C.openblas_set_num_threads(n)
}

// ddot forms the dot product of two vectors. Uses unrolled loops for increments equal to one.
//
// See: http://www.netlib.org/lapack/explore-html/d5/df6/ddot_8f.html
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return C.cblas_ddot(n, &x[0], incx, &y[0], incy)
}

// dscal scales a vector by a constant. Uses unrolled loops for increment equal to 1.
//
// See: http://www.netlib.org/lapack/explore-html/d4/dd0/dscal_8f.html
pub fn dscal(n int, alpha f64, x []f64, incx int) {
	C.cblas_dscal(n, alpha, &x[0], incx)
}

// daxpy computes constant times a vector plus a vector.
//
// See: http://www.netlib.org/lapack/explore-html/d9/dcd/daxpy_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-axpy
//
// y += alpha*x + y
//
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	unsafe {C.cblas_daxpy(n, alpha, &x[0], incx, &y[0], incy)}
}

// zaxpy computes constant times a vector plus a vector.
//
// See: http://www.netlib.org/lapack/explore-html/d7/db2/zaxpy_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-axpy
//
// y += alpha*x + y
//
// pub fn zaxpy(n int, alpha complex128, x []complex128, incx int, y mut []complex128, incy int) {
// C.cblas_zaxpy(n, &alpha, &x[0], incx, &y[0], incy)
// }
// dgemv performs one of the matrix-vector operations
//
// See: http://www.netlib.org/lapack/explore-html/dc/da8/dgemv_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-gemv
//
// y := alpha*A*x + beta*y,   or   y := alpha*A**T*x + beta*y,
//
// where alpha and beta are scalars, x and y are vectors and A is an
// m by n matrix.
// trans=false     y := alpha*A*x + beta*y.
//
// trans=true      y := alpha*A**T*x + beta*y.
pub fn dgemv(trans bool, m int, n int, alpha f64, a []f64, lda int, x []f64, incx int, beta f64, mut y []f64, incy int) {
	unsafe {C.cblas_dgemv(cblas_col_major, c_trans(trans), m, n, alpha, &a[0], lda, &x[0],
		incx, beta, &y[0], incy)}
}

// zgemv performs one of the matrix-vector operations.
//
// See: http://www.netlib.org/lapack/explore-html/db/d40/zgemv_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-gemv
//
// y := alpha*A*x + beta*y,   or   y := alpha*A**T*x + beta*y,   or
//
// y := alpha*A**H*x + beta*y,
//
// where alpha and beta are scalars, x and y are vectors and A is an
// m by n matrix.
// pub fn zgemv(trans bool, m, n int, alpha complex128, a []complex128, lda int, x []complex128, incx int, beta complex128, y mut []complex128, incy int) {
// C.cblas_zgemv(cblas_col_major, c_trans(trans), m, n, &alpha, &a[0], lda, &x[0], incx, &beta, &y[0], incy)
// }
// dger performs the rank 1 operation
//
// See: http://www.netlib.org/lapack/explore-html/dc/da8/dger_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-ger
//
// A := alpha*x*y**T + A,
//
// where alpha is a scalar, x is an m element vector, y is an n element
// vector and A is an m by n matrix.
pub fn dger(m int, n int, alpha f64, x []f64, incx int, y []f64, incy int, mut a []f64, lda int) {
	unsafe {C.cblas_dger(cblas_col_major, m, n, alpha, &x[0], incx, &y[0], incy, &a[0],
		lda)}
}

pub fn dnrm2(n int, x []f64, incx int) f64 {
	return unsafe {C.cblas_dnrm2(n, &x[0], incx)}
}

// dgemm performs one of the matrix-matrix operations
//
// false,false:  C_{m,n} := α ⋅ A_{m,k} ⋅ B_{k,n}  +  β ⋅ C_{m,n}
// false,true:   C_{m,n} := α ⋅ A_{m,k} ⋅ B_{n,k}  +  β ⋅ C_{m,n}
// true, false:  C_{m,n} := α ⋅ A_{k,m} ⋅ B_{k,n}  +  β ⋅ C_{m,n}
// true, true:   C_{m,n} := α ⋅ A_{k,m} ⋅ B_{n,k}  +  β ⋅ C_{m,n}
//
// see: http://www.netlib.org/lapack/explore-html/d7/d2b/dgemm_8f.html
//
// see: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-gemm
//
// C := alpha*op( A )*op( B ) + beta*C,
//
// where  op( X ) is one of
//
// op( X ) = X   or   op( X ) = X**T,
//
// alpha and beta are scalars, and A, B and C are matrices, with op( A )
// an m by k matrix,  op( B )  a  k by n matrix and  C an m by n matrix.
pub fn dgemm(transA bool, transB bool, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	unsafe {C.cblas_dgemm(cblas_col_major, c_trans(transA), c_trans(transB), m, n, k,
		alpha, &a[0], lda, &b[0], ldb, beta, &c[0], ldc)}
}

// zgemm performs one of the matrix-matrix operations
//
// see: http://www.netlib.org/lapack/explore-html/d7/d76/zgemm_8f.html
//
// see: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-gemm
//
// C := alpha*op( A )*op( B ) + beta*C,
//
// where  op( X ) is one of
//
// op( X ) = X   or   op( X ) = X**T   or   op( X ) = X**H,
//
// alpha and beta are scalars, and A, B and C are matrices, with op( A )
// an m by k matrix,  op( B )  a  k by n matrix and  C an m by n matrix.
// pub fn zgemm(transA, transB bool, m, n, k int, alpha complex128, a []complex128, lda int, b []complex128, ldb int, beta complex128, c []complex128, ldc int) {
// C.cblas_zgemm(cblas_col_major, c_trans(transA), c_trans(transB), m, n, k, &alpha, &a[0], lda, &b[0], ldb, &beta, &c[0], ldc)
// }
// dgesv computes the solution to a real system of linear equations.
//
// See: http://www.netlib.org/lapack/explore-html/d8/d72/dgesv_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-gesv
//
// The system is:
//
// A * X = B,
//
// where A is an N-by-N matrix and X and B are N-by-NRHS matrices.
//
// The LU decomposition with partial pivoting and row interchanges is
// used to factor A as
//
// A = P * L * U,
//
// where P is a permutation matrix, L is unit lower triangular, and U is
// upper triangular.  The factored form of A is then used to solve the
// system of equations A * X = B.
//
// NOTE: matrix 'a' will be modified
pub fn dgesv(n int, nrhs int, mut a []f64, lda int, ipiv []int, mut b []f64, ldb int) {
	if ipiv.len != n {
		errno.vsl_panic('ipiv.len must be equal to n. $ipiv.len != $n\n', .efailed)
	}
	info := C.LAPACKE_dgesv(lapack_col_major, n, nrhs, unsafe {&a[0]}, lda, &ipiv[0],
		unsafe {&b[0]}, ldb)
	if info != 0 {
		errno.vsl_panic('lapack failed', .efailed)
	}
}

// zgesv computes the solution to a complex system of linear equations.
//
// See: http://www.netlib.org/lapack/explore-html/d1/ddc/zgesv_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-gesv
//
// The system is:
//
// A * X = B,
//
// where A is an N-by-N matrix and X and B are N-by-NRHS matrices.
//
// The LU decomposition with partial pivoting and row interchanges is
// used to factor A as
//
// A = P * L * U,
//
// where P is a permutation matrix, L is unit lower triangular, and U is
// upper triangular.  The factored form of A is then used to solve the
// system of equations A * X = B.
//
// NOTE: matrix 'a' will be modified
// pub fn zgesv(n, nrhs int, a []complex128, lda int, ipiv []int, b []complex128, ldb int) {
// if ipiv.len != n {
// errno.vsl_panic("ipiv.len must be equal to n. %d != %d\n", ipiv.lenn, .efailed)
// }
// info := C.LAPACKE_zgesv(lapack_col_major, n, nrhs, &a[0], lda, &ipiv[0], &b[0], ldb)
// if info != 0 {
// errno.vsl_panic("lapack failed", .efailed)
// }
// }
// dgesvd computes the singular value decomposition (SVD) of a real M-by-N matrix A, optionally computing the left and/or right singular vectors.
//
// See: http://www.netlib.org/lapack/explore-html/d8/d2d/dgesvd_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-gesvd
//
// The SVD is written
//
// A = U * SIGMA * transpose(V)
//
// where SIGMA is an M-by-N matrix which is zero except for its
// min(m,n) diagonal elements, U is an M-by-M orthogonal matrix, and
// V is an N-by-N orthogonal matrix.  The diagonal elements of SIGMA
// are the singular values of A; they are real and non-negative, and
// are returned in descending order.  The first min(m,n) columns of
// U and V are the left and right singular vectors of A.
//
// Note that the routine returns V**T, not V.
//
// NOTE: matrix 'a' will be modified
pub fn dgesvd(jobu byte, jobvt byte, m int, n int, a []f64, lda int, s []f64, u []f64, ldu int, vt []f64, ldvt int, superb []f64) {
	info := C.LAPACKE_dgesvd(lapack_col_major, jobu, jobvt, m, n, &a[0], lda, &s[0], &u[0],
		ldu, &vt[0], ldvt, &superb[0])
	if info != 0 {
		errno.vsl_panic('lapack failed', .efailed)
	}
}

// zgesvd computes the singular value decomposition (SVD) of a complex M-by-N matrix A, optionally computing the left and/or right singular vectors.
//
// See: http://www.netlib.org/lapack/explore-html/d6/d42/zgesvd_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-gesvd
//
// The SVD is written
//
// A = U * SIGMA * conjugate-transpose(V)
//
// where SIGMA is an M-by-N matrix which is zero except for its
// min(m,n) diagonal elements, U is an M-by-M unitary matrix, and
// V is an N-by-N unitary matrix.  The diagonal elements of SIGMA
// are the singular values of A; they are real and non-negative, and
// are returned in descending order.  The first min(m,n) columns of
// U and V are the left and right singular vectors of A.
//
// Note that the routine returns V**H, not V.
//
// NOTE: matrix 'a' will be modified
// pub fn zgesvd(jobu, jobvt byte, m, n int, a []complex128, lda int, s []f64, u []complex128, ldu int, vt []complex128, ldvt int, superb []f64) {
// info := C.LAPACKE_zgesvd(lapack_col_major, jobu, jobvt, m, n, &a[0], lda, &s[0], &u[0], ldu, &vt[0], ldvt, &superb[0])
// if info != 0 {
// errno.vsl_panic("lapack failed", .efailed)
// }
// }
// dgetrf computes an LU factorization of a general M-by-N matrix A using partial pivoting with row interchanges.
//
// See: http://www.netlib.org/lapack/explore-html/d3/d6a/dgetrf_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-getrf
//
// The factorization has the form
// A = P * L * U
// where P is a permutation matrix, L is lower triangular with unit
// diagonal elements (lower trapezoidal if m > n), and U is upper
// triangular (upper trapezoidal if m < n).
//
// This is the right-looking Level 3 BLAS version of the algorithm.
//
// NOTE: (1) matrix 'a' will be modified
// (2) ipiv indices are 1-based (i.e. Fortran)
pub fn dgetrf(m int, n int, mut a []f64, lda int, ipiv []int) {
	unsafe {
		info := C.LAPACKE_dgetrf(lapack_col_major, m, n, &a[0], lda, &ipiv[0])
		if info != 0 {
			errno.vsl_panic('lapack failed', .efailed)
		}
	}
}

// zgetrf computes an LU factorization of a general M-by-N matrix A using partial pivoting with row interchanges.
//
// See: http://www.netlib.org/lapack/explore-html/dd/dd1/zgetrf_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-getrf
//
// The factorization has the form
// A = P * L * U
// where P is a permutation matrix, L is lower triangular with unit
// diagonal elements (lower trapezoidal if m > n), and U is upper
// triangular (upper trapezoidal if m < n).
//
// This is the right-looking Level 3 BLAS version of the algorithm.
//
// NOTE: (1) matrix 'a' will be modified
// (2) ipiv indices are 1-based (i.e. Fortran)
// pub fn zgetrf(m, n int, a []complex128, lda int, ipiv []int) {
// info := C.LAPACKE_zgetrf(lapack_col_major, m, n, &a[0], lda, &ipiv[0])
// if info != 0 {
// errno.vsl_panic("lapack failed", .efailed)
// }
// }
// dgetri computes the inverse of a matrix using the LU factorization computed by DGETRF.
//
// See: http://www.netlib.org/lapack/explore-html/df/da4/dgetri_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-getri
//
// This method inverts U and then computes inv(A) by solving the system
// inv(A)*L = inv(U) for inv(A).
pub fn dgetri(n int, mut a []f64, lda int, ipiv []int) {
	unsafe {
		info := C.LAPACKE_dgetri(lapack_col_major, n, &a[0], lda, &ipiv[0])
		if info != 0 {
			errno.vsl_panic('lapack failed', .efailed)
		}
	}
}

// zgetri computes the inverse of a matrix using the LU factorization computed by zgetrf.
//
// See: http://www.netlib.org/lapack/explore-html/d0/db3/zgetri_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-getri
//
// This method inverts U and then computes inv(A) by solving the system
// inv(A)*L = inv(U) for inv(A).
// pub fn zgetri(n int, a []complex128, lda int, ipiv []int) {
// info := C.LAPACKE_zgetri(lapack_col_major, n, &a[0], lda, &ipiv[0])
// if info != 0 {
// errno.vsl_panic("lapack failed", .efailed)
// }
// }
// dsyrk performs one of the symmetric rank k operations
//
// See: http://www.netlib.org/lapack/explore-html/dc/d05/dsyrk_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-syrk
//
// C := alpha*A*A**T + beta*C,
//
// or
//
// C := alpha*A**T*A + beta*C,
//
// where  alpha and beta  are scalars, C is an  n by n  symmetric matrix
// and  A  is an  n by k  matrix in the first case and a  k by n  matrix
// in the second case.
pub fn dsyrk(up bool, trans bool, n int, k int, alpha f64, a []f64, lda int, beta f64, mut c []f64, ldc int) {
	unsafe {C.cblas_dsyrk(cblas_col_major, c_uplo(up), c_trans(trans), n, k, alpha, &a[0],
		lda, beta, &c[0], ldc)}
}

// zsyrk performs one of the symmetric rank k operations
//
// See: http://www.netlib.org/lapack/explore-html/de/d54/zsyrk_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-syrk
//
// C := alpha*A*A**T + beta*C,
//
// or
//
// C := alpha*A**T*A + beta*C,
//
// where  alpha and beta  are scalars,  C is an  n by n symmetric matrix
// and  A  is an  n by k  matrix in the first case and a  k by n  matrix
// in the second case.
// pub fn zsyrk(up, trans bool, n, k int, alpha complex128, a []complex128, lda int, beta complex128, c []complex128, ldc int) {
// C.cblas_zsyrk(cblas_col_major, c_uplo(up), c_trans(trans), n, k, &alpha, &a[0], lda, &beta, &c[0], ldc)
// }
// zherk performs one of the hermitian rank k operations
//
// See: http://www.netlib.org/lapack/explore-html/d1/db1/zherk_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-herk
//
// C := alpha*A*A**H + beta*C,
//
// or
//
// C := alpha*A**H*A + beta*C,
//
// where  alpha and beta  are  real scalars,  C is an  n by n  hermitian
// matrix and  A  is an  n by k  matrix in the  first case and a  k by n
// matrix in the second case.
// pub fn zherk(up, trans bool, n, k int, alpha f64, a []complex128, lda int, beta f64, c []complex128, ldc int) {
// C.cblas_zherk(cblas_col_major, c_uplo(up), c_trans(trans), n, k, alpha, &a[0], lda, beta, &c[0], ldc)
// }
// dpotrf computes the Cholesky factorization of a real symmetric positive definite matrix A.
//
// See: http://www.netlib.org/lapack/explore-html/d0/d8a/dpotrf_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-potrf
//
// The factorization has the form
//
// A = U**T * U,  if UPLO = 'U'
//
// or
//
// A = L  * L**T,  if UPLO = 'L'
//
// where U is an upper triangular matrix and L is lower triangular.
//
// This is the block version of the algorithm, calling Level 3 BLAS.
pub fn dpotrf(up bool, n int, mut a []f64, lda int) {
	unsafe {
		info := C.LAPACKE_dpotrf(lapack_col_major, l_uplo(up), n, &a[0], lda)
		if info != 0 {
			errno.vsl_panic('lapack failed', .efailed)
		}
	}
}

// zpotrf computes the Cholesky factorization of a complex Hermitian positive definite matrix A.
//
// See: http://www.netlib.org/lapack/explore-html/d1/db9/zpotrf_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-potrf
//
// The factorization has the form
//
// A = U**H * U,  if UPLO = 'U'
//
// or
//
// A = L  * L**H,  if UPLO = 'L'
//
// where U is an upper triangular matrix and L is lower triangular.
//
// This is the block version of the algorithm, calling Level 3 BLAS.
// pub fn zpotrf(up bool, n int, a []complex128, lda int) {
// info := C.LAPACKE_zpotrf(lapack_col_major, l_uplo(up), n, &a[0], lda,
// )
// if info != 0 {
// errno.vsl_panic("lapack failed", .efailed)
// }
// }
// dgeev computes for an N-by-N real nonsymmetric matrix A, the
// eigenvalues and, optionally, the left and/or right eigenvectors.
//
// See: http://www.netlib.org/lapack/explore-html/d9/d28/dgeev_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-geev
//
// See: https://www.nag.co.uk/numeric/fl/nagdoc_fl26/html/f08/f08naf.html
//
// The right eigenvector v(j) of A satisfies
//
// A * v(j) = lambda(j) * v(j)
//
// where lambda(j) is its eigenvalue.
//
// The left eigenvector u(j) of A satisfies
//
// u(j)**H * A = lambda(j) * u(j)**H
//
// where u(j)**H denotes the conjugate-transpose of u(j).
//
// The computed eigenvectors are normalized to have Euclidean norm
// equal to 1 and largest component real.
pub fn dgeev(calcVl bool, calcVr bool, n int, mut a []f64, lda int, wr []f64, wi []f64, vl []f64, ldvl_ int, vr []f64, ldvr_ int) {
	mut vvl := 0.0
	mut vvr := 0.0
	mut ldvl := ldvl_
	mut ldvr := ldvr_
	if calcVl {
		vvl = &vl[0]
	} else {
		ldvl = 1
	}
	if calcVr {
		vvr = &vr[0]
	} else {
		ldvr = 1
	}
	unsafe {
		info := C.LAPACKE_dgeev(lapack_col_major, job_vlr(calcVl), job_vlr(calcVr), n,
			&a[0], lda, &wr[0], &wi[0], &vvl, ldvl, &vvr, ldvr)
		if info != 0 {
			errno.vsl_panic('lapack failed', .efailed)
		}
	}
}

pub fn dlange(norm byte, m int, n int, a []f64, lda int, work []f64) f64 {
	return unsafe {C.LAPACKE_dlange(norm, m, n, &a[0], lda, &work[0])}
}

// auxiliary //////////////////////////////////////////////////////////////////////////////////////
// constants
pub const (
	lapack_row_major    = 101
	lapack_col_major    = 102
	cblas_row_major     = u32(101)
	cblas_col_major     = u32(102)
	cblas_no_trans      = u32(111)
	cblas_trans         = u32(112)
	cblas_conj_trans    = u32(113)
	cblas_conj_no_trans = u32(114)
	cblas_upper         = u32(121)
	cblas_lower         = u32(122)
	cblas_non_unit      = u32(131)
	cblas_unit          = u32(132)
	cblas_left          = u32(141)
	cblas_right         = u32(142)
)

pub fn c_trans(trans bool) u32 {
	if trans {
		return cblas_trans
	}
	return cblas_no_trans
}

pub fn c_uplo(up bool) u32 {
	if up {
		return cblas_upper
	}
	return cblas_lower
}

pub fn l_uplo(up bool) byte {
	if up {
		return `U`
	}
	return `L`
}

pub fn job_vlr(doCalc bool) byte {
	if doCalc {
		return `V`
	}
	return `N`
}
