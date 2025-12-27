module lapack

import vsl.errors
import vsl.blas
import math

// ========================================================================
// HIGH-LEVEL WRAPPER FUNCTIONS
// These functions provide a convenient interface for 2D matrix operations
// using the low-level dgesv, dgetrf, etc. functions from either backend
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

	// Flatten matrices to 1D arrays (row-major storage)
	mut a_flat := []f64{len: n * n}
	mut b_flat := []f64{len: n * nrhs}
	mut ipiv := []int{len: n}

	// Convert A from row-major to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Convert B from row-major to flat array (row-major storage)
	for i in 0 .. n {
		for j in 0 .. nrhs {
			b_flat[i * nrhs + j] = b[i][j]
		}
	}

	// Call low-level dgesv function
	info := dgesv(n, nrhs, mut a_flat, n, mut ipiv, mut b_flat, nrhs)
	if info != 0 {
		return error('gesv failed with info=${info}')
	}

	// Convert result back to row-major 2D arrays
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}

	for i in 0 .. n {
		for j in 0 .. nrhs {
			b[i][j] = b_flat[i * nrhs + j]
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

	// Flatten matrix to 1D array (row-major storage)
	mut a_flat := []f64{len: m * n}
	mut ipiv := []int{len: int_min(m, n)}

	// Convert A from row-major to flat array
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Call low-level dgetrf function
	info := dgetrf(m, n, mut a_flat, n, mut ipiv)
	if info != 0 {
		return error('getrf failed with info=${info}')
	}

	// Convert result back to row-major 2D array
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}

	// Convert 1-based LAPACK pivot indices to 0-based V indices
	for i in 0 .. ipiv.len {
		ipiv[i] -= 1
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

	// Flatten matrix to 1D array (row-major storage)
	mut a_flat := []f64{len: n * n}

	// Convert A from row-major to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Convert 0-based V indices to 1-based LAPACK indices
	mut ipiv_lapack := []int{len: n}
	for i in 0 .. n {
		ipiv_lapack[i] = ipiv[i] + 1
	}

	// Call low-level dgetri function
	info := dgetri(n, mut a_flat, n, mut ipiv_lapack)
	if info != 0 {
		return error('getri failed with info=${info}')
	}

	// Convert result back to row-major 2D array
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
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

	// Flatten matrix to 1D array (row-major storage)
	mut a_flat := []f64{len: n * n}

	// Convert A from row-major to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Convert uplo to character for LAPACK
	// Call low-level dpotrf function
	info := dpotrf(uplo, n, mut a_flat, n)
	if info != 0 {
		return error('potrf failed with info=${info}')
	}

	// Convert result back to row-major 2D array
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}
}

// geqrf computes a QR factorization of a real m×n matrix A.
pub fn geqrf(mut a [][]f64) ![]f64 {
	if a.len == 0 || a[0].len == 0 {
		return error('geqrf: matrix A is empty')
	}

	m := a.len
	n := a[0].len
	min_mn := int_min(m, n)

	// Flatten matrix to 1D array (row-major storage)
	mut a_flat := []f64{len: m * n}
	mut tau := []f64{len: min_mn}

	// Convert A from row-major to flat array
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Call low-level dgeqrf function
	info := dgeqrf(m, n, mut a_flat, n, mut tau)
	if info != 0 {
		return error('geqrf failed with info=${info}')
	}

	// Convert result back to row-major 2D array
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j]
		}
	}

	return tau
}

// orgqr generates the m×n matrix Q with orthonormal columns defined as the
// first n columns of a product of k elementary reflectors of order m.
pub fn orgqr(mut a [][]f64, tau []f64) ! {
	if a.len == 0 || a[0].len == 0 {
		return error('orgqr: matrix A is empty')
	}

	m := a.len
	n := a[0].len
	k := tau.len

	// For ORGQR, we need to ensure n <= m. For wide matrices (m < n),
	// we should only generate Q as an m×m matrix, taking the first m columns.
	n_q := int_min(m, n)

	// Flatten matrix to 1D array (row-major storage)
	mut a_flat := []f64{len: m * n_q}

	// Convert A from row-major to flat array (only first n_q columns)
	for i in 0 .. m {
		for j in 0 .. n_q {
			a_flat[i * n_q + j] = a[i][j]
		}
	}

	// Call low-level dorgqr function
	info := dorgqr(m, n_q, k, mut a_flat, n_q, tau)
	if info != 0 {
		return error('orgqr failed with info=${info}')
	}

	// For wide matrices (m < n), resize the matrix to be m×m (economy size)
	if m < n {
		for i in 0 .. m {
			a[i] = []f64{len: m}
		}
	}

	// Convert result back to the (possibly resized) matrix
	for i in 0 .. m {
		for j in 0 .. n_q {
			a[i][j] = a_flat[i * n_q + j]
		}
	}
}

// geev computes the eigenvalues and, optionally, the left and/or right eigenvectors
// for a real nonsymmetric matrix A.
pub fn geev(a [][]f64, jobvl LeftEigenVectorsJob, jobvr RightEigenVectorsJob) !([]f64, []f64, [][]f64, [][]f64) {
	if a.len == 0 || a[0].len == 0 {
		return error('geev: matrix A is empty')
	}

	n := a.len
	if a[0].len != n {
		return error('geev: matrix A is not square')
	}

	// Flatten matrix to 1D array (row-major storage)
	mut a_flat := []f64{len: n * n}
	mut wr := []f64{len: n}
	mut wi := []f64{len: n}
	mut vl := []f64{len: n * n}
	mut vr := []f64{len: n * n}

	// Convert A from row-major to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Call low-level dgeev function
	info := dgeev(jobvl, jobvr, n, mut a_flat, n, mut wr, mut wi, mut vl, n, mut vr, n)
	if info != 0 {
		return error('geev failed with info=${info}')
	}

	// Convert eigenvector arrays back to 2D
	mut vl_2d := [][]f64{len: if jobvl == .left_ev_compute { n } else { 0 }, init: []f64{len: if jobvl == .left_ev_compute {
		n
	} else {
		0
	}}}
	mut vr_2d := [][]f64{len: if jobvr == .right_ev_compute { n } else { 0 }, init: []f64{len: if jobvr == .right_ev_compute {
		n
	} else {
		0
	}}}

	if jobvl == .left_ev_compute {
		for i in 0 .. n {
			for j in 0 .. n {
				vl_2d[i][j] = vl[i * n + j]
			}
		}
	}

	if jobvr == .right_ev_compute {
		for i in 0 .. n {
			for j in 0 .. n {
				vr_2d[i][j] = vr[i * n + j]
			}
		}
	}

	return wr, wi, vl_2d, vr_2d
}

// syev computes all eigenvalues and, optionally, eigenvectors of a real symmetric matrix A.
pub fn syev(mut a [][]f64, jobz EigenVectorsJob, uplo blas.Uplo) ![]f64 {
	if a.len == 0 || a[0].len == 0 {
		return error('syev: matrix A is empty')
	}

	n := a.len
	if a[0].len != n {
		return error('syev: matrix A is not square')
	}

	// Flatten matrix to 1D array (row-major storage)
	mut a_flat := []f64{len: n * n}
	mut w := []f64{len: n}

	// Convert A from row-major to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Convert enums to characters
	// Call low-level dsyev function
	info := dsyev(jobz, uplo, n, mut a_flat, n, mut w)
	if info != 0 {
		return error('syev failed with info=${info}')
	}

	// Convert eigenvectors back to row-major 2D array (if computed)
	if jobz == .ev_compute {
		for i in 0 .. n {
			for j in 0 .. n {
				a[i][j] = a_flat[i * n + j]
			}
		}
	}

	return w
}

// gesvd computes the singular value decomposition (SVD) of a real m×n matrix A.
pub fn gesvd(a [][]f64, jobu SVDJob, jobvt SVDJob) !([]f64, [][]f64, [][]f64) {
	if a.len == 0 || a[0].len == 0 {
		return error('gesvd: matrix A is empty')
	}

	m := a.len
	n := a[0].len
	min_mn := int_min(m, n)

	// Flatten matrix to 1D array (row-major storage)
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

	// Convert A from row-major to flat array
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Call low-level dgesvd function
	ldu := if u_cols > 0 { u_cols } else { 1 }
	ldvt := if vt_rows > 0 { n } else { 1 }

	info := dgesvd(jobu, jobvt, m, n, mut a_flat, n, s, mut u, ldu, mut vt, ldvt, superb)
	if info != 0 {
		return error('gesvd failed with info=${info}')
	}

	// Convert U and VT back to 2D arrays
	mut u_2d := [][]f64{len: if u_cols > 0 { m } else { 0 }, init: []f64{len: u_cols}}
	mut vt_2d := [][]f64{len: vt_rows, init: []f64{len: if vt_rows > 0 { n } else { 0 }}}

	if u_cols > 0 {
		for i in 0 .. m {
			for j in 0 .. u_cols {
				u_2d[i][j] = u[i * u_cols + j]
			}
		}
	}

	if vt_rows > 0 {
		for i in 0 .. vt_rows {
			for j in 0 .. n {
				vt_2d[i][j] = vt[i * n + j]
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
