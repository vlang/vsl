module lapack64

import math

// dsterf computes all eigenvalues of a symmetric tridiagonal matrix using the
// Pal-Walker-Kahan variant of the QL or QR algorithm.
//
// d contains the diagonal elements of the tridiagonal matrix on entry, and
// contains the eigenvalues in ascending order on exit. d must have length at
// least n, or dsterf will panic.
//
// e contains the off-diagonal elements of the tridiagonal matrix on entry, and is
// overwritten during the call to dsterf. e must have length of at least n-1 or
// dsterf will panic.
//
// dsterf is an internal routine. It is exported for testing purposes.
pub fn dsterf(n int, mut d []f64, mut e []f64) bool {
	if n < 0 {
		panic(n_lt0)
	}

	// Quick return if possible.
	if n == 0 {
		return true
	}

	if d.len < n {
		panic(short_d)
	}
	if e.len < n - 1 {
		panic(short_e)
	}

	if n == 1 {
		return true
	}

	none_scaled := 0 // The values are not scaled.
	down := 1 // The values are scaled below ssfmax threshold.
	up := 2 // The values are scaled below ssfmin threshold.

	// Determine the unit roundoff for this environment.
	eps := dlamch_e
	eps2 := eps * eps
	safmin := dlamch_s
	safmax := 1.0 / safmin
	ssfmax := math.sqrt(safmax) / 3.0
	ssfmin := math.sqrt(safmin) / eps2

	// Compute the eigenvalues of the tridiagonal matrix.
	maxit := 30
	nmaxit := n * maxit
	mut jtot := 0

	mut l1 := 0

	for {
		if l1 > n - 1 {
			dlasrt(.sort_increasing, n, mut d)
			return true
		}
		if l1 > 0 {
			e[l1 - 1] = 0
		}
		mut m := 0
		for m = l1; m < n - 1; m++ {
			if math.abs(e[m]) <= math.sqrt(math.abs(d[m])) * math.sqrt(math.abs(d[m + 1])) * eps {
				e[m] = 0
				break
			}
		}

		mut l := l1
		lsv := l
		mut lend := m
		lendsv := lend
		l1 = m + 1
		if lend == 0 {
			continue
		}

		// Scale submatrix in rows and columns l to lend.
		anorm := dlanst(.max_abs, lend - l + 1, d[l..], e[l..])
		mut iscale := none_scaled
		if anorm == 0.0 {
			continue
		}
		if anorm > ssfmax {
			iscale = down
			dlascl(.general, 0, 0, anorm, ssfmax, lend - l + 1, 1, mut d[l..], n)
			dlascl(.general, 0, 0, anorm, ssfmax, lend - l, 1, mut e[l..], n)
		} else if anorm < ssfmin {
			iscale = up
			dlascl(.general, 0, 0, anorm, ssfmin, lend - l + 1, 1, mut d[l..], n)
			dlascl(.general, 0, 0, anorm, ssfmin, lend - l, 1, mut e[l..], n)
		}

		mut el := unsafe { e[l..lend] }
		for i, v in el {
			el[i] *= v
		}

		// Choose between QL and QR iteration.
		if math.abs(d[lend]) < math.abs(d[l]) {
			lend = lsv
			l = lendsv
		}
		if lend >= l {
			// QL Iteration.
			// Look for small sub-diagonal element.
			for {
				if l != lend {
					for m = l; m < lend; m++ {
						if math.abs(e[m]) <= eps2 * (math.abs(d[m] * d[m + 1])) {
							break
						}
					}
				} else {
					m = lend
				}
				if m < lend {
					e[m] = 0
				}
				mut p := d[l]
				if m == l {
					// Eigenvalue found.
					l++
					if l > lend {
						break
					}
					continue
				}
				// If remaining matrix is 2 by 2, use Dlae2 to compute its eigenvalues.
				if m == l + 1 {
					d[l], d[l + 1] = dlae2(d[l], math.sqrt(e[l]), d[l + 1])
					e[l] = 0
					l += 2
					if l > lend {
						break
					}
					continue
				}
				if jtot == nmaxit {
					break
				}
				jtot++

				// Form shift.
				rte := math.sqrt(e[l])
				mut sigma := (d[l + 1] - p) / (2.0 * rte)
				r := dlapy2(sigma, 1.0)
				sigma = p - (rte / (sigma + math.copysign(r, sigma)))

				mut c := 1.0
				mut s := 0.0
				mut gamma := d[m] - sigma
				p = gamma * gamma

				// Inner loop.
				for i := m - 1; i >= l; i-- {
					bb := e[i]
					r_ := p + bb
					if i != m - 1 {
						e[i + 1] = s * r_
					}
					oldc := c
					c = p / r_
					s = bb / r_
					oldgam := gamma
					alpha := d[i]
					gamma = c * (alpha - sigma) - s * oldgam
					d[i + 1] = oldgam + (alpha - gamma)
					if c != 0.0 {
						p = (gamma * gamma) / c
					} else {
						p = oldc * bb
					}
				}
				e[l] = s * p
				d[l] = sigma + gamma
			}
		} else {
			for {
				// QR Iteration.
				// Look for small super-diagonal element.
				for m = l; m > lend; m-- {
					if math.abs(e[m - 1]) <= eps2 * math.abs(d[m] * d[m - 1]) {
						break
					}
				}
				if m > lend {
					e[m - 1] = 0
				}
				mut p := d[l]
				if m == l {
					// Eigenvalue found.
					l--
					if l < lend {
						break
					}
					continue
				}

				// If remaining matrix is 2 by 2, use Dlae2 to compute its eigenvalues.
				if m == l - 1 {
					d[l], d[l - 1] = dlae2(d[l], math.sqrt(e[l - 1]), d[l - 1])
					e[l - 1] = 0
					l -= 2
					if l < lend {
						break
					}
					continue
				}
				if jtot == nmaxit {
					break
				}
				jtot++

				// Form shift.
				rte := math.sqrt(e[l - 1])
				mut sigma := (d[l - 1] - p) / (2.0 * rte)
				r := dlapy2(sigma, 1.0)
				sigma = p - (rte / (sigma + math.copysign(r, sigma)))

				mut c := 1.0
				mut s := 0.0
				mut gamma := d[m] - sigma
				p = gamma * gamma

				// Inner loop.
				for i := m; i < l; i++ {
					bb := e[i]
					r_ := p + bb
					if i != m {
						e[i - 1] = s * r_
					}
					oldc := c
					c = p / r_
					s = bb / r_
					oldgam := gamma
					alpha := d[i + 1]
					gamma = c * (alpha - sigma) - s * oldgam
					d[i] = oldgam + alpha - gamma
					if c != 0.0 {
						p = (gamma * gamma) / c
					} else {
						p = oldc * bb
					}
				}
				e[l - 1] = s * p
				d[l] = sigma + gamma
			}
		}

		// Undo scaling if necessary
		match iscale {
			down {
				dlascl(.general, 0, 0, ssfmax, anorm, lendsv - lsv + 1, 1, mut d[lsv..],
					n)
			}
			up {
				dlascl(.general, 0, 0, ssfmin, anorm, lendsv - lsv + 1, 1, mut d[lsv..],
					n)
			}
			else {}
		}

		// Check for no convergence to an eigenvalue after a total of n*maxit iterations.
		if jtot >= nmaxit {
			break
		}
	}
	for v in e[0..n - 1] {
		if v != 0.0 {
			return false
		}
	}
	dlasrt(.sort_increasing, n, mut d)
	return true
}
