module lapack

import vsl.errors
import vsl.blas

fn C.LAPACKE_dgesv(matrix_layout blas.MemoryLayout, n int, nrhs int, a &f64, lda int, ipiv &int, b &f64, ldb int) int

fn C.LAPACKE_dgesvd(matrix_layout blas.MemoryLayout, jobu &char, jobvt &char, m int, n int, a &f64, lda int, s &f64, u &f64, ldu int, vt &f64, ldvt int, superb &f64) int

fn C.LAPACKE_dgetrf(matrix_layout blas.MemoryLayout, m int, n int, a &f64, lda int, ipiv &int) int

fn C.LAPACKE_dgetri(matrix_layout blas.MemoryLayout, n int, a &f64, lda int, ipiv &int) int

fn C.LAPACKE_dpotrf(matrix_layout blas.MemoryLayout, up u32, n int, a &f64, lda int) int

fn C.LAPACKE_dgeev(matrix_layout blas.MemoryLayout, calc_vl &char, calc_vr &char, n int, a &f64, lda int, wr &f64, wi &f64, vl &f64, ldvl_ int, vr &f64, ldvr_ int) int

fn C.LAPACKE_dsyev(matrix_layout blas.MemoryLayout, jobz byte, uplo byte, n int, a &f64, lda int, w &f64, work &f64, lwork int) int

fn C.LAPACKE_dgebal(matrix_layout blas.MemoryLayout, job &char, n int, a &f64, lda int, ilo int, ihi int, scale &f64) int

fn C.LAPACKE_dgehrd(matrix_layout blas.MemoryLayout, n int, ilo int, ihi int, a &f64, lda int, tau &f64, work &f64, lwork int) int

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
		errors.vsl_panic('ipiv.len must be equal to n. ${ipiv.len} != ${n}\n', .efailed)
	}
	info := C.LAPACKE_dgesv(.row_major, n, nrhs, unsafe { &a[0] }, lda, &ipiv[0], unsafe { &b[0] },
		ldb)
	if info != 0 {
		errors.vsl_panic('lapack failed', .efailed)
	}
}

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
pub fn dgesvd(jobu &char, jobvt &char, m int, n int, a []f64, lda int, s []f64, u []f64, ldu int, vt []f64, ldvt int, superb []f64) {
	info := C.LAPACKE_dgesvd(.row_major, jobu, jobvt, m, n, &a[0], lda, &s[0], &u[0],
		ldu, &vt[0], ldvt, &superb[0])
	if info != 0 {
		errors.vsl_panic('lapack failed', .efailed)
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
pub fn dgetrf(m int, n int, mut a []f64, lda int, ipiv []int) {
	unsafe {
		info := C.LAPACKE_dgetrf(.row_major, m, n, &a[0], lda, &ipiv[0])
		if info != 0 {
			errors.vsl_panic('lapack failed', .efailed)
		}
	}
}

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
		info := C.LAPACKE_dgetri(.row_major, n, &a[0], lda, &ipiv[0])
		if info != 0 {
			errors.vsl_panic('lapack failed', .efailed)
		}
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
pub fn dpotrf(up bool, n int, mut a []f64, lda int) {
	unsafe {
		info := C.LAPACKE_dpotrf(.row_major, blas.l_uplo(up), n, &a[0], lda)
		if info != 0 {
			errors.vsl_panic('lapack failed', .efailed)
		}
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
pub fn dgeev(calc_vl bool, calc_vr bool, n int, mut a []f64, lda int, wr []f64, wi []f64, vl []f64, ldvl_ int, vr []f64, ldvr_ int) {
	mut vvl := 0.0
	mut vvr := 0.0
	mut ldvl := ldvl_
	mut ldvr := ldvr_
	if calc_vl {
		vvl = vl[0]
	} else {
		ldvl = 1
	}
	if calc_vr {
		vvr = vr[0]
	} else {
		ldvr = 1
	}
	unsafe {
		info := C.LAPACKE_dgeev(.row_major, &char(blas.job_vlr(calc_vl).str().str), &char(blas.job_vlr(calc_vr).str().str),
			n, &a[0], lda, &wr[0], &wi[0], &vvl, ldvl, &vvr, ldvr)
		if info != 0 {
			errors.vsl_panic('lapack failed', .efailed)
		}
	}
}
