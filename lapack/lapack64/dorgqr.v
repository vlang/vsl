module lapack64

import math
import vsl.blas

pub fn dorgqr(m int, n int, k int, mut a []f64, lda int, tau []f64, mut work []f64, lwork int) {
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
	if lda < math.max(1, n) && lwork != -1 {
		panic(bad_ld_a)
	}
	if lwork < math.max(1, n) && lwork != -1 {
		panic(bad_l_work)
	}
	if work.len < math.max(1, lwork) {
		panic(short_work)
	}

	if n == 0 {
		work[0] = 1.0
		return
	}

	mut nb := ilaenv(1, 'DORGQR', ' ', m, n, k, -1)
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

	mut nbmin := 2
	mut nx := 0
	mut iws := n
	mut ldwork := 0
	if 1 < nb && nb < k {
		nx = math.max(0, ilaenv(3, 'DORGQR', ' ', m, n, k, -1))
		if nx < k {
			ldwork = nb
			iws = n * ldwork
			if lwork < iws {
				nb = lwork / n
				ldwork = nb
				nbmin = math.max(2, ilaenv(2, 'DORGQR', ' ', m, n, k, -1))
			}
		}
	}
	mut ki := 0
	mut kk := 0
	if nbmin <= nb && nb < k && nx < k {
		ki = ((k - nx - 1) / nb) * nb
		kk = math.min(k, ki + nb)
		for i := 0; i < kk; i++ {
			for j := kk; j < n; j++ {
				unsafe {
					a[i * lda + j] = 0.0
				}
			}
		}
	}
	if kk < n {
		dorg2r(m - kk, n - kk, k - kk, mut a[(kk * lda + kk)..], lda, tau[kk..], mut work)
	}
	if kk > 0 {
		for i := ki; i >= 0; i -= nb {
			ib := math.min(nb, k - i)
			if i + ib < n {
				dlarft(.forward, .column_wise, m - i, ib, a[(i * lda + i)..], lda, tau[i..], mut
					work, ldwork)

				dlarfb(.left, .no_trans, .forward, .column_wise, m - i, n - i - ib, ib,
					a[(i * lda + i)..], lda, work, ldwork, mut a[(i * lda + i + ib)..],
					lda, mut work[(ib * ldwork)..], ldwork)
			}
			dorg2r(m - i, ib, ib, mut a[(i * lda + i)..], lda, tau[i..(i + ib)], mut work)
			for j := i; j < i + ib; j++ {
				for l := 0; l < i; l++ {
					unsafe {
						a[l * lda + j] = 0.0
					}
				}
			}
		}
	}
	work[0] = f64(iws)
}
