module lapack64

import math
import vsl.blas

// dgeev computes the eigenvalues and, optionally, the left and/or right eigenvectors for a real nonsymmetric matrix A.
pub fn dgeev(jobvl LeftEigenVectorsJob, jobvr LeftEigenVectorsJob, n int, mut a []f64, lda int, wr []f64, wi []f64, mut vl []f64, ldvl int, mut vr []f64, ldvr int) int {
	if n == 0 {
		return 0
	}

	mut info := 0
	if jobvl != .left_ev_none && jobvl != .left_ev_compute {
		info = -1
	} else if jobvr != .left_ev_none && jobvr != .left_ev_compute {
		info = -2
	} else if n < 0 {
		info = -3
	} else if lda < math.max(1, n) {
		info = -5
	} else if ldvl < 1 || (jobvl == .left_ev_compute && ldvl < n) {
		info = -8
	} else if ldvr < 1 || (jobvr == .left_ev_compute && ldvr < n) {
		info = -10
	}

	if info != 0 {
		return info
	}

	// Quick return if possible
	if n == 0 {
		return 0
	}

	// Placeholder for the actual LAPACK function calls
	// Example: info = dgehrd(n, ilo, ihi, a, lda, tau, work, lwork)
	return info
}
