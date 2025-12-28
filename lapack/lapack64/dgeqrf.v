module lapack64

import math

// dgeqrf computes the QR factorization of the m×n matrix A using a blocked
// algorithm. See the documentation for dgeqr2 for a description of the
// parameters at entry and exit.
//
// work is temporary storage, and lwork specifies the usable memory length.
// The length of work must be at least max(1, lwork) and lwork must be -1
// or at least n, otherwise this function will panic.
// dgeqrf is a blocked QR factorization, but the block size is limited
// by the temporary space available. If lwork == -1, instead of performing dgeqrf,
// the optimal work length will be stored into work[0].
//
// tau must have length min(m,n), and this function will panic otherwise.
pub fn dgeqrf(m int, n int, mut a []f64, lda int, mut tau []f64, mut work []f64, lwork int) {
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
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
	k := math.min(m, n)
	if k == 0 {
		work[0] = 1.0
		return
	}

	// nb is the optimal blocksize, i.e. the number of columns transformed at a time.
	mut nb := ilaenv(1, 'DGEQRF', ' ', m, n, -1, -1)
	if lwork == -1 {
		work[0] = f64(n * nb)
		return
	}

	if a.len < (m - 1) * lda + n {
		panic(short_a)
	}
	if tau.len != k {
		panic(bad_len_tau)
	}

	mut nbmin := 2 // Minimal block size.
	mut nx := 0 // Use unblocked (unless changed in the next for loop)
	mut iws := n
	// Only consider blocked if the suggested block size is > 1 and the
	// number of rows or columns is sufficiently large.
	if 1 < nb && nb < k {
		// nx is the block size at which the code switches from blocked
		// to unblocked.
		nx = math.max(0, ilaenv(3, 'DGEQRF', ' ', m, n, -1, -1))
		if k > nx {
			iws = n * nb
			if lwork < iws {
				// Not enough workspace to use the optimal block
				// size. Get the minimum block size instead.
				nb = lwork / n
				nbmin = math.max(2, ilaenv(2, 'DGEQRF', ' ', m, n, -1, -1))
			}
		}
	}

	// Compute QR using a blocked algorithm.
	mut i := 0
	if nbmin <= nb && nb < k && nx < k {
		ldwork := nb
		for i < k - nx {
			ib := math.min(k - i, nb)
			// Compute the QR factorization of the current block.
			mut a_block := unsafe { a[i * lda + i..] }
			mut tau_block := unsafe { tau[i..i + ib] }
			dgeqr2(m - i, ib, mut a_block, lda, mut tau_block, mut work)
			if i + ib < n {
				// Form the triangular factor of the block reflector and apply Hᵀ
				// In dlarft, work becomes the T matrix.
				mut t_work := unsafe { work[..ib * ldwork] }
				dlarft(.forward, .column_wise, m - i, ib, a_block, lda, tau_block, mut t_work,
					ldwork)
				mut a_right := unsafe { a[i * lda + i + ib..] }
				mut work_right := unsafe { work[ib * ldwork..] }
				dlarfb(.left, .trans, .forward, .column_wise, m - i, n - i - ib, ib, a_block,
					lda, t_work, ldwork, mut a_right, lda, mut work_right, ldwork)
			}
			i += nb
		}
	}
	// Call unblocked code on the remaining columns.
	if i < k {
		mut a_rem := unsafe { a[i * lda + i..] }
		mut tau_rem := unsafe { tau[i..] }
		dgeqr2(m - i, n - i, mut a_rem, lda, mut tau_rem, mut work)
	}
	work[0] = f64(iws)
}

