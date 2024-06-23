module lapack64

import math
import vsl.blas

// dorgql generates the m×n matrix Q with orthonormal columns defined as the
// last n columns of a product of k elementary reflectors of order m
//
//  Q = H_{k-1} * ... * H_1 * H_0.
//
// It must hold that
//
//  0 <= k <= n <= m,
//
// and dorgql will panic otherwise.
//
// On entry, the (n-k+i)-th column of A must contain the vector which defines
// the elementary reflector H_i, for i=0,...,k-1, and tau[i] must contain its
// scalar factor. On return, a contains the m×n matrix Q.
//
// tau must have length at least k, and dorgql will panic otherwise.
//
// work must have length at least max(1,lwork), and lwork must be at least
// max(1,n), otherwise dorgql will panic. For optimum performance lwork must
// be a sufficiently large multiple of n.
//
// If lwork == -1, instead of computing dorgql the optimal work length is stored
// into work[0].
//
// dorgql is an internal routine. It is exported for testing purposes.
pub fn dorgql(m int, n int, k int, mut a []f64, lda int, tau []f64, mut work []f64, lwork int) {
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if n > m {
		panic(n_gtm)
	}
	if k < 0 {
		panic(k_lt0)
	}
	if k > n {
		panic(k_gtn)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if lwork < math.max(1, n) && lwork != -1 {
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

	mut nb := ilaenv(1, 'DORGQL', ' ', m, n, k, -1)
	if lwork == -1 {
		work[0] = f64(n * nb)
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}
	if tau.len < k {
		panic(short_tau)
	}

	mut nbmin := 2
	mut nx := 0
	mut ldwork := 0
	mut iws := n
	if 1 < nb && nb < k {
		// Determine when to cross over from blocked to unblocked code.
		nx = math.max(0, ilaenv(3, 'DORGQL', ' ', m, n, k, -1))
		if nx < k {
			// Determine if workspace is large enough for blocked code.
			iws = n * nb
			if lwork < iws {
				// Not enough workspace to use optimal nb: reduce nb and determine
				// the minimum value of nb.
				nb = lwork / n
				nbmin = math.max(2, ilaenv(2, 'DORGQL', ' ', m, n, k, -1))
			}
			ldwork = nb
		}
	}

	mut kk := 0
	if nbmin <= nb && nb < k && nx < k {
		// Use blocked code after the first block. The last kk columns are handled
		// by the block method.
		kk = math.min(k, ((k - nx + nb - 1) / nb) * nb)

		// Set A(m-kk:m, 0:n-kk) to zero.
		for i := m - kk; i < m; i++ {
			for j := 0; j < n - kk; j++ {
				a[i * lda + j] = 0
			}
		}
	}

	// Use unblocked code for the first or only block.
	dorg2l(m - kk, n - kk, k - kk, mut a, lda, tau, mut work)
	if kk > 0 {
		// Use blocked code.
		for i := k - kk; i < k; i += nb {
			ib := math.min(nb, k - i)
			if n - k + i > 0 {
				// Form the triangular factor of the block reflector
				// H = H_{i+ib-1} * ... * H_{i+1} * H_i.
				dlarft(.backward, .column_wise, m - k + i + ib, ib, a[n - k + i..], lda,
					tau[i..], mut work, ldwork)

				// Apply H to A[0:m-k+i+ib, 0:n-k+i] from the left.
				dlarfb(.left, .no_trans, .backward, .column_wise, m - k + i + ib, n - k + i,
					ib, a[n - k + i..], lda, work, ldwork, mut a, lda, mut work[ib * ldwork..],
					ldwork)
			}

			// Apply H to rows 0:m-k+i+ib of current block.
			dorg2l(m - k + i + ib, ib, ib, mut a[n - k + i..], lda, tau[i..], mut work)

			// Set rows m-k+i+ib:m of current block to zero.
			for j := n - k + i; j < n - k + i + ib; j++ {
				for l := m - k + i + ib; l < m; l++ {
					a[l * lda + j] = 0
				}
			}
		}
	}
	work[0] = f64(iws)
}
