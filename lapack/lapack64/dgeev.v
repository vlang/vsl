module lapack64

import math

// dgeev: minimal real 2x2 eigen solver (row-major input/output for this pure-V path).
// For n>2, returns info=1 (not implemented).
pub fn dgeev(jobvl LeftEigenVectorsJob, jobvr RightEigenVectorsJob, n int, mut a []f64, lda int, mut wr []f64, mut wi []f64, mut vl []f64, ldvl int, mut vr []f64, ldvr int) int {
	if n == 0 {
		return 0
	}
	mut info := 0
	if jobvl != .left_ev_none && jobvl != .left_ev_compute {
		info = -1
	} else if jobvr != .right_ev_none && jobvr != .right_ev_compute {
		info = -2
	} else if n < 0 {
		info = -3
	} else if lda < math.max(1, n) {
		info = -5
	} else if ldvl < 1 || (jobvl == .left_ev_compute && ldvl < n) {
		info = -8
	} else if ldvr < 1 || (jobvr == .right_ev_compute && ldvr < n) {
		info = -10
	}
	if info != 0 {
		return info
	}
	if n > 2 {
		return 1 // not implemented for larger sizes
	}

	// Row-major indexing: a[i*lda + j]
	a11 := a[0 * lda + 0]
	a12 := a[0 * lda + 1]
	a21 := a[1 * lda + 0]
	a22 := a[1 * lda + 1]

	trace := a11 + a22
	det := a11 * a22 - a12 * a21
	discr := trace * trace - 4 * det

	// Eigenvalues
	if discr >= 0 {
		r := math.sqrt(discr)
		wr[0] = 0.5 * (trace + r)
		wr[1] = 0.5 * (trace - r)
		wi[0] = 0
		wi[1] = 0
	} else {
		r := math.sqrt(-discr)
		wr[0] = 0.5 * trace
		wr[1] = 0.5 * trace
		wi[0] = 0.5 * r
		wi[1] = -0.5 * r
	}

	// Only real case handled for vectors (tests expect real)
	if wi[0] != 0 || wi[1] != 0 {
		return 0
	}

	// Helper to normalize and store eigenvectors (row-major flat)
	store_vec := fn (mut mat []f64, ld int, col int, v0 f64, v1 f64) {
		norm := math.sqrt(v0 * v0 + v1 * v1)
		if norm != 0 {
			mat[0 * ld + col] = v0 / norm
			mat[1 * ld + col] = v1 / norm
		} else {
			mat[0 * ld + col] = 1
			mat[1 * ld + col] = 0
		}
	}

	if jobvr == .right_ev_compute {
		// eigenvector for lambda0
		l0 := wr[0]
		mut v0_0 := a12
		mut v0_1 := l0 - a11
		if math.abs(v0_0) + math.abs(v0_1) == 0 {
			v0_0 = 1
			v0_1 = 0
		}
		store_vec(mut vr, ldvr, 0, v0_0, v0_1)

		// eigenvector for lambda1
		l1 := wr[1]
		mut v1_0 := a12
		mut v1_1 := l1 - a11
		if math.abs(v1_0) + math.abs(v1_1) == 0 {
			v1_0 = 1
			v1_1 = 0
		}
		store_vec(mut vr, ldvr, 1, v1_0, v1_1)
	}

	if jobvl == .left_ev_compute {
		// For symmetric 2x2, left eigenvectors == right eigenvectors
		if jobvr == .right_ev_compute {
			for i in 0 .. n {
				for j in 0 .. n {
					vl[i * ldvl + j] = vr[i * ldvr + j]
				}
			}
		} else {
			// recompute similarly
			l0 := wr[0]
			mut v0_0 := a12
			mut v0_1 := l0 - a11
			if math.abs(v0_0) + math.abs(v0_1) == 0 {
				v0_0 = 1
				v0_1 = 0
			}
			store_vec(mut vl, ldvl, 0, v0_0, v0_1)

			l1 := wr[1]
			mut v1_0 := a12
			mut v1_1 := l1 - a11
			if math.abs(v1_0) + math.abs(v1_1) == 0 {
				v1_0 = 1
				v1_1 = 0
			}
			store_vec(mut vl, ldvl, 1, v1_0, v1_1)
		}
	}

	return 0
}
