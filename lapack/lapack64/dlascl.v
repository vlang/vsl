module lapack64

import math

// dlascl multiplies an m×n matrix by the scalar cto/cfrom.
//
// cfrom must not be zero, and cto and cfrom must not be NaN, otherwise dlascl
// will panic.
//
// dlascl is an internal routine. It is exported for testing purposes.
pub fn dlascl(kind MatrixType, kl int, ku int, cfrom f64, cto f64, m int, n int, mut a []f64, lda int) {
	match kind {
		.general, .upper_tri, .lower_tri {
			if lda < math.max(1, n) {
				panic(bad_ld_a)
			}
		}
	}
	if cfrom == 0.0 {
		panic(zero_c_from)
	}
	if math.is_nan(cfrom) {
		panic(nan_c_from)
	}
	if math.is_nan(cto) {
		panic(nan_c_to)
	}
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}

	if n == 0 || m == 0 {
		return
	}

	match kind {
		.general, .upper_tri, .lower_tri {
			if a.len < (m - 1) * lda + n {
				panic(short_a)
			}
		}
	}

	smlnum := dlamch_s
	bignum := 1.0 / smlnum
	mut cfromc := cfrom
	mut ctoc := cto
	mut cfrom1 := cfromc * smlnum
	for {
		mut done := false
		mut mul := 0.0
		mut ctol := 0.0
		if cfrom1 == cfromc {
			// cfromc is inf.
			mul = ctoc / cfromc
			done = true
			ctol = ctoc
		} else {
			ctol = ctoc / bignum
			if ctol == ctoc {
				// ctoc is either 0 or inf.
				mul = ctoc
				done = true
				cfromc = 1.0
			} else if math.abs(cfrom1) > math.abs(ctoc) && ctoc != 0.0 {
				mul = smlnum
				done = false
				cfromc = cfrom1
			} else if math.abs(ctol) > math.abs(cfromc) {
				mul = bignum
				done = false
				ctoc = ctol
			} else {
				mul = ctoc / cfromc
				done = true
			}
		}
		match kind {
			.general {
				for i in 0 .. m {
					for j in 0 .. n {
						a[i * lda + j] *= mul
					}
				}
			}
			.upper_tri {
				for i in 0 .. m {
					for j in i .. n {
						a[i * lda + j] *= mul
					}
				}
			}
			.lower_tri {
				for i in 0 .. m {
					for j in 0 .. math.min(i + 1, n) {
						a[i * lda + j] *= mul
					}
				}
			}
		}
		if done {
			break
		}
	}
}
