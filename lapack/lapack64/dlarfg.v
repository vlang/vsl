module lapack64

import math
import vsl.blas

pub fn dlarfg(n int, alpha f64, mut x []f64, incx int) (f64, f64) {
	if n < 0 {
		panic(n_lt0)
	}
	if incx <= 0 {
		panic(bad_inc_x)
	}

	if n <= 1 {
		return alpha, 0
	}

	if x.len < 1 + (n - 2) * math.abs(incx) {
		panic(short_x)
	}

	mut xnorm := blas.dnrm2(n - 1, x, incx)
	if xnorm == 0 {
		return alpha, 0
	}
	mut beta := -math.copysign(dlapy2(alpha, xnorm), alpha)
	safmin := dlamch_s / dlamch_e
	mut knt := 0
	mut alpha_ := alpha
	if math.abs(beta) < safmin {
		// xnorm and beta may be inaccurate, scale x and recompute.
		rsafmn := 1 / safmin
		for {
			knt++
			blas.dscal(n - 1, rsafmn, mut x, incx)
			beta *= rsafmn
			alpha_ *= rsafmn
			if math.abs(beta) >= safmin {
				break
			}
		}
		xnorm = blas.dnrm2(n - 1, x, incx)
		beta = -math.copysign(dlapy2(alpha_, xnorm), alpha_)
	}
	mut tau := (beta - alpha_) / beta
	blas.dscal(n - 1, 1 / (alpha_ - beta), mut x, incx)
	for _ in 0 .. knt {
		beta *= safmin
	}
	return beta, tau
}
