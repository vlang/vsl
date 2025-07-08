module lapack

import vsl.errors
import vsl.blas
import vsl.lapack.lapack64

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
@[inline]
pub fn dgesv(n int, nrhs int, mut a []f64, lda int, mut ipiv []int, mut b []f64, ldb int) {
	lapack64.dgesv(n, nrhs, mut a, lda, mut ipiv, mut b, ldb)
}

// dgesvd computes the singular value decomposition (SingularValueDecomposition) of a real M-by-N matrix A, optionally computing the left and/or right singular vectors.
//
// See: http://www.netlib.org/lapack/explore-html/d8/d2d/dgesvd_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-gesvd
//
// The SingularValueDecomposition is written
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
pub fn dgesvd(jobu SVDJob, jobvt SVDJob, m int, n int, mut a []f64, lda int, s []f64, mut u []f64, ldu int, mut vt []f64, ldvt int, superb []f64) {
	info := lapack64.dgesvd(to_lapack64_svd_job(jobu), to_lapack64_svd_job(jobvt), m,
		n, mut a, lda, s, mut u, ldu, mut vt, ldvt, superb)
	if info != 0 {
		errors.vsl_panic('LAPACK dgesvd failed with error code: ${info}', .efailed)
	}
}

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
pub fn dgetrf(m int, n int, mut a []f64, lda int, mut ipiv []int) {
	lapack64.dgetrf(m, n, mut a, lda, mut ipiv)
}

// dgetri computes the inverse of a matrix using the LU factorization computed by DGETRF.
//
// See: http://www.netlib.org/lapack/explore-html/df/da4/dgetri_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-getri
//
// This method inverts U and then computes inv(A) by solving the system
// inv(A)*L = inv(U) for inv(A).
pub fn dgetri(n int, mut a []f64, lda int, mut ipiv []int) {
	info := lapack64.dgetri(n, mut a, lda, mut ipiv)
	if info != 0 {
		errors.vsl_panic('LAPACK dgesvd failed with error code: ${info}', .efailed)
	}
}

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
pub fn dpotrf(uplo blas.Uplo, n int, mut a []f64, lda int) {
	info := lapack64.dpotrf(uplo, n, mut a, lda)
	if !info {
		errors.vsl_panic('LAPACK dgesvd failed with error code: ${info}', .efailed)
	}
}

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
pub fn dgeev(calc_vl LeftEigenVectorsJob, calc_vr LeftEigenVectorsJob, n int, mut a []f64, lda int, wr []f64, wi []f64, mut vl []f64, ldvl_ int, mut vr []f64, ldvr_ int) {
	mut vvl := 0.0
	mut vvr := 0.0
	mut ldvl := ldvl_
	mut ldvr := ldvr_
	if calc_vl == .left_ev_compute {
		vvl = vl[0]
	} else {
		ldvl = 1
	}
	if calc_vr == .left_ev_compute {
		vvr = vr[0]
	} else {
		ldvr = 1
	}

	vl[0] = vvl
	vr[0] = vvr

	info := lapack64.dgeev(to_lapack64_left_eigen_vectors_job(calc_vl), to_lapack64_left_eigen_vectors_job(calc_vr),
		n, mut a, lda, wr, wi, mut vl, ldvl, mut vr, ldvr)
	if info != 0 {
		errors.vsl_panic('LAPACK dgesvd failed with error code: ${info}', .efailed)
	}
}
