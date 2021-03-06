module blas

import vsl.blas.vlas

// set_num_threads sets the number of threads in VLAS
pub fn set_num_threads(n int) {}

// ddot forms the dot product of two vectors. Uses unrolled loops for increments equal to one.
//
// See: http://www.netlib.org/lapack/explore-html/d5/df6/ddot_8f.html
pub fn ddot(n int, x []f64, incx int, y []f64, incy int) f64 {
	return vlas.ddot(n, x, incx, y, incy)
}

// dscal scales a vector by a constant. Uses unrolled loops for increment equal to 1.
//
// See: http://www.netlib.org/lapack/explore-html/d4/dd0/dscal_8f.html
pub fn dscal(n int, alpha f64, mut x []f64, incx int) {
	vlas.dscal(n, alpha, mut x, incx)
}

// daxpy computes constant times a vector plus a vector.
//
// See: http://www.netlib.org/lapack/explore-html/d9/dcd/daxpy_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-cblas-axpy
//
// y += alpha*x + y
//
[inline]
pub fn daxpy(n int, alpha f64, x []f64, incx int, mut y []f64, incy int) {
	vlas.daxpy(n, alpha, x, incx, mut y, incy)
}

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
	vlas.dgemv(c_trans(trans), m, n, alpha, a, lda, x, incx, beta, mut y, incy)
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
[inline]
pub fn dgemm(trans_a bool, trans_b bool, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	vlas.dgemm(c_trans(trans_a), c_trans(trans_b), m, n, k, alpha, a, lda, b, ldb, beta, mut
		c, ldc)
}

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
	vlas.dger(m, n, alpha, x, incx, y, incy, mut a, lda)
}

[inline]
pub fn dnrm2(n int, x []f64, incx int) f64 {
	return vlas.dnrm2(n, x, incx)
}

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
	vlas.dsyrk(c_uplo(up), c_trans(trans), n, k, alpha, a, lda, beta, mut c, ldc)
}
