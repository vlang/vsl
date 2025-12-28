module lapack

import vsl.blas
import vsl.lapack.lapack64
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

	// Flatten matrices to 1D arrays (row-major for C LAPACKE, converted by pure V backend if needed)
	mut a_flat := []f64{len: n * n}
	mut b_flat := []f64{len: n * nrhs}
	mut ipiv := []int{len: n}

	// Convert A from row-major nested slice to row-major flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j] // row-major: a[i][j] -> a_flat[i*n + j]
		}
	}

	// Convert B from row-major nested slice to row-major flat array
	for i in 0 .. n {
		for j in 0 .. nrhs {
			b_flat[i * nrhs + j] = b[i][j] // row-major: b[i][j] -> b_flat[i*nrhs + j]
		}
	}

	// Call low-level dgesv function
	// C LAPACKE backend expects row-major (lda=n, ldb=nrhs)
	// Pure V backend will convert internally from row-major to column-major
	info := dgesv(n, nrhs, mut a_flat, n, mut ipiv, mut b_flat, nrhs)
	if info != 0 {
		return error('gesv failed with info=${info}')
	}

	// Convert result back from flat array to row-major 2D arrays
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j] // row-major: a_flat[i*n + j] -> a[i][j]
		}
	}

	for i in 0 .. n {
		for j in 0 .. nrhs {
			b[i][j] = b_flat[i * nrhs + j] // row-major: b_flat[i*nrhs + j] -> b[i][j]
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
	mut ipiv := []int{len: int_min(m, n)}

	for k in 0 .. ipiv.len {
		// pivot search in column k
		mut piv := k
		mut maxv := math.abs(a[k][k])
		for i in k + 1 .. m {
			v := math.abs(a[i][k])
			if v > maxv {
				maxv = v
				piv = i
			}
		}
		ipiv[k] = piv
		if maxv == 0 {
			return error('getrf failed: singular pivot at ${k}')
		}
		// swap rows if needed
		if piv != k {
			a[k], a[piv] = a[piv], a[k]
		}
		// elimination
		for i in k + 1 .. m {
			a[i][k] /= a[k][k]
			for j in k + 1 .. n {
				a[i][j] -= a[i][k] * a[k][j]
			}
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

	// Flatten matrix to 1D array (row-major for C LAPACKE, converted by pure V backend if needed)
	mut a_flat := []f64{len: n * n}

	// Convert A from row-major nested slice to row-major flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j] // row-major: a[i][j] -> a_flat[i*n + j]
		}
	}

	// Convert 0-based V indices to 1-based LAPACK indices
	mut ipiv_lapack := []int{len: n}
	for i in 0 .. n {
		ipiv_lapack[i] = ipiv[i] + 1
	}

	// Call low-level dgetri function
	// C LAPACKE backend expects row-major (lda=n)
	// Pure V backend will convert internally from row-major to column-major
	info := dgetri(n, mut a_flat, n, mut ipiv_lapack)
	if info != 0 {
		return error('getri failed with info=${info}')
	}

	// Convert result back from flat array to row-major 2D array
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j] // row-major: a_flat[i*n + j] -> a[i][j]
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

	// Flatten matrix to 1D array (row-major for C LAPACKE, converted by pure V backend if needed)
	mut a_flat := []f64{len: n * n}

	// Convert A from row-major nested slice to row-major flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j] // row-major: a[i][j] -> a_flat[i*n + j]
		}
	}

	// Convert uplo to character for LAPACK
	// Call low-level dpotrf function
	// C LAPACKE backend expects row-major (lda=n)
	// Pure V backend will convert internally from row-major to column-major
	info := dpotrf(uplo, n, mut a_flat, n)
	if info != 0 {
		return error('potrf failed with info=${info}')
	}

	// Convert result back from flat array to row-major 2D array
	for i in 0 .. n {
		for j in 0 .. n {
			a[i][j] = a_flat[i * n + j] // row-major: a_flat[i*n + j] -> a[i][j]
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

	// Convert to column-major and call lapack64
	mut a_col := []f64{len: m * n}
	for i in 0 .. m {
		for j in 0 .. n {
			a_col[i + j * m] = a[i][j]
		}
	}
	mut tau := []f64{len: min_mn}
	mut work := []f64{len: 1}
	lapack64.dgeqrf(m, n, mut a_col, m, mut tau, mut work, -1)
	lwork := int(work[0])
	if lwork < 1 {
		return error('geqrf failed: bad lwork')
	}
	work = []f64{len: lwork}
	lapack64.dgeqrf(m, n, mut a_col, m, mut tau, mut work, lwork)
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = a_col[i + j * m]
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
	n_q := int_min(m, n)

	// column-major buffer
	mut a_col := []f64{len: m * n_q}
	for i in 0 .. m {
		for j in 0 .. n_q {
			a_col[i + j * m] = a[i][j]
		}
	}
	mut work := []f64{len: 1}
	lapack64.dorgqr(m, n_q, k, mut a_col, m, tau, mut work, -1)
	lwork := int(work[0])
	if lwork < 1 {
		return error('orgqr failed: bad lwork')
	}
	work = []f64{len: lwork}
	lapack64.dorgqr(m, n_q, k, mut a_col, m, tau, mut work, lwork)

	if m < n {
		for i in 0 .. m {
			a[i] = []f64{len: m}
		}
	}
	for i in 0 .. m {
		for j in 0 .. n_q {
			a[i][j] = a_col[i + j * m]
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
	mut compute_vec := jobz == .ev_compute

	// Convert A from row-major to flat array
	for i in 0 .. n {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j]
		}
	}

	// Pure V Jacobi for symmetric matrices (row-major).
	jacobi_symmetric(mut a_flat, n, compute_vec, mut w)

	// Convert eigenvectors back to row-major 2D array (if computed)
	if compute_vec {
		for i in 0 .. n {
			for j in 0 .. n {
				a[i][j] = a_flat[i * n + j]
			}
		}
	}

	return w
}

// Simple Jacobi symmetric eigensolver (row-major). Overwrites `a` with eigenvectors if requested.
fn jacobi_symmetric(mut a []f64, n int, compute_vec bool, mut w []f64) {
	mut v := []f64{}
	if compute_vec {
		v = []f64{len: n * n}
		for i in 0 .. n {
			v[i * n + i] = 1
		}
	}
	max_sweeps := 50
	eps := 1e-12
	for _ in 0 .. max_sweeps {
		mut p := 0
		mut q := 1
		mut max_off := 0.0
		for i in 0 .. n {
			for j in i + 1 .. n {
				val := math.abs(a[i * n + j])
				if val > max_off {
					max_off = val
					p = i
					q = j
				}
			}
		}
		if max_off < eps {
			break
		}
		app := a[p * n + p]
		aqq := a[q * n + q]
		apq := a[p * n + q]
		phi := 0.5 * math.atan2(2 * apq, aqq - app)
		c := math.cos(phi)
		s := math.sin(phi)
		for k in 0 .. n {
			apk := a[p * n + k]
			aqk := a[q * n + k]
			a[p * n + k] = c * apk - s * aqk
			a[q * n + k] = s * apk + c * aqk
		}
		for k in 0 .. n {
			akp := a[k * n + p]
			akq := a[k * n + q]
			a[k * n + p] = c * akp - s * akq
			a[k * n + q] = s * akp + c * akq
		}
		if compute_vec {
			for k in 0 .. n {
				vkp := v[k * n + p]
				vkq := v[k * n + q]
				v[k * n + p] = c * vkp - s * vkq
				v[k * n + q] = s * vkp + c * vkq
			}
		}
	}
	for i in 0 .. n {
		w[i] = a[i * n + i]
	}
	if compute_vec {
		for i in 0 .. n {
			for j in 0 .. n {
				a[i * n + j] = v[i * n + j]
			}
		}
	}

	// Sort eigenvalues ascending (and eigenvectors columns accordingly)
	mut idx := []int{len: n}
	for i in 0 .. n {
		idx[i] = i
	}
	for i in 0 .. n {
		mut min_j := i
		for j in i + 1 .. n {
			if w[j] < w[min_j] {
				min_j = j
			}
		}
		if min_j != i {
			w[i], w[min_j] = w[min_j], w[i]
			idx[i], idx[min_j] = idx[min_j], idx[i]
		}
	}
	if compute_vec {
		mut v_sorted := []f64{len: n * n}
		for col in 0 .. n {
			src_col := idx[col]
			for row in 0 .. n {
				v_sorted[row * n + col] = a[row * n + src_col]
			}
		}
		for i in 0 .. n * n {
			a[i] = v_sorted[i]
		}
	}
}

// gesvd computes the singular value decomposition (SVD) of a real m×n matrix A.
pub fn gesvd(a [][]f64, jobu SVDJob, jobvt SVDJob) !([]f64, [][]f64, [][]f64) {
	if a.len == 0 || a[0].len == 0 {
		return error('gesvd: matrix A is empty')
	}

	m := a.len
	n := a[0].len
	min_mn := int_min(m, n)

	// Flatten matrix to 1D array (row-major for C LAPACKE, converted by pure V backend if needed)
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

	// Convert A from row-major nested slice to row-major flat array
	for i in 0 .. m {
		for j in 0 .. n {
			a_flat[i * n + j] = a[i][j] // row-major: a[i][j] -> a_flat[i*n + j]
		}
	}

	// Call low-level dgesvd function
	// C LAPACKE backend expects row-major (lda=n, ldu=u_cols, ldvt=n)
	// Pure V backend will convert internally from row-major to column-major
	ldu := if u_cols > 0 { u_cols } else { 1 }
	ldvt := if vt_rows > 0 { n } else { 1 }

	info := dgesvd(jobu, jobvt, m, n, mut a_flat, n, s, mut u, ldu, mut vt, ldvt, superb)
	if info != 0 {
		return error('gesvd failed with info=${info}')
	}

	// Convert U and VT back from flat array to row-major 2D arrays
	mut u_2d := [][]f64{len: if u_cols > 0 { m } else { 0 }, init: []f64{len: u_cols}}
	mut vt_2d := [][]f64{len: vt_rows, init: []f64{len: if vt_rows > 0 { n } else { 0 }}}

	if u_cols > 0 {
		for i in 0 .. m {
			for j in 0 .. u_cols {
				u_2d[i][j] = u[i * u_cols + j] // row-major: u[i*u_cols + j] -> u_2d[i][j]
			}
		}
	}

	if vt_rows > 0 {
		for i in 0 .. vt_rows {
			for j in 0 .. n {
				vt_2d[i][j] = vt[i * n + j] // row-major: vt[i*n + j] -> vt_2d[i][j]
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
