module lapack64

import math
import vsl.blas

// dsteqr computes the eigenvalues and optionally the eigenvectors of a symmetric
// tridiagonal matrix using the implicit QL or QR method. The eigenvectors of a
// full or band symmetric matrix can also be found if dsytrd, dsptrd, or dsbtrd
// have been used to reduce this matrix to tridiagonal form.
//
// d, on entry, contains the diagonal elements of the tridiagonal matrix. On exit,
// d contains the eigenvalues in ascending order. d must have length n and
// dsteqr will panic otherwise.
//
// e, on entry, contains the off-diagonal elements of the tridiagonal matrix on
// entry, and is overwritten during the call to dsteqr. e must have length n-1 and
// dsteqr will panic otherwise.
//
// z, on entry, contains the n×n orthogonal matrix used in the reduction to
// tridiagonal form if compz == lapack.EigenVectorsOrig. On exit, if
// compz == lapack.EigenVectorsOrig, z contains the orthonormal eigenvectors of the
// original symmetric matrix, and if compz == lapack.EigenVectorsTridiag, z contains the
// orthonormal eigenvectors of the symmetric tridiagonal matrix. z is not used
// if compz == lapack.EigenVectorsCompNone.
//
// work must have length at least max(1, 2*n-2) if the eigenvectors are computed,
// and dsteqr will panic otherwise.
//
// dsteqr is an internal routine. It is exported for testing purposes.
pub fn dsteqr(compz EigenVectorsComp, n int, mut d []f64, mut e []f64, mut z []f64, ldz int, mut work []f64) bool {
	if compz != .ev_comp_none && compz != .ev_tridiag && compz != .ev_orig {
		panic('bad_ev_comp')
	}
	if n < 0 {
		panic('n < 0')
	}
	if ldz < 1 || (compz != .ev_comp_none && ldz < n) {
		panic('bad_ldz')
	}

	// Quick return if possible.
	if n == 0 {
		return true
	}

	if d.len < n {
		panic('short d')
	}
	if e.len < n - 1 {
		panic('short e')
	}
	if compz != .ev_comp_none && z.len < (n - 1) * ldz + n {
		panic('short z')
	}
	if compz != .ev_comp_none && work.len < math.max(1, 2 * n - 2) {
		panic('short work')
	}

	mut icompz := 0
	if compz == .ev_orig {
		icompz = 1
	} else if compz == .ev_tridiag {
		icompz = 2
	}

	if n == 1 {
		if icompz == 2 {
			z[0] = 1
		}
		return true
	}

	eps := dlamch_e
	eps2 := eps * eps
	safmin := dlamch_s
	safmax := 1 / safmin
	ssfmax := math.sqrt(safmax) / 3
	ssfmin := math.sqrt(safmin) / eps2

	// Compute the eigenvalues and eigenvectors of the tridiagonal matrix.
	if icompz == 2 {
		dlaset(.all, n, n, 0, 1, mut z, ldz)
	}
	maxit := 30
	nmaxit := n * maxit

	mut jtot := 0

	// Determine where the matrix splits and choose QL or QR iteration for each
	// block, according to whether top or bottom diagonal element is smaller.
	mut l1 := 0
	nm1 := n - 1

	down := 1
	up := 2
	mut iscale := 0

	for {
		if l1 > n - 1 {
			// Order eigenvalues and eigenvectors.
			if icompz == 0 {
				dlasrt(.sort_increasing, n, mut d)
			} else {
				for ii := 1; ii < n; ii++ {
					i := ii - 1
					mut k := i
					mut p := d[i]
					for j := ii; j < n; j++ {
						if d[j] < p {
							k = j
							p = d[j]
						}
					}
					if k != i {
						d[k] = d[i]
						d[i] = p
						blas.dswap(n, mut z[i..], ldz, mut z[k..], ldz)
					}
				}
			}
			return true
		}
		if l1 > 0 {
			e[l1 - 1] = 0
		}
		mut m := 0
		if l1 <= nm1 {
			for m = l1; m < nm1; m++ {
				test := math.abs(e[m])
				if test == 0 {
					break
				}
				if test <= (math.sqrt(math.abs(d[m])) * math.sqrt(math.abs(d[m + 1]))) * eps {
					e[m] = 0
					break
				}
			}
		}
		mut l := l1
		lsv := l
		mut lend := m
		lendsv := lend
		l1 = m + 1
		if lend == l {
			continue
		}

		// Scale submatrix in rows and columns L to Lend
		anorm := dlanst(.max_abs, lend - l + 1, d[l..], e[l..])
		match anorm {
			0 {
				continue
			}
			ssfmax {
				iscale = down
				// Pretend that d and e are matrices with 1 column.
				dlascl(.general, 0, 0, anorm, ssfmax, lend - l + 1, 1, mut d[l..], 1)
				dlascl(.general, 0, 0, anorm, ssfmax, lend - l, 1, mut e[l..], 1)
			}
			ssfmin {
				iscale = up
				dlascl(.general, 0, 0, anorm, ssfmin, lend - l + 1, 1, mut d[l..], 1)
				dlascl(.general, 0, 0, anorm, ssfmin, lend - l, 1, mut e[l..], 1)
			}
			else {}
		}

		// Choose between QL and QR.
		if math.abs(d[lend]) < math.abs(d[l]) {
			lend = lsv
			l = lendsv
		}
		if lend > l {
			// QL Iteration. Look for small subdiagonal element.
			for {
				if l != lend {
					for m = l; m < lend; m++ {
						v := math.abs(e[m])
						if v * v <= (eps2 * math.abs(d[m])) * math.abs(d[m + 1]) + safmin {
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

				// If remaining matrix is 2×2, use dlaev2 to compute its eigensystem.
				if m == l + 1 {
					if icompz > 0 {
						d[l], d[l + 1], work[l], work[n - 1 + l] = dlaev2(d[l], e[l],
							d[l + 1])
						dlasr(.right, .variable, .backward, n, 2, work[l..], work[n - 1 + l..], mut
							z[l..], ldz)
					} else {
						d[l], d[l + 1] = dlae2(d[l], e[l], d[l + 1])
					}
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

				// Form shift
				mut g := (d[l + 1] - p) / (2 * e[l])
				mut r := dlapy2(g, 1)
				g = d[m] - p + e[l] / (g + math.copysign(r, g))
				mut s := 1.0
				mut c := 1.0
				p = 0.0

				// Inner loop
				for i := m - 1; i >= l; i-- {
					f := s * e[i]
					b := c * e[i]
					c, s, r = dlartg(g, f)
					if i != m - 1 {
						e[i + 1] = r
					}
					g = d[i + 1] - p
					r = (d[i] - g) * s + 2 * c * b
					p = s * r
					d[i + 1] = g + p
					g = c * r - b

					// If eigenvectors are desired, then save rotations.
					if icompz > 0 {
						work[i] = c
						work[n - 1 + i] = -s
					}
				}
				// If eigenvectors are desired, then apply saved rotations.
				if icompz > 0 {
					mm := m - l + 1
					dlasr(.right, .variable, .backward, n, mm, work[l..], work[n - 1 + l..], mut
						z[l..], ldz)
				}
				d[l] -= p
				e[l] = g
			}
		} else {
			// QR Iteration.
			// Look for small superdiagonal element.
			for {
				if l != lend {
					for m = l; m > lend; m-- {
						v := math.abs(e[m - 1])
						if v * v <= (eps2 * math.abs(d[m]) * math.abs(d[m - 1]) + safmin) {
							break
						}
					}
				} else {
					m = lend
				}
				if m > lend {
					e[m - 1] = 0
				}
				mut p := d[l]
				if m == l {
					// Eigenvalue found
					l--
					if l < lend {
						break
					}
					continue
				}

				// If remaining matrix is 2×2, use dlae2 to compute its eigenvalues.
				if m == l - 1 {
					if icompz > 0 {
						d[l - 1], d[l], work[m], work[n - 1 + m] = dlaev2(d[l - 1], e[l - 1],
							d[l])
						dlasr(.right, .variable, .forward, n, 2, work[m..], work[n - 1 + m..], mut
							z[l - 1..], ldz)
					} else {
						d[l - 1], d[l] = dlae2(d[l - 1], e[l - 1], d[l])
					}
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
				mut g := (d[l - 1] - p) / (2 * e[l - 1])
				mut r := dlapy2(g, 1)
				g = d[m] - p + (e[l - 1]) / (g + math.copysign(r, g))
				mut s := 1.0
				mut c := 1.0
				p = 0.0

				// Inner loop.
				for i := m; i < l; i++ {
					f := s * e[i]
					b := c * e[i]
					c, s, r = dlartg(g, f)
					if i != m {
						e[i - 1] = r
					}
					g = d[i] - p
					r = (d[i + 1] - g) * s + 2 * c * b
					p = s * r
					d[i] = g + p
					g = c * r - b

					// If eigenvectors are desired, then save rotations.
					if icompz > 0 {
						work[i] = c
						work[n - 1 + i] = s
					}
				}

				// If eigenvectors are desired, then apply saved rotations.
				if icompz > 0 {
					mm := l - m + 1
					dlasr(.right, .variable, .forward, n, mm, work[m..], work[n - 1 + m..], mut
						z[m..], ldz)
				}
				d[l] -= p
				e[l - 1] = g
			}
		}

		// Undo scaling if necessary.
		match iscale {
			down {
				// Pretend that d and e are matrices with 1 column.
				dlascl(.general, 0, 0, ssfmax, anorm, lendsv - lsv + 1, 1, mut d[lsv..],
					1)
				dlascl(.general, 0, 0, ssfmax, anorm, lendsv - lsv, 1, mut e[lsv..], 1)
			}
			up {
				dlascl(.general, 0, 0, ssfmin, anorm, lendsv - lsv + 1, 1, mut d[lsv..],
					1)
				dlascl(.general, 0, 0, ssfmin, anorm, lendsv - lsv, 1, mut e[lsv..], 1)
			}
			else {}
		}

		// Check for no convergence to an eigenvalue after a total of n*maxit iterations.
		if jtot >= nmaxit {
			break
		}
	}
	for i := 0; i < n - 1; i++ {
		if e[i] != 0 {
			return false
		}
	}
	return true
}
