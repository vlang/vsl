module fun

import math

// JacobiValues holds the Jacobi elliptic functions sn(u), cn(u), dn(u).
pub struct JacobiValues {
pub:
	sn f64
	cn f64
	dn f64
}

fn elliptic_finite(value f64) bool {
	return !math.is_nan(value) && !math.is_inf(value, 0)
}

fn elliptic_check_m(m f64) ! {
	if !elliptic_finite(m) || m < 0.0 || m >= 1.0 {
		return error('elliptic functions require 0 <= m < 1 (parameter convention m = k^2)')
	}
}

fn elliptic_check_n(n f64, phi f64) ! {
	if !elliptic_finite(n) {
		return error('elliptic Pi requires a finite characteristic n')
	}
	sin_phi := math.sin(phi)
	if n > 0.0 && n * sin_phi * sin_phi >= 1.0 {
		return error('elliptic Pi is singular on the integration path')
	}
}

// elliptic_agm returns K(m) and E(m) from the arithmetic-geometric mean.
fn elliptic_agm(m f64) (f64, f64) {
	mut agm_a := 1.0
	mut agm_b := math.sqrt(1.0 - m)
	mut agm_c := math.sqrt(m)
	mut coefficients := []f64{}
	for {
		coefficients << agm_c
		if math.abs(agm_c) < 1e-16 {
			break
		}
		next_c := 0.5 * (agm_a - agm_b)
		next_a := 0.5 * (agm_a + agm_b)
		next_b := math.sqrt(agm_a * agm_b)
		agm_a = next_a
		agm_b = next_b
		agm_c = next_c
	}
	k := math.pi / (2.0 * agm_a)
	mut correction := 0.0
	mut factor := 0.5
	for value in coefficients {
		correction += factor * value * value
		factor *= 2.0
	}
	return k, k * (1.0 - correction)
}

fn elliptic_simpson(a f64, b f64, fa f64, fm f64, fb f64) f64 {
	return (b - a) / 6.0 * (fa + 4.0 * fm + fb)
}

fn elliptic_adapt(f fn (f64) f64, a f64, b f64, fa f64, fm f64, fb f64, whole f64, tol f64, depth int) !f64 {
	if depth > 40 {
		return error('elliptic integral did not converge')
	}
	mid := 0.5 * (a + b)
	left_mid := 0.5 * (a + mid)
	right_mid := 0.5 * (mid + b)
	flm := f(left_mid)
	frm := f(right_mid)
	if !elliptic_finite(flm) || !elliptic_finite(frm) {
		return error('elliptic integrand produced a non-finite value')
	}
	left := elliptic_simpson(a, mid, fa, flm, fm)
	right := elliptic_simpson(mid, b, fm, frm, fb)
	delta := left + right - whole
	if math.abs(delta) <= 15.0 * tol {
		return left + right + delta / 15.0
	}
	left_result := elliptic_adapt(f, a, mid, fa, flm, fm, left, tol * 0.5, depth + 1) or {
		return err
	}
	right_result := elliptic_adapt(f, mid, b, fm, frm, fb, right, tol * 0.5, depth + 1) or {
		return err
	}
	return left_result + right_result
}

fn elliptic_integrate(f fn (f64) f64, phi f64) !f64 {
	if !elliptic_finite(phi) {
		return error('elliptic amplitude must be finite')
	}
	start := f(0.0)
	end := f(phi)
	if !elliptic_finite(start) || !elliptic_finite(end) {
		return error('elliptic integrand produced a non-finite value')
	}
	if phi == 0.0 {
		return 0.0
	}
	if phi < 0.0 {
		value := elliptic_integrate(f, -phi) or {
			return err
		}
		return -value
	}
	mid := 0.5 * phi
	mid_value := f(mid)
	if !elliptic_finite(mid_value) {
		return error('elliptic integrand produced a non-finite value')
	}
	whole := elliptic_simpson(0.0, phi, start, mid_value, end)
	value := elliptic_adapt(f, 0.0, phi, start, mid_value, end, whole, 1e-14, 0) or {
		return err
	}
	if !elliptic_finite(value) {
		return error('elliptic integral is not finite')
	}
	return value
}

// ellipk returns the complete elliptic integral of the first kind K(m).
pub fn ellipk(m f64) !f64 {
	elliptic_check_m(m)!
	k, _ := elliptic_agm(m)
	return k
}

// ellipe returns the complete elliptic integral of the second kind E(m).
pub fn ellipe(m f64) !f64 {
	if elliptic_finite(m) && m == 1.0 {
		return 1.0
	}
	elliptic_check_m(m)!
	_, e := elliptic_agm(m)
	return e
}

// ellippi returns the complete elliptic integral of the third kind Pi(n, m).
pub fn ellippi(n f64, m f64) !f64 {
	elliptic_check_m(m)!
	elliptic_check_n(n, math.pi / 2.0)!
	return elliptic_integrate(fn [n, m] (t f64) f64 {
		s := math.sin(t)
		return 1.0 / ((1.0 - n * s * s) * math.sqrt(1.0 - m * s * s))
	}, math.pi / 2.0)
}

// ellipf returns the incomplete elliptic integral of the first kind F(phi, m).
pub fn ellipf(phi f64, m f64) !f64 {
	elliptic_check_m(m)!
	return elliptic_integrate(fn [m] (t f64) f64 {
		s := math.sin(t)
		return 1.0 / math.sqrt(1.0 - m * s * s)
	}, phi)
}

// ellipe_inc returns the incomplete elliptic integral of the second kind
// E(phi, m).
pub fn ellipe_inc(phi f64, m f64) !f64 {
	elliptic_check_m(m)!
	return elliptic_integrate(fn [m] (t f64) f64 {
		s := math.sin(t)
		return math.sqrt(1.0 - m * s * s)
	}, phi)
}

// ellippi_inc returns the incomplete elliptic integral of the third kind
// Pi(n, phi, m).
pub fn ellippi_inc(n f64, phi f64, m f64) !f64 {
	elliptic_check_m(m)!
	elliptic_check_n(n, phi)!
	return elliptic_integrate(fn [n, m] (t f64) f64 {
		s := math.sin(t)
		return 1.0 / ((1.0 - n * s * s) * math.sqrt(1.0 - m * s * s))
	}, phi)
}

// ellipj returns the Jacobi elliptic functions sn(u), cn(u), and dn(u) for
// 0 <= m <= 1. It inverts F(phi, m) = |u| mod K and applies the standard
// quarter-period transformations. At m = 1 the hyperbolic limit is returned.
pub fn ellipj(u f64, m f64) !JacobiValues {
	if !elliptic_finite(u) {
		return error('ellipj requires a finite argument u')
	}
	if !elliptic_finite(m) || m < 0.0 || m > 1.0 {
		return error('ellipj requires 0 <= m <= 1')
	}
	if m == 1.0 {
		abs_u := math.abs(u)
		ch := math.cosh(abs_u)
		return JacobiValues{
			sn: if u < 0.0 { -math.tanh(abs_u) } else { math.tanh(abs_u) }
			cn: 1.0 / ch
			dn: 1.0 / ch
		}
	}
	k := ellipk(m) or {
		return err
	}
	four_k := 4.0 * k
	mut reduced := math.abs(u) - math.floor(math.abs(u) / four_k) * four_k
	if reduced < 0.0 {
		reduced += four_k
	}
	mut quarter := int(math.floor(reduced / k))
	if quarter == 4 {
		quarter = 0
	}
	mut remainder := reduced - f64(quarter) * k
	if remainder > k {
		remainder = k
	}

	mut low := 0.0
	mut high := math.pi / 2.0
	for _ in 0 .. 90 {
		mid := 0.5 * (low + high)
		value := ellipf(mid, m) or {
			return err
		}
		if value < remainder {
			low = mid
		} else {
			high = mid
		}
	}
	phi := 0.5 * (low + high)
	sn0 := math.sin(phi)
	cn0 := math.cos(phi)
	dn0 := math.sqrt(1.0 - m * sn0 * sn0)
	complement := math.sqrt(1.0 - m)

	mut sn := 0.0
	mut cn := 0.0
	mut dn := 0.0
	match quarter {
		0 {
			sn = sn0
			cn = cn0
			dn = dn0
		}
		1 {
			sn = cn0 / dn0
			cn = -complement * sn0 / dn0
			dn = complement / dn0
		}
		2 {
			sn = -sn0
			cn = -cn0
			dn = dn0
		}
		3 {
			sn = -cn0 / dn0
			cn = complement * sn0 / dn0
			dn = complement / dn0
		}
		else {
			return error('ellipj quarter-period index is out of range')
		}
	}
	if u < 0.0 {
		sn = -sn
	}
	return JacobiValues{sn, cn, dn}
}
