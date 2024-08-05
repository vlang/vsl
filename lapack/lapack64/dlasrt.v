module lapack64

import math

// dlasrt sorts the numbers in the input slice d. If s == .increasing,
// the elements are sorted in increasing order. If s == .decreasing,
// the elements are sorted in decreasing order. For other values of s dlasrt
// will panic.
//
// dlasrt is an internal routine. It is exported for testing purposes.
pub fn dlasrt(s Sort, n int, mut d []f64) {
	if n < 0 {
		panic(n_lt0)
	}
	if d.len < n {
		panic(short_d)
	}

	d = unsafe { d[..n] }
	match s {
		.sort_increasing {
			d.sort()
		}
		.sort_decreasing {
			d.sort(b < a)
		}
	}
}
