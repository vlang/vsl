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
pub fn dgesv(n int, nrhs int, mut a []f64, lda int, mut ipiv []int, mut b []f64, ldb int) int {
	// Validate input assuming row-major format (as used by wrapper functions and la module)
	if n < 0 {
		panic('lapack: n < 0')
	}
	if nrhs < 0 {
		panic('lapack: nrhs < 0')
	}
	if lda < math.max(1, n) {
		panic('lapack: bad leading dimension of A')
	}
	if ldb < math.max(1, nrhs) {
		panic('lapack: bad leading dimension of B')
	}
	// For row-major format: a has n rows, each with lda elements
	// When converting back, we access a[i * lda + j] for i in [0, n-1], j in [0, n-1]
	// Maximum index: (n-1) * lda + (n-1), so we need a.len > (n-1) * lda + (n-1)
	// For dense storage with lda = n: a.len >= n * n
	// But we also need to ensure we can read all elements: a.len >= (n - 1) * lda + n
	min_a_len := math.max((n - 1) * lda + n, n * n)
	if a.len < min_a_len {
		panic('lapack: insufficient length of a (a.len=${a.len}, need ${min_a_len}, n=${n}, lda=${lda})')
	}
	if ipiv.len < n {
		panic('lapack: bad length of ipiv')
	}
	// For row-major: b has n rows, each with ldb elements (ldb >= nrhs)
	// For single column vector (ldb=1, nrhs=1): b.len >= n
	// For general matrix: b.len >= (n - 1) * ldb + nrhs
	// Use the more lenient check: b.len >= n (always true for valid input)
	if b.len < n {
		panic('lapack: insufficient length of b')
	}
	// Solve directly in row-major to avoid extra conversions
	return row_major_dgesv(n, nrhs, mut a, lda, mut ipiv, mut b, ldb)
}

// Simple row-major Gaussian elimination with partial pivoting.
// Mutates a (row-major) and b (row-major) in place.
fn row_major_dgesv(n int, nrhs int, mut a []f64, lda int, mut ipiv []int, mut b []f64, ldb int) int {
	// LU factorization with partial pivoting
	for k in 0 .. n {
		// pivot search
		mut piv := k
		mut maxv := math.abs(a[k * lda + k])
		for i in k + 1 .. n {
			v := math.abs(a[i * lda + k])
			if v > maxv {
				maxv = v
				piv = i
			}
		}
		ipiv[k] = piv + 1 // 1-based to match LAPACK convention
		if maxv == 0 {
			return k + 1 // singular
		}
		// swap rows in A if needed
		if piv != k {
			for j in k .. n {
				a[k * lda + j], a[piv * lda + j] = a[piv * lda + j], a[k * lda + j]
			}
			// swap rows in B
			for j in 0 .. nrhs {
				b[k * ldb + j], b[piv * ldb + j] = b[piv * ldb + j], b[k * ldb + j]
			}
		}
		// elimination
		for i in k + 1 .. n {
			f := a[i * lda + k] / a[k * lda + k]
			a[i * lda + k] = f
			for j in k + 1 .. n {
				a[i * lda + j] -= f * a[k * lda + j]
			}
			for j in 0 .. nrhs {
				b[i * ldb + j] -= f * b[k * ldb + j]
			}
		}
	}
	// back substitution Ux = y
	for j in 0 .. nrhs {
		// forward solve Ly = Pb already done in-place on b
		// back solve
		for i := n - 1; i >= 0; i-- {
			mut sum := b[i * ldb + j]
			for k in i + 1 .. n {
				sum -= a[i * lda + k] * b[k * ldb + j]
			}
			b[i * ldb + j] = sum / a[i * lda + i]
		}
	}
	return 0
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
pub fn dgesvd(jobu SVDJob, jobvt SVDJob, m int, n int, mut a []f64, lda int, s []f64, mut u []f64, ldu int, mut vt []f64, ldvt int, superb []f64) int {
	// Convert from row-major (wrapper/C LAPACKE format) to column-major (BLAS/LAPACK format)
	mut a_col := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			a_col[i + j * m] = a[i * lda + j] // row-major -> column-major
		}
	}
	// Determine U and VT dimensions
	u_cols := match jobu {
		.svd_all { m }
		.svd_store { math.min(m, n) }
		else { 0 }
	}
	vt_rows := match jobvt {
		.svd_all { n }
		.svd_store { math.min(m, n) }
		else { 0 }
	}
	mut u_col := []f64{len: if u_cols > 0 { m * u_cols } else { 0 }}
	mut vt_col := []f64{len: if vt_rows > 0 { vt_rows * n } else { 0 }}
	// Convert U and VT from row-major to column-major if needed
	if u_cols > 0 {
		for i in 0 .. m {
			for j in 0 .. u_cols {
				u_col[i + j * m] = u[i * ldu + j] // row-major -> column-major
			}
		}
	}
	if vt_rows > 0 {
		for i in 0 .. vt_rows {
			for j in 0 .. n {
				vt_col[i + j * vt_rows] = vt[i * ldvt + j] // row-major -> column-major
			}
		}
	}
	info := lapack64.dgesvd(to_lapack64_svd_job(jobu), to_lapack64_svd_job(jobvt), m, n, mut
		a_col, m, s, mut u_col, m, mut vt_col, n, superb)
	// Convert back to row-major
	for i in 0 .. m {
		for j in 0 .. n {
			a[i * lda + j] = a_col[i + j * m] // column-major -> row-major
		}
	}
	if u_cols > 0 {
		for i in 0 .. m {
			for j in 0 .. u_cols {
				u[i * ldu + j] = u_col[i + j * m] // column-major -> row-major
			}
		}
	}
	if vt_rows > 0 {
		for i in 0 .. vt_rows {
			for j in 0 .. n {
				vt[i * ldvt + j] = vt_col[i + j * vt_rows] // column-major -> row-major
			}
		}
	}
	return info
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
pub fn dgetrf(m int, n int, mut a []f64, lda int, mut ipiv []int) int {
	// Convert from row-major (wrapper/C LAPACKE format) to column-major (BLAS/LAPACK format)
	mut a_col := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			a_col[i + j * m] = a[i * lda + j] // row-major -> column-major
		}
	}
	ok := lapack64.dgetrf(m, n, mut a_col, m, mut ipiv)
	// Convert back to row-major
	for i in 0 .. m {
		for j in 0 .. n {
			a[i * lda + j] = a_col[i + j * m] // column-major -> row-major
		}
	}
	// Convert 0-based indices to 1-based indices to match LAPACKE behavior
	for i in 0 .. ipiv.len {
		ipiv[i] += 1
	}
	return if ok { 0 } else { 1 } // Convert boolean to LAPACK info code
}

// dgetri computes the inverse of a matrix using the LU factorization computed by DGETRF.
//
// See: http://www.netlib.org/lapack/explore-html/df/da4/dgetri_8f.html
//
// See: https://software.intel.com/en-us/mkl-developer-reference-c-getri
//
// This method inverts U and then computes inv(A) by solving the system
// inv(A)*L = inv(U) for inv(A).
pub fn dgetri(n int, mut a []f64, lda int, mut ipiv []int) int {
	// Convert from row-major (wrapper/C LAPACKE format) to column-major (BLAS/LAPACK format)
	mut a_col := []f64{len: n * n}
	for i in 0 .. n {
		for j in 0 .. n {
			a_col[i + j * n] = a[i * lda + j] // row-major -> column-major
		}
	}
	// Query optimal workspace size
	mut work_query := []f64{len: 1}
	lapack64.dgetri(n, mut a_col, n, ipiv, mut work_query, -1)
	lwork := int(work_query[0])
	// Allocate workspace and call dgetri
	mut work := []f64{len: math.max(1, lwork)}
	ok := lapack64.dgetri(n, mut a_col, n, ipiv, mut work, lwork)
	// Convert back to row-major
	for i in 0 .. n {
		for j in 0 .. n {
			a[i * lda + j] = a_col[i + j * n] // column-major -> row-major
		}
	}
	if !ok {
		return -1 // Matrix is singular
	}
	return 0 // lapack64 functions don't return error codes
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
pub fn dpotrf(uplo blas.Uplo, n int, mut a []f64, lda int) int {
	// Convert from row-major (wrapper/C LAPACKE format) to column-major (BLAS/LAPACK format)
	mut a_col := []f64{len: n * n}
	for i in 0 .. n {
		for j in 0 .. n {
			a_col[i + j * n] = a[i * lda + j] // row-major -> column-major
		}
	}
	ok := lapack64.dpotrf(uplo, n, mut a_col, n)
	// Convert back to row-major
	for i in 0 .. n {
		for j in 0 .. n {
			a[i * lda + j] = a_col[i + j * n] // column-major -> row-major
		}
	}
	return if ok { 0 } else { 1 }
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
pub fn dgeev(calc_vl LeftEigenVectorsJob, calc_vr RightEigenVectorsJob, n int, mut a []f64, lda int, mut wr []f64, mut wi []f64, mut vl []f64, ldvl int, mut vr []f64, ldvr int) int {
	return lapack64.dgeev(to_lapack64_left_eigen_vectors_job(calc_vl), to_lapack64_right_eigen_vectors_job(calc_vr),
		n, mut a, lda, mut wr, mut wi, mut vl, ldvl, mut vr, ldvr)
}

// Low-level wrapper functions with standardized signatures
// These provide a consistent interface for both V and C backends

// dpotrf_standardized - Standardized dpotrf wrapper
@[inline]
pub fn dpotrf_standardized(uplo blas.Uplo, n int, mut a []f64, lda int) int {
	info := lapack64.dpotrf(uplo, n, mut a, lda)
	return if info { 0 } else { 1 }
}

// dsyev_standardized - Standardized dsyev wrapper
@[inline]
pub fn dsyev_standardized(jobz EigenVectorsJob, uplo blas.Uplo, n int, mut a []f64, lda int, mut w []f64) int {
	mut work := []f64{len: math.max(1, 3 * n - 1)}
	lapack64.dsyev(to_lapack64_eigen_vectors_job(jobz), uplo, n, mut a, lda, mut w, mut
		work, work.len)
	return 0 // lapack64 functions don't return error codes
}

// dgeev_standardized - Standardized dgeev wrapper
@[inline]
pub fn dgeev_standardized(jobvl LeftEigenVectorsJob, jobvr RightEigenVectorsJob, n int, mut a []f64, lda int, mut wr []f64, mut wi []f64, mut vl []f64, ldvl int, mut vr []f64, ldvr int) int {
	info := lapack64.dgeev(to_lapack64_left_eigen_vectors_job(jobvl), to_lapack64_right_eigen_vectors_job(jobvr),
		n, mut a, lda, mut wr, mut wi, mut vl, ldvl, mut vr, ldvr)
	return if info == 0 { 0 } else { info }
}

// dgeqrf_standardized - Standardized dgeqrf wrapper (placeholder until implemented)
@[inline]
pub fn dgeqrf_standardized(m int, n int, mut a []f64, lda int, mut tau []f64) int {
	// Placeholder - not implemented in lapack64 yet
	return -1 // Indicate not implemented
}

// dorgqr_standardized - Standardized dorgqr wrapper
@[inline]
pub fn dorgqr_standardized(m int, n int, k int, mut a []f64, lda int, tau []f64) int {
	mut work := []f64{len: math.max(1, n)}
	lapack64.dorgqr(m, n, k, mut a, lda, tau, mut work, work.len)
	return 0 // lapack64.dorgqr doesn't return error code
}

// dsyev - Direct wrapper for dsyev with standardized interface
@[inline]
pub fn dsyev(jobz EigenVectorsJob, uplo blas.Uplo, n int, mut a []f64, lda int, mut w []f64) int {
	// Call lapack64 with work array
	mut work := []f64{len: math.max(1, 3 * n - 1)}
	lapack64.dsyev(to_lapack64_eigen_vectors_job(jobz), uplo, n, mut a, lda, mut w, mut
		work, work.len)
	return 0 // lapack64 functions don't return error codes
}

// dgeqrf - Direct wrapper for dgeqrf with standardized interface
@[inline]
pub fn dgeqrf(m int, n int, mut a []f64, lda int, mut tau []f64) int {
	// Convert from row-major (wrapper/C LAPACKE format) to column-major (BLAS/LAPACK format)
	mut a_col := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			a_col[i + j * m] = a[i * lda + j] // row-major -> column-major
		}
	}
	// Query optimal workspace size
	mut work_query := []f64{len: 1}
	lapack64.dgeqrf(m, n, mut a_col, m, mut tau, mut work_query, -1)
	lwork := int(work_query[0])
	// Allocate workspace and call dgeqrf
	mut work := []f64{len: math.max(1, lwork)}
	lapack64.dgeqrf(m, n, mut a_col, m, mut tau, mut work, lwork)
	// Convert back to row-major
	for i in 0 .. m {
		for j in 0 .. n {
			a[i * lda + j] = a_col[i + j * m] // column-major -> row-major
		}
	}
	return 0 // lapack64 functions don't return error codes
}

// dorgqr - Direct wrapper for dorgqr with standardized interface
@[inline]
pub fn dorgqr(m int, n int, k int, mut a []f64, lda int, tau []f64) int {
	// Call lapack64 function with work array
	mut work := []f64{len: math.max(1, n)}
	lapack64.dorgqr(m, n, k, mut a, lda, tau, mut work, work.len)
	return 0 // lapack64 functions don't return error codes
}
