module fun

import math

fn test_complete_elliptic_integrals() {
	assert math.abs(ellipk(0.0)! - math.pi / 2.0) < 1e-12
	assert math.abs(ellipe(0.0)! - math.pi / 2.0) < 1e-12
	assert math.abs(ellipk(0.5)! - 1.8540746773013719) < 1e-12
	assert math.abs(ellipe(0.5)! - 1.3506438810476755) < 1e-12
	assert math.abs(ellipk(0.9)! - 2.578092113348173) < 1e-12
	assert math.abs(ellipe(0.9)! - 1.1047747327040734) < 1e-12
	assert math.abs(ellipe(1.0)! - 1.0) < 1e-12
}

fn test_incomplete_elliptic_integrals() {
	assert math.abs(ellipf(1.0, 0.5)! - 1.083216772845175) < 1e-10
	assert math.abs(ellipe_inc(1.0, 0.5)! - 0.927329883624446) < 1e-10
	assert math.abs(ellippi_inc(0.3, 1.0, 0.5)! - 1.192325436934554) < 1e-10
	assert math.abs(ellippi(0.3, 0.5)! - 2.2503768219439864) < 1e-10
}

fn test_incomplete_matches_complete_at_quarter_period() {
	for m in [f64(0.0), 0.3, 0.5, 0.9] {
		assert math.abs(ellipf(math.pi / 2.0, m)! - ellipk(m)!) < 1e-10
		assert math.abs(ellipe_inc(math.pi / 2.0, m)! - ellipe(m)!) < 1e-10
		assert math.abs(ellippi_inc(0.3, math.pi / 2.0, m)! - ellippi(0.3, m)!) < 1e-10
	}
}

fn test_incomplete_integrals_are_odd_in_amplitude() {
	for m in [f64(0.0), 0.4, 0.8] {
		assert math.abs(ellipf(-0.7, m)! + ellipf(0.7, m)!) < 1e-12
		assert math.abs(ellipe_inc(-0.7, m)! + ellipe_inc(0.7, m)!) < 1e-12
		assert math.abs(ellippi_inc(0.3, -0.7, m)! + ellippi_inc(0.3, 0.7, m)!) < 1e-12
	}
}

fn test_jacobi_matches_reference_values() {
	first := ellipj(0.3, 0.5)!
	assert math.abs(first.sn - 0.2934127331684555) < 1e-9
	assert math.abs(first.cn - 0.955985861827787) < 1e-9
	assert math.abs(first.dn - 0.9782405041743611) < 1e-9

	second := ellipj(1.2, 0.5)!
	assert math.abs(second.sn - 0.8877154886192793) < 1e-9
	assert math.abs(second.cn - 0.46039245352789426) < 1e-9
	assert math.abs(second.dn - 0.7784475612606908) < 1e-9

	quarter := ellipj(2.0, 0.5)!
	assert math.abs(quarter.sn - 0.9946623253580202) < 1e-9
	assert math.abs(quarter.cn + 0.10318361552775786) < 1e-9
	assert math.abs(quarter.dn - 0.7108610477840857) < 1e-9
}

fn test_jacobi_identities_and_parity() {
	for u in [f64(-2.0), -0.5, 0.0, 0.3, 1.2, 2.0, 4.0] {
		j := ellipj(u, 0.5)!
		assert math.abs(j.sn * j.sn + j.cn * j.cn - 1.0) < 1e-11
		assert math.abs(j.dn * j.dn + 0.5 * j.sn * j.sn - 1.0) < 1e-11
	}
	positive := ellipj(0.7, 0.4)!
	negative := ellipj(-0.7, 0.4)!
	assert math.abs(negative.sn + positive.sn) < 1e-12
	assert math.abs(negative.cn - positive.cn) < 1e-12
	assert math.abs(negative.dn - positive.dn) < 1e-12
}

fn test_jacobi_derivative_relations() {
	u := 0.8
	m := 0.4
	h := 1e-6
	center := ellipj(u, m)!
	plus := ellipj(u + h, m)!
	minus := ellipj(u - h, m)!
	assert math.abs((plus.sn - minus.sn) / (2.0 * h) - center.cn * center.dn) < 1e-6
	assert math.abs((plus.cn - minus.cn) / (2.0 * h) + center.sn * center.dn) < 1e-6
	assert math.abs((plus.dn - minus.dn) / (2.0 * h) + m * center.sn * center.cn) < 1e-6
}

fn test_jacobi_limit_cases() {
	zero := ellipj(0.6, 0.0)!
	assert math.abs(zero.sn - math.sin(0.6)) < 1e-12
	assert math.abs(zero.cn - math.cos(0.6)) < 1e-12
	assert math.abs(zero.dn - 1.0) < 1e-12

	one := ellipj(0.6, 1.0)!
	assert math.abs(one.sn - math.tanh(0.6)) < 1e-12
	assert math.abs(one.cn - 1.0 / math.cosh(0.6)) < 1e-12
	assert math.abs(one.dn - 1.0 / math.cosh(0.6)) < 1e-12
}

fn test_elliptic_rejects_invalid_parameters() {
	ellipk(1.0) or {
		return
	}
	assert false, 'expected m >= 1 to be rejected'
	ellipf(0.5, -0.1) or {
		return
	}
	assert false, 'expected a negative parameter to be rejected'
	ellippi(1.0, 0.5) or {
		return
	}
	assert false, 'expected a singular characteristic to be rejected'
	ellipj(math.nan(), 0.5) or {
		return
	}
	assert false, 'expected a non-finite argument to be rejected'
	ellipj(0.5, 1.5) or {
		return
	}
	assert false, 'expected an out-of-range parameter to be rejected'
}
