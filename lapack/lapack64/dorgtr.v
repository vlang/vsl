module lapack64

import math
import vsl.blas

// dorgtr generates a real orthogonal matrix Q which is defined as the product
// of n-1 elementary reflectors of order n as returned by dsytrd.
//
// The construction of Q depends on the value of uplo:
//
//  Q = H_{n-1} * ... * H_1 * H_0  if uplo == blas.Upper
//  Q = H_0 * H_1 * ... * H_{n-1}  if uplo == blas.Lower
//
// where H_i is constructed from the elementary reflectors as computed by dsytrd.
// See the documentation for dsytrd for more information.
//
// tau must have length at least n-1, and dorgtr will panic otherwise.
//
// work is temporary storage, and lwork specifies the usable memory length. At
// minimum, lwork >= max(1,n-1), and dorgtr will panic otherwise. The amount of blocking
// is limited by the usable length.
// If lwork == -1, instead of computing dorgtr the optimal work length is stored
// into work[0].
//
// dorgtr is an internal routine. It is exported for testing purposes.
pub fn dorgtr(uplo blas.Uplo, n int, mut a []f64, lda int, tau []f64, mut work []f64, lwork int) {
	if uplo != .upper && uplo != .lower {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if lwork < math.max(1, n - 1) && lwork != -1 {
		panic(bad_l_work)
	}
	if work.len < math.max(1, lwork) {
		panic(short_work)
	}

	if n == 0 {
		work[0] = 1
		return
	}

	mut nb := 0
	if uplo == .upper {
		nb = ilaenv(1, 'DORGQL', ' ', n - 1, n - 1, n - 1, -1)
	} else {
		nb = ilaenv(1, 'DORGQR', ' ', n - 1, n - 1, n - 1, -1)
	}
	lworkopt := math.max(1, n - 1) * nb
	if lwork == -1 {
		work[0] = f64(lworkopt)
		return
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}
	if tau.len < n - 1 {
		panic(short_tau)
	}

	if uplo == .upper {
		// Q was determined by a call to dsytrd with uplo == blas.Upper.
		// Shift the vectors which define the elementary reflectors one column
		// to the left, and set the last row and column of Q to those of the unit
		// matrix.
		for j := 0; j < n - 1; j++ {
			for i := 0; i < j; i++ {
				a[i * lda + j] = unsafe { a[i * lda + j + 1] }
			}
			a[(n - 1) * lda + j] = 0
		}
		for i := 0; i < n - 1; i++ {
			a[i * lda + n - 1] = 0
		}
		a[(n - 1) * lda + n - 1] = 1

		// Generate Q[0:n-1, 0:n-1].
		dorgql(n - 1, n - 1, n - 1, mut a, lda, tau, mut work, lwork)
	} else {
		// Q was determined by a call to dsytrd with uplo == blas.Lower.
		// Shift the vectors which define the elementary reflectors one column
		// to the right, and set the first row and column of Q to those of the unit
		// matrix.
		for j := n - 1; j > 0; j-- {
			a[j] = 0
			for i := j + 1; i < n; i++ {
				a[i * lda + j] = unsafe { a[i * lda + j - 1] }
			}
		}
		a[0] = 1
		for i := 1; i < n; i++ {
			a[i * lda] = 0
		}
		if n > 1 {
			mut a_sub := unsafe { a[lda + 1..] }
			// Generate Q[1:n, 1:n].
			dorgqr(n - 1, n - 1, n - 1, mut a_sub, lda, tau[..n - 1], mut work, lwork)
		}
	}
	work[0] = f64(lworkopt)
}
