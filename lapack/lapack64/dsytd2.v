module lapack64

import math
import vsl.blas

// Dsytd2 reduces a symmetric n×n matrix A to symmetric tridiagonal form T by
// an orthogonal similarity transformation
//
//  Qᵀ * A * Q = T
//
// On entry, the matrix is contained in the specified triangle of a. On exit,
// if uplo == Uplo.upper, the diagonal and first super-diagonal of a are
// overwritten with the elements of T. The elements above the first super-diagonal
// are overwritten with the elementary reflectors that are used with
// the elements written to tau in order to construct Q. If uplo == Uplo.lower,
// the elements are written in the lower triangular region.
//
// d must have length at least n. e and tau must have length at least n-1. Dsytd2
// will panic if these sizes are not met.
//
// Q is represented as a product of elementary reflectors.
// If uplo == Uplo.upper
//
//  Q = H_{n-2} * ... * H_1 * H_0
//
// and if uplo == Uplo.lower
//
//  Q = H_0 * H_1 * ... * H_{n-2}
//
// where
//
//  H_i = I - tau * v * vᵀ
//
// where tau is stored in tau[i], and v is stored in a.
//
// If uplo == Uplo.upper, v[0:i-1] is stored in A[0:i-1,i+1], v[i] = 1, and
// v[i+1:] = 0. The elements of a are
//
//  [ d   e  v2  v3  v4]
//  [     d   e  v3  v4]
//  [         d   e  v4]
//  [             d   e]
//  [                 d]
//
// If uplo == Uplo.lower, v[0:i+1] = 0, v[i+1] = 1, and v[i+2:] is stored in
// A[i+2:n,i].
// The elements of a are
//
//  [ d                ]
//  [ e   d            ]
//  [v1   e   d        ]
//  [v1  v2   e   d    ]
//  [v1  v2  v3   e   d]
//
pub fn dsytd2(uplo blas.Uplo, n int, mut a []f64, lda int, mut d []f64, mut e []f64, mut tau []f64) {
	if uplo != .upper && uplo != .lower {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	// Quick return if possible.
	if n == 0 {
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

	if uplo == .upper {
		// Reduce the upper triangle of A.
		for i := n - 2; i >= 0; i-- {
			// Generate elementary reflector H_i = I - tau * v * vᵀ to
			// annihilate A[i:i-1, i+1].
			taui, _ := dlarfg(i + 1, a[i * lda + i + 1], mut a[0 + i + 1..], lda)
			e[i] = a[i * lda + i + 1]
			if taui != 0.0 {
				// Apply H_i from both sides to A[0:i,0:i].
				a[i * lda + i + 1] = 1.0

				// Compute x := tau * A * v storing x in tau[0:i].
				blas.dsymv(.upper, i + 1, taui, a, lda, a[i + 1..], lda, 0, mut tau, 1)

				// Compute w := x - 1/2 * tau * (xᵀ * v) * v.
				alpha := -0.5 * taui * blas.ddot(i + 1, tau, 1, a[i + 1..], lda)
				blas.daxpy(i + 1, alpha, a[i + 1..], lda, mut tau, 1)

				// Apply the transformation as a rank-2 update
				// A = A - v * wᵀ - w * vᵀ.
				blas.dsyr2(.upper, i + 1, -1.0, a[i + 1..], lda, tau, 1, mut a, lda)
				a[i * lda + i + 1] = e[i]
			}
			d[i + 1] = a[(i + 1) * lda + i + 1]
			tau[i] = taui
		}
		d[0] = a[0]
	} else {
		// Reduce the lower triangle of A.
		for i := 0; i < n - 1; i++ {
			// Generate elementary reflector H_i = I - tau * v * vᵀ to
			// annihilate A[i+2:n, i].
			taui, _ := dlarfg(n - i - 1, a[(i + 1) * lda + i], mut a[math.min(i + 2, n - 1) * lda +
				i..], lda)
			e[i] = a[(i + 1) * lda + i]
			if taui != 0.0 {
				// Apply H_i from both sides to A[i+1:n, i+1:n].
				a[(i + 1) * lda + i] = 1.0

				// Compute x := tau * A * v, storing y in tau[i:n-1].
				blas.dsymv(.lower, n - i - 1, taui, a[(i + 1) * lda + i + 1..], lda, a[(i +
					1) * lda + i..], lda, 0, mut tau[i..], 1)

				// Compute w := x - 1/2 * tau * (xᵀ * v) * v.
				alpha := -0.5 * taui * blas.ddot(n - i - 1, tau[i..], 1, a[(i + 1) * lda + i..],
					lda)
				blas.daxpy(n - i - 1, alpha, a[(i + 1) * lda + i..], lda, mut tau[i..],
					1)

				// Apply the transformation as a rank-2 update
				// A = A - v * wᵀ - w * vᵀ.
				blas.dsyr2(.lower, n - i - 1, -1.0, a[(i + 1) * lda + i..], lda, tau[i..],
					1, mut a[(i + 1) * lda + i + 1..], lda)
				a[(i + 1) * lda + i] = e[i]
			}
			d[i] = a[i * lda + i]
			tau[i] = taui
		}
		d[n - 1] = a[(n - 1) * lda + n - 1]
	}
}
