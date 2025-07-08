module lapack64

import math
import vsl.blas

// dlarf applies an elementary reflector H to an m×n matrix C:
//
//  C = H * C  if side == .left
//  C = C * H  if side == .right
//
// H is represented in the form
//
//  H = I - tau * v * vᵀ
//
// where tau is a scalar and v is a vector.
//
// work must have length at least m if side == .left and
// at least n if side == .right.
//
// dlarf is an internal routine. It is exported for testing purposes.
pub fn dlarf(side blas.Side, m int, n int, v []f64, incv int, tau f64, mut c []f64, ldc int, mut work []f64) {
	if side != .left && side != .right {
		panic(bad_side)
	}
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if incv == 0 {
		panic(zero_inc_v)
	}
	if ldc < math.max(1, n) {
		panic(bad_ld_c)
	}

	if m == 0 || n == 0 {
		return
	}

	applyleft := side == .left
	len_v := if applyleft { m } else { n }

	if v.len < 1 + (len_v - 1) * math.abs(incv) {
		panic(short_v)
	}
	if c.len < (m - 1) * ldc + n {
		panic(short_c)
	}
	if (applyleft && work.len < n) || (!applyleft && work.len < m) {
		panic(short_work)
	}

	mut lastv := -1 // last non-zero element of v
	mut lastc := -1 // last non-zero row/column of C
	if tau != 0 {
		lastv = if applyleft { m - 1 } else { n - 1 }
		mut i := if incv > 0 { lastv * incv } else { 0 }
		// Look for the last non-zero row in v.
		for lastv >= 0 && v[i] == 0 {
			lastv--
			i -= incv
		}
		if applyleft {
			// Scan for the last non-zero column in C[0:lastv, :]
			lastc = iladlc(lastv + 1, n, c, ldc)
		} else {
			// Scan for the last non-zero row in C[:, 0:lastv]
			lastc = iladlr(m, lastv + 1, c, ldc)
		}
	}
	if lastv == -1 || lastc == -1 {
		return
	}

	if applyleft {
		// Form H * C
		// w[0:lastc+1] = c[1:lastv+1, 1:lastc+1]ᵀ * v[1:lastv+1,1]
		blas.dgemv(.trans, lastv + 1, lastc + 1, 1.0, c, ldc, v, incv, 0.0, mut work,
			1)
		// c[0: lastv, 0: lastc] = c[...] - w[0:lastv, 1] * v[1:lastc, 1]ᵀ
		blas.dger(lastv + 1, lastc + 1, -tau, v, incv, work, 1, mut c, ldc)
	} else {
		// Form C * H
		// w[0:lastc+1,1] := c[0:lastc+1,0:lastv+1] * v[0:lastv+1,1]
		blas.dgemv(.no_trans, lastc + 1, lastv + 1, 1.0, c, ldc, v, incv, 0.0, mut work,
			1)
		// c[0:lastc+1,0:lastv+1] = c[...] - w[0:lastc+1,0] * v[0:lastv+1,0]ᵀ
		blas.dger(lastc + 1, lastv + 1, -tau, work, 1, v, incv, mut c, ldc)
	}
}
