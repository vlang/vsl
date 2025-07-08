module lapack

import math
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
pub fn dgeev(calc_vl LeftEigenVectorsJob, calc_vr RightEigenVectorsJob, n int, mut a []f64, lda int, wr []f64, wi []f64, mut vl []f64, ldvl_ int, mut vr []f64, ldvr_ int) {
	mut vvl := 0.0
	mut vvr := 0.0
	mut ldvl := ldvl_
	mut ldvr := ldvr_
	if calc_vl == .left_ev_compute {
		vvl = vl[0]
	} else {
		ldvl = 1
	}
	if calc_vr == .right_ev_compute {
		vvr = vr[0]
	} else {
		ldvr = 1
	}

	vl[0] = vvl
	vr[0] = vvr

	info := lapack64.dgeev(to_lapack64_left_eigen_vectors_job(calc_vl), to_lapack64_right_eigen_vectors_job(calc_vr),
		n, mut a, lda, wr, wi, mut vl, ldvl, mut vr, ldvr)
	if info != 0 {
		errors.vsl_panic('LAPACK dgesvd failed with error code: ${info}', .efailed)
	}
}

// ========================================================================
// HIGH-LEVEL WRAPPER FUNCTIONS
// These functions provide a convenient interface for 2D matrix operations
// ========================================================================

// gesv solves the linear system A*X = B using LU factorization with partial pivoting.
// A is an n×n matrix and B is an n×nrhs matrix.
// On return, A is overwritten with the LU factorization and B contains the solution X.
pub fn gesv(mut a [][]f64, mut b [][]f64) ! {
	if a.len == 0 || a[0].len == 0 {
		return error('gesv: matrix A is empty')
	}
	if b.len == 0 || b[0].len == 0 {
		return error('gesv: matrix B is empty')
	}

	n := a.len
	nrhs := b[0].len

	// Check dimensions
	if a[0].len != n {
		return error('gesv: matrix A is not square')
	}
	if b.len != n {
		return error('gesv: dimension mismatch between A and B')
	}

	// Flatten matrices to 1D arrays (column-major storage)
	mut a_flat := []f64{len: n * n}
	ldb := int_max(n, nrhs)  // Leading dimension must be at least max(n, nrhs)
	mut b_flat := []f64{len: ldb * nrhs}
	mut ipiv := []int{len: n}

	// Convert A from row-major to column-major
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[j * n + i] = a[i][j]  // column-major: A[i,j] -> a_flat[j*n + i]
		}
	}

	// Convert B from row-major to column-major
	for i in 0 .. n {
		for j in 0 .. nrhs {
			b_flat[j * ldb + i] = b[i][j]  // column-major: B[i,j] -> b_flat[j*ldb + i]
		}
	}

	// Call lapack64 function
	lapack64.dgesv(n, nrhs, mut a_flat, n, mut ipiv, mut b_flat, ldb)

	// Convert result back to row-major 2D arrays
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[j * n + i]  // Convert back from column-major
		}
	}

	for i in 0 .. n {
		for j in 0 .. nrhs {
			b[i][j] = b_flat[j * ldb + i]  // Convert back from column-major
		}
	}
}

// getrf computes the LU factorization of a general m×n matrix A using partial pivoting.
// On return, A contains the LU factorization and the function returns the pivot indices.
pub fn getrf(mut a [][]f64) ![]int {
	if a.len == 0 || a[0].len == 0 {
		return error('getrf: matrix A is empty')
	}

	m := a.len
	n := a[0].len

	// Flatten matrix to 1D array (column-major storage)
	mut a_flat := []f64{len: m * n}
	mut ipiv := []int{len: int_min(m, n)}

	// Convert A from row-major to column-major
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[j * m + i] = a[i][j]  // column-major: A[i,j] -> a_flat[j*m + i]
		}
	}

	// Call lapack64 function
	lapack64.dgetrf(m, n, mut a_flat, m, mut ipiv)

	// Convert result back to row-major 2D array
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_flat[j * m + i]  // Convert back from column-major
		}
	}

	return ipiv
}

// getri computes the inverse of a matrix using the LU factorization computed by getrf.
// A should contain the LU factorization from getrf, and ipiv should be the pivot indices.
pub fn getri(mut a [][]f64, mut ipiv []int) ! {
	if a.len == 0 || a[0].len == 0 {
		return error('getri: matrix A is empty')
	}

	n := a.len
	if a[0].len != n {
		return error('getri: matrix A is not square')
	}

	// Flatten matrix to 1D array (column-major storage)
	mut a_flat := []f64{len: n * n}

	// Convert A from row-major to column-major
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[j * n + i] = a[i][j]  // column-major: A[i,j] -> a_flat[j*n + i]
		}
	}

	// Call lapack64 function
	lapack64.dgetri(n, mut a_flat, n, mut ipiv)

	// Convert result back to row-major 2D array
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[j * n + i]  // Convert back from column-major
		}
	}
}

// potrf computes the Cholesky factorization of a symmetric positive definite matrix.
// uplo specifies whether the upper or lower triangle of A is stored.
pub fn potrf(mut a [][]f64, uplo blas.Uplo) ! {
	if a.len == 0 || a[0].len == 0 {
		return error('potrf: matrix A is empty')
	}

	n := a.len
	if a[0].len != n {
		return error('potrf: matrix A is not square')
	}

	// Flatten matrix to 1D array (column-major storage)
	mut a_flat := []f64{len: n * n}

	// Convert A from row-major to column-major
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[j * n + i] = a[i][j]  // column-major: A[i,j] -> a_flat[j*n + i]
		}
	}

	// Call lapack64 function
	lapack64.dpotrf(uplo, n, mut a_flat, n)

	// Convert result back to row-major 2D array
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[j * n + i]  // Convert back from column-major
		}
	}
}

// geev computes the eigenvalues and, optionally, the left and/or right eigenvectors
// for a real nonsymmetric matrix A.
// NOTE: This is a placeholder implementation - the actual dgeev in lapack64 needs to be fixed
pub fn geev(a [][]f64, jobvl LeftEigenVectorsJob, jobvr RightEigenVectorsJob) !([]f64, []f64, [][]f64, [][]f64) {
	if a.len == 0 || a[0].len == 0 {
		return error('geev: matrix A is empty')
	}

	n := a.len
	if a[0].len != n {
		return error('geev: matrix A is not square')
	}

	// For now, return placeholder results until dgeev is properly implemented
	wr := []f64{len: n, init: 0.0}
	wi := []f64{len: n, init: 0.0}
	vl_2d := [][]f64{len: if jobvl == .left_ev_compute { n } else { 0 }, init: []f64{len: if jobvl == .left_ev_compute { n } else { 0 }}}
	vr_2d := [][]f64{len: if jobvr == .right_ev_compute { n } else { 0 }, init: []f64{len: if jobvr == .right_ev_compute { n } else { 0 }}}

	return wr, wi, vl_2d, vr_2d
}

// syev computes all eigenvalues and, optionally, eigenvectors of a real symmetric matrix A.
// NOTE: This is a placeholder implementation - the actual dsyev needs proper work array handling
pub fn syev(mut a [][]f64, jobz EigenVectorsJob, uplo blas.Uplo) ![]f64 {
	if a.len == 0 || a[0].len == 0 {
		return error('syev: matrix A is empty')
	}

	n := a.len
	if a[0].len != n {
		return error('syev: matrix A is not square')
	}

	// Flatten matrix to 1D array (column-major storage)
	mut a_flat := []f64{len: n * n}
	mut w := []f64{len: n}
	mut work := []f64{len: math.max(1, 3 * n - 1)}

	// Convert A from row-major to column-major
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[j * n + i] = a[i][j]  // column-major: A[i,j] -> a_flat[j*n + i]
		}
	}

	// Call lapack64 function
	lapack64.dsyev(to_lapack64_eigen_vectors_job(jobz), uplo, n, mut a_flat, n, mut w, mut work, work.len)

	// Convert eigenvectors back to row-major 2D array (if computed)
	if jobz == .ev_compute {
		for i in 0 .. n {
			for j in 0 .. n {
				a[i][j] = a_flat[j * n + i]  // Convert back from column-major
			}
		}
	}

	return w
}

// geqrf computes a QR factorization of a real m×n matrix A.
// NOTE: This is a placeholder implementation - dgeqrf is not implemented in lapack64 yet
pub fn geqrf(mut a [][]f64) ![]f64 {
	if a.len == 0 || a[0].len == 0 {
		return error('geqrf: matrix A is empty')
	}

	m := a.len
	n := a[0].len

	// Return placeholder tau array until dgeqrf is implemented
	tau := []f64{len: int_min(m, n), init: 0.0}
	return tau
}

// orgqr generates the m×n matrix Q with orthonormal columns defined as the
// first n columns of a product of k elementary reflectors of order m.
// NOTE: This is a placeholder implementation - need proper dorgqr implementation
pub fn orgqr(mut a [][]f64, tau []f64) ! {
	if a.len == 0 || a[0].len == 0 {
		return error('orgqr: matrix A is empty')
	}

	m := a.len
	n := a[0].len
	k := tau.len

	// Flatten matrix to 1D array (column-major storage)
	mut a_flat := []f64{len: m * n}
	mut work := []f64{len: math.max(1, n)}

	// Convert A from row-major to column-major
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[j * m + i] = a[i][j]  // column-major: A[i,j] -> a_flat[j*m + i]
		}
	}

	// Call lapack64 function
	lapack64.dorgqr(m, n, k, mut a_flat, m, tau, mut work, work.len)

	// Convert result back to row-major 2D array
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_flat[j * m + i]  // Convert back from column-major
		}
	}
}

// gesvd computes the singular value decomposition (SVD) of a real m×n matrix A.
// NOTE: This is a placeholder implementation - dgesvd needs proper implementation
pub fn gesvd(a [][]f64, jobu SVDJob, jobvt SVDJob) !([]f64, [][]f64, [][]f64) {
	if a.len == 0 || a[0].len == 0 {
		return error('gesvd: matrix A is empty')
	}

	m := a.len
	n := a[0].len
	min_mn := int_min(m, n)

	// Flatten matrix to 1D array (column-major storage)
	mut a_flat := []f64{len: m * n}
	mut s := []f64{len: min_mn}
	mut superb := []f64{len: min_mn - 1}

	// Determine dimensions for U and VT based on job parameters
	u_cols := match jobu {
		.svd_all { m }
		.svd_store { min_mn }
		else { 0 }
	}
	vt_rows := match jobvt {
		.svd_all { n }
		.svd_store { min_mn }
		else { 0 }
	}

	mut u := []f64{len: if u_cols > 0 { m * u_cols } else { 0 }}
	mut vt := []f64{len: if vt_rows > 0 { vt_rows * n } else { 0 }}

	// Convert A from row-major to column-major
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[j * m + i] = a[i][j]  // column-major: A[i,j] -> a_flat[j*m + i]
		}
	}

	// Call lapack64 function
	ldu := if u_cols > 0 { m } else { 1 }
	ldvt := if vt_rows > 0 { vt_rows } else { 1 }

	info := lapack64.dgesvd(to_lapack64_svd_job(jobu), to_lapack64_svd_job(jobvt), m, n,
		mut a_flat, m, s, mut u, ldu, mut vt, ldvt, superb)

	if info != 0 {
		return error('gesvd failed with info=${info}')
	}

	// Convert U and VT back to 2D arrays
	mut u_2d := [][]f64{len: if u_cols > 0 { m } else { 0 }, init: []f64{len: u_cols}}
	mut vt_2d := [][]f64{len: vt_rows, init: []f64{len: if vt_rows > 0 { n } else { 0 }}}

	if u_cols > 0 {
		for i in 0 .. m {
			for j in 0 .. u_cols {
				u_2d[i][j] = u[j * m + i]  // Convert back from column-major
			}
		}
	}

	if vt_rows > 0 {
		for i in 0 .. vt_rows {
			for j in 0 .. n {
				vt_2d[i][j] = vt[j * vt_rows + i]  // Convert back from column-major
			}
		}
	}

	return s, u_2d, vt_2d
}

// Helper function to get minimum of two integers
fn int_min(a int, b int) int {
	if a < b {
		return a
	}
	return b
}

// Helper function to get maximum of two integers
fn int_max(a int, b int) int {
	if a > b {
		return a
	}
	return b
}
