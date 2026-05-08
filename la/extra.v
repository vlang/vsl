module la

import vsl.lapack.lapack64
import vsl.errors
import math

// trace returns the sum of the diagonal elements of a matrix.
pub fn trace(a &Matrix[f64]) f64 {
	if a.m != a.n {
		errors.vsl_panic('trace: matrix must be square (${a.m}x${a.n})', .efailed)
	}
	mut tr := 0.0
	for i := 0; i < a.m; i++ {
		tr += a.get(i, i)
	}
	return tr
}

// norm returns the specified norm of a matrix.
// ord:
//   "" or "F" -> Frobenius norm
//   "I"       -> infinity norm (max row sum)
//   "1"       -> 1-norm (max column sum)
pub fn norm(a &Matrix[f64], ord string) f64 {
	if ord == 'I' {
		return a.norm_inf()
	}
	if ord == '1' {
		mut max_col := 0.0
		for j := 0; j < a.n; j++ {
			mut col_sum := 0.0
			for i := 0; i < a.m; i++ {
				col_sum += math.abs(a.get(i, j))
			}
			if col_sum > max_col {
				max_col = col_sum
			}
		}
		return max_col
	}
	// default: Frobenius
	return a.norm_frob()
}

// lstsq solves the linear least-squares problem: min ||Ax - B||_2
// using SVD-based pseudo-inverse.
// Returns (x, residuals, rank, singular_values)
pub fn lstsq(a &Matrix[f64], b &Matrix[f64]) ([][]f64, []f64, int, []f64) {
	if b.m != a.m {
		errors.vsl_panic('lstsq: A and B must have the same number of rows', .efailed)
	}
	m := a.m
	n := a.n
	nrhs := b.n

	// SVD: A = U * S * Vt
	mut a_svd := a.clone()
	mut s := []f64{len: int_min(m, n)}
	mut u_mat := Matrix.new[f64](m, m)
	mut vt_mat := Matrix.new[f64](n, n)
	matrix_svd(mut s, mut u_mat, mut vt_mat, mut a_svd, false)

	// x = V * Σ⁻¹ * U^T * b  (pseudo-inverse via SVD)
	tol := 1e-8
	mut x := [][]f64{len: n, init: []f64{len: nrhs}}
	for j := 0; j < nrhs; j++ {
		for i := 0; i < n; i++ {
			mut sum := 0.0
			for k := 0; k < int_min(m, n); k++ {
				if s[k] > tol {
					sum += vt_mat.get(k, i) * u_mat.get(j, k) / s[k]
				}
			}
			x[i][j] = sum
		}
	}

	// Residuals ||Ax - b||_2 per RHS
	mut residuals := []f64{len: nrhs}
	if m >= n && nrhs > 0 {
		for j := 0; j < nrhs; j++ {
			mut r := 0.0
			for i := 0; i < m; i++ {
				mut ax_i := 0.0
				for k := 0; k < n; k++ {
					ax_i += a.get(i, k) * x[k][j]
				}
				dx := ax_i - b.get(i, j)
				r += dx * dx
			}
			residuals[j] = math.sqrt(r)
		}
	}

	return x, residuals, int_min(m, n), s
}

// outer computes the outer product of two vectors: result[i,j] = u[i] * v[j]
pub fn outer(u []f64, v []f64) &Matrix[f64] {
	mut result := Matrix.new[f64](u.len, v.len)
	for i := 0; i < u.len; i++ {
		for j := 0; j < v.len; j++ {
			result.set(i, j, u[i] * v[j])
		}
	}
	return result
}

// cross computes the 3D cross product of two vectors: result = u × v
pub fn cross(u []f64, v []f64) []f64 {
	if u.len != 3 || v.len != 3 {
		errors.vsl_panic('cross: both vectors must have length 3', .efailed)
	}
	return [
		u[1] * v[2] - u[2] * v[1],
		u[2] * v[0] - u[0] * v[2],
		u[0] * v[1] - u[1] * v[0],
	]
}

// qr computes QR factorization of A via LAPACKgeqrf + orgqr.
// Returns (Q, R) where Q is orthonormal (m x min_mn) and R is upper triangular (min_mn x n).
pub fn qr(a &Matrix[f64]) !(&Matrix[f64], &Matrix[f64]) {
	m := a.m
	n := a.n

	// Column-major buffer
	mut a_col := []f64{len: m * n}
	for i := 0; i < m; i++ {
		for j := 0; j < n; j++ {
			a_col[i + j * m] = a.get(i, j)
		}
	}

	min_mn := int_min(m, n)
	mut tau := []f64{len: min_mn}
	mut work := []f64{len: 1}
	lapack64.dgeqrf(m, n, mut a_col, m, mut tau, mut work, -1)
	lwork := int(work[0])
	if lwork < 1 {
		return error('qr: bad lwork=${lwork}')
	}
	work = []f64{len: lwork}
	lapack64.dgeqrf(m, n, mut a_col, m, mut tau, mut work, lwork)

	// R: upper triangular part (column-major stored)
	mut r_mat := Matrix.new[f64](min_mn, n)
	for i := 0; i < min_mn; i++ {
		for j := i; j < n; j++ {
			r_mat.set(i, j, a_col[i + j * m])
		}
	}

	// Q via orgqr
	mut a_q := a_col.clone()
	mut work2 := []f64{len: 1}
	lapack64.dorgqr(m, n, min_mn, mut a_q, m, tau, mut work2, -1)
	lwork2 := int(work2[0])
	if lwork2 < 1 {
		return error('qr: bad lwork2=${lwork2}')
	}
	work2 = []f64{len: lwork2}
	lapack64.dorgqr(m, n, min_mn, mut a_q, m, tau, mut work2, lwork2)

	// Q back to row-major (m x min_mn)
	mut q_mat := Matrix.new[f64](m, min_mn)
	for i := 0; i < m; i++ {
		for j := 0; j < min_mn; j++ {
			q_mat.set(i, j, a_q[i + j * m])
		}
	}

	return q_mat, r_mat
}

// lu computes LU decomposition with partial pivoting: PA = LU.
// Returns (L, U, piv) where L is lower triangular, U is upper, piv are pivot indices.
pub fn lu(a &Matrix[f64]) !(&Matrix[f64], &Matrix[f64], []int) {
	m := a.m
	n := a.n
	min_mn := int_min(m, n)

	mut a_lu := a.clone()
	mut ipiv := []int{len: min_mn}

	for k := 0; k < min_mn; k++ {
		// Find pivot in column k
		mut piv := k
		mut maxv := math.abs(a_lu.get(k, k))
		for i := k + 1; i < m; i++ {
			v := math.abs(a_lu.get(i, k))
			if v > maxv {
				maxv = v
				piv = i
			}
		}
		ipiv[k] = piv
		if math.abs(maxv) < 1e-14 {
			continue
		}
		// Swap rows k and piv
		if piv != k {
			for j := 0; j < n; j++ {
				tmp := a_lu.get(k, j)
				a_lu.set(k, j, a_lu.get(piv, j))
				a_lu.set(piv, j, tmp)
			}
		}
		// Gaussian elimination
		for i := k + 1; i < m; i++ {
			factor := a_lu.get(i, k) / a_lu.get(k, k)
			a_lu.set(i, k, factor)
			for j := k + 1; j < n; j++ {
				val := a_lu.get(i, j) - factor * a_lu.get(k, j)
				a_lu.set(i, j, val)
			}
		}
	}

	// L: unit diagonal + strictly lower part
	mut l_mat := Matrix.new[f64](m, min_mn)
	for i := 0; i < m; i++ {
		for j := 0; j < min_mn; j++ {
			if i == j {
				l_mat.set(i, j, 1.0)
			} else if i > j {
				l_mat.set(i, j, a_lu.get(i, j))
			}
		}
	}

	// U: upper triangular (rows 0..min_mn-1, all cols)
	mut u_mat := Matrix.new[f64](min_mn, n)
	for i := 0; i < min_mn; i++ {
		for j := 0; j < n; j++ {
			if i <= j {
				u_mat.set(i, j, a_lu.get(i, j))
			}
		}
	}

	return l_mat, u_mat, ipiv
}

// rank returns the effective numerical rank of A using SVD.
pub fn rank(a &Matrix[f64], tol f64) int {
	m := a.m
	n := a.n
	min_mn := int_min(m, n)
	mut s := []f64{len: min_mn}
	mut u := Matrix.new[f64](m, m)
	mut vt := Matrix.new[f64](n, n)
	mut acpy := a.clone()
	matrix_svd(mut s, mut u, mut vt, mut acpy, false)
	mut r := 0
	for i := 0; i < min_mn; i++ {
		if s[i] > tol {
			r++
		}
	}
	return r
}

fn int_min(a int, b int) int {
	return if a < b { a } else { b }
}

fn int_max(a int, b int) int {
	return if a > b { a } else { b }
}