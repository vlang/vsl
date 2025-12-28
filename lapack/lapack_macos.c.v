module lapack

import vsl.blas

// double LAPACKE_dlange( int matrix_order, char norm, lapack_int m,
//                        lapack_int n, const double* a, lapack_int lda );

// double LAPACKE_dlange_work( int matrix_order, char norm, lapack_int m,
//                             lapack_int n, const double* a, lapack_int lda, double* work );

fn C.LAPACKE_dlange_work(matrix_order blas.MemoryLayout, norm char, m int, n int, const_a &f64, lda int, work &f64) f64

pub fn dlange(norm rune, m int, n int, a []f64, lda int, work []f64) f64 {
	return unsafe { C.LAPACKE_dlange_work(.row_major, char(norm), m, n, &a[0], lda, &work[0]) }
}
