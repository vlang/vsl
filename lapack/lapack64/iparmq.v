module lapack64

import math

fn iparmq(ispec int, name string, opts string, n int, ilo int, ihi int, lwork int) int {
	nh := ihi - ilo + 1
	mut ns := 2
	if nh >= 30 {
		ns = 4
	} else if nh >= 60 {
		ns = 10
	} else if nh >= 150 {
		ns = math.max(10, nh / int(math.log(nh) / math.ln2))
	} else if nh >= 590 {
		ns = 64
	} else if nh >= 3000 {
		ns = 128
	} else if nh >= 6000 {
		ns = 256
	}
	ns = math.max(2, ns - (ns % 2))

	match ispec {
		12 {
			// Matrices of order smaller than nmin get sent to Dlahqr, the
			// classic double shift algorithm. This must be at least 11.
			nmin := 75
			return nmin
		}
		13 {
			knwswp := 500
			if nh <= knwswp {
				return ns
			}
			return 3 * ns / 2
		}
		14 {
			// Skip a computationally expensive multi-shift QR sweep with
			// Dlaqr5 whenever aggressive early deflation finds at least
			// nibble*(window size)/100 deflations. The default, small,
			// value reflects the expectation that the cost of looking
			// through the deflation window with Dlaqr3 will be
			// substantially smaller.
			nibble := 14
			return nibble
		}
		15 {
			return ns
		}
		16 {
			if name.len != 6 {
				panic('bad name length')
			}
			k22min := 14
			kacmin := 14
			mut acc22 := 0
			if name[1..].starts_with('GGHRD') || name[1..].starts_with('GGHD3') {
				acc22 = 1
				if nh >= k22min {
					acc22 = 2
				}
			} else if name[3..].starts_with('EXC') {
				if nh >= kacmin {
					acc22 = 1
				}
				if nh >= k22min {
					acc22 = 2
				}
			} else if name[1..].starts_with('HSEQR') || name[1..5].starts_with('LAQR') {
				if ns >= kacmin {
					acc22 = 1
				}
				if ns >= k22min {
					acc22 = 2
				}
			}
			return acc22
		}
		else {
			panic('bad ispec')
		}
	}
}
