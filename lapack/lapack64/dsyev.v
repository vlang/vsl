module lapack64

import math
import vsl.blas

pub fn dsyev(jobz EigenVectorsJob, uplo blas.Uplo, n int, mut a []f64, lda int, mut w []f64, mut work []f64, lwork int) {
	if jobz != .ev_none && jobz != .ev_compute {
		panic(bad_ev_job)
	}
	if uplo != .upper && uplo != .lower {
		panic(bad_uplo)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if lwork < math.max(1, 3 * n - 1) && lwork != -1 {
		panic(bad_l_work)
	}
	if work.len < math.max(1, lwork) {
		panic(short_work)
	}

	// Quick return if possible.
	if n == 0 {
		return
	}

	opts := if uplo == .upper { 'U' } else { 'L' }
	nb := ilaenv(1, 'DSYTRD', opts, n, -1, -1, -1)
	lworkopt := math.max(1, (nb + 2) * n)
	if lwork == -1 {
		work[0] = f64(lworkopt)
		return
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}
	if w.len < n {
		panic(short_w)
	}

	if n == 1 {
		w[0] = a[0]
		work[0] = 2
		if jobz == .ev_compute {
			a[0] = 1
		}
		return
	}

	safmin := dlamch_s
	eps := dlamch_p
	smlnum := safmin / eps
	bignum := 1 / smlnum
	rmin := math.sqrt(smlnum)
	rmax := math.sqrt(bignum)

	// Scale matrix to allowable range, if necessary.
	anrm := dlansy(.max_abs, uplo, n, a, lda, mut work)
	mut scaled := false
	mut sigma := f64(0)
	if anrm > 0 && anrm < rmin {
		scaled = true
		sigma = rmin / anrm
	} else if anrm > rmax {
		scaled = true
		sigma = rmax / anrm
	}
	if scaled {
		kind := if uplo == .upper { MatrixType.upper_tri } else { MatrixType.lower_tri }
		dlascl(kind, 0, 0, 1, sigma, n, n, mut a, lda)
	}
	inde := 0
	indtau := inde + n
	indwork := indtau + n
	llwork := lwork - indwork
	dsytrd(uplo, n, mut a, lda, mut w, mut work[inde..], mut work[indtau..], mut work[indwork..],
		llwork)

	// For eigenvalues only, call Dsterf. For eigenvectors, first call Dorgtr
	// to generate the orthogonal matrix, then call Dsteqr.
	if jobz == .ev_none {
		if !dsterf(n, mut w, mut work[inde..]) {
			panic('Dsterf failed')
		}
	} else {
		dorgtr(uplo, n, mut a, lda, work[indtau..], mut work[indwork..], llwork)
		if !dsteqr(EigenVectorsComp(jobz), n, mut w, mut work[inde..], mut a, lda, mut
			work[indtau..]) {
			panic('Dsteqr failed')
		}
	}

	// If the matrix was scaled, then rescale eigenvalues appropriately.
	if scaled {
		blas.dscal(n, 1 / sigma, mut w, 1)
	}
	work[0] = f64(lworkopt)
}
