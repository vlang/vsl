module blas

import vsl.blas.vlas

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
        vlas.dgemm(c_trans(transA), c_trans(transB), m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)   
}
