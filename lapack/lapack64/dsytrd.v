module lapack64

import math
import vsl.blas

// dsytrd reduces a symmetric n×n matrix A to symmetric tridiagonal form by an
// orthogonal similarity transformation
//
//  Qᵀ * A * Q = T
//
// where Q is an orthonormal matrix and T is symmetric and tridiagonal.
//
// On entry, a contains the elements of the input matrix in the triangle specified
// by uplo. On exit, the diagonal and sub/super-diagonal are overwritten by the
// corresponding elements of the tridiagonal matrix T. The remaining elements in
// the triangle, along with the array tau, contain the data to construct Q as
// the product of elementary reflectors.
//
// If uplo == blas.upper, Q is constructed with
//
//  Q = H_{n-2} * ... * H_1 * H_0
//
// where
//
//  H_i = I - tau_i * v * vᵀ
//
// v is constructed as v[i+1:n] = 0, v[i] = 1, v[0:i-1] is stored in A[0:i-1, i+1].
// The elements of A are
//
//  [ d   e  v1  v2  v3]
//  [     d   e  v2  v3]
//  [         d   e  v3]
//  [             d   e]
//  [                 e]
//
// If uplo == blas.lower, Q is constructed with
//
//  Q = H_0 * H_1 * ... * H_{n-2}
//
// where
//
//  H_i = I - tau_i * v * vᵀ
//
// v is constructed as v[0:i+1] = 0, v[i+1] = 1, v[i+2:n] is stored in A[i+2:n, i].
// The elements of A are
//
//  [ d                ]
//  [ e   d            ]
//  [v0   e   d        ]
//  [v0  v1   e   d    ]
//  [v0  v1  v2   e   d]
//
// d must have length n, and e and tau must have length n-1. dsytrd will panic if
// these conditions are not met.
//
// work is temporary storage, and lwork specifies the usable memory length. At minimum,
// lwork >= 1, and dsytrd will panic otherwise. The amount of blocking is
// limited by the usable length.
// If lwork == -1, instead of computing dsytrd the optimal work length is stored
// into work[0].
//
// dsytrd is an internal routine. It is exported for testing purposes.
pub fn dsytrd(uplo blas.Uplo, n int, mut a []f64, lda int, mut d []f64, mut e []f64, mut tau []f64, mut work []f64, lwork int) {
	if uplo != .upper && uplo != .lower {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if lwork < 1 && lwork != -1 {
		panic(bad_l_work)
	}
	if work.len < math.max(1, lwork) {
		panic(short_work)
	}

	// Quick return if possible.
	if n == 0 {
		work[0] = 1
		return
	}

	mut nb := ilaenv(1, 'DSYTRD', if uplo == .upper { 'U' } else { 'L' }, n, -1, -1, -1)
	lworkopt := n * nb
	if lwork == -1 {
		work[0] = f64(lworkopt)
		return
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}
	if d.len < n {
		panic(short_d)
	}
	if e.len < n - 1 {
		panic(short_e)
	}
	if tau.len < n - 1 {
		panic(short_tau)
	}

	mut nx := n
	mut iws := 1
	mut ldwork := 0
	if 1 < nb && nb < n {
		// Determine when to cross over from blocked to unblocked code. The last
		// block is always handled by unblocked code.
		nx = math.max(nb, ilaenv(3, 'DSYTRD', if uplo == .upper { 'U' } else { 'L' },
			n, -1, -1, -1))
		if nx < n {
			// Determine if workspace is large enough for blocked code.
			ldwork = nb
			iws = n * ldwork
			if lwork < iws {
				// Not enough workspace to use optimal nb: determine the minimum
				// value of nb and reduce nb or force use of unblocked code by
				// setting nx = n.
				nb = math.max(lwork / n, 1)
				nbmin := ilaenv(2, 'DSYTRD', if uplo == .upper { 'U' } else { 'L' }, n,
					-1, -1, -1)
				if nb < nbmin {
					nx = n
				}
			}
		} else {
			nx = n
		}
	} else {
		nb = 1
	}
	ldwork = nb

	if uplo == .upper {
		// Reduce the upper triangle of A. Columns 0:kk are handled by the
		// unblocked method.
		mut i := 0
		kk := n - ((n - nx + nb - 1) / nb) * nb
		for i = n - nb; i >= kk; i -= nb {
			// Reduce columns i:i+nb to tridiagonal form and form the matrix W
			// which is needed to update the unreduced part of the matrix.
			dlatrd(uplo, i + nb, nb, mut a, lda, mut e, mut tau, mut work, ldwork)

			// Update the unreduced submatrix A[0:i-1,0:i-1], using an update
			// of the form A = A - V*Wᵀ - W*Vᵀ.
			blas.dsyr2k(uplo, .no_trans, i, nb, -1.0, a[i * lda..], lda, work, ldwork,
				1.0, mut a, lda)

			// Copy superdiagonal elements back into A, and diagonal elements into D.
			for j := i; j < i + nb; j++ {
				a[(j - 1) * lda + j] = e[j - 1]
				d[j] = a[j * lda + j]
			}
		}
		// Use unblocked code to reduce the last or only block
		dsytd2(uplo, kk, mut a, lda, mut d, mut e, mut tau)
	} else {
		mut i := 0
		// Reduce the lower triangle of A.
		for i = 0; i < n - nx; i += nb {
			// Reduce columns 0:i+nb to tridiagonal form and form the matrix W
			// which is needed to update the unreduced part of the matrix.
			dlatrd(uplo, n - i, nb, mut a[i * lda + i..], lda, mut e[i..], mut tau[i..], mut
				work, ldwork)

			// Update the unreduced submatrix A[i+ib:n, i+ib:n], using an update
			// of the form A = A + V*Wᵀ - W*Vᵀ.
			blas.dsyr2k(uplo, .no_trans, n - i - nb, nb, -1.0, a[(i + nb) * lda + i..],
				lda, work[nb * ldwork..], ldwork, 1.0, mut a[(i + nb) * lda + i + nb..],
				lda)

			// Copy subdiagonal elements back into A, and diagonal elements into D.
			for j := i; j < i + nb; j++ {
				a[(j + 1) * lda + j] = e[j]
				d[j] = a[j * lda + j]
			}
		}
		// Use unblocked code to reduce the last or only block.
		dsytd2(uplo, n - i, mut a[i * lda + i..], lda, mut d[i..], mut e[i..], mut tau[i..])
	}
	work[0] = f64(iws)
}
