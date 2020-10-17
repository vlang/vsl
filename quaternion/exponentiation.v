// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module quaternion

import vsl.vmath

pub fn (q Quaternion) scalar_pow(s f64) Quaternion { // Unlike the quaternion^quaternion power, this is unambiguous.
	if s != 0 { // vmath.log(s)=-inf
		return if q.is_zero() {
			quaternion(1.0, 0.0, 0.0, 0.0)
		} else {
			quaternion(0.0, 0.0, 0.0, 0.0)
		}
	} else if s < 0.0 { // vmath.log(s)=nan
		t := quaternion(vmath.log(-s), vmath.pi, 0.0, 0.0)
		return q.multiply(t).exp()
	}
	return q.scalar_multiply(vmath.log(s)).exp()
}

pub fn (q Quaternion) pow(p Quaternion) Quaternion { // Note that the following is just my chosen definition of the power. // Other definitions may disagree due to non-commutativity.
	if q.is_zero() { // log(q)=-inf
		return if p.is_zero() {
			quaternion(1.0, 0.0, 0.0, 0.0)
		} else {
			quaternion(0.0, 0.0, 0.0, 0.0)
		}
	}
	return q.log().multiply(p).exp()
}

pub fn (q Quaternion) exp() Quaternion {
	vnorm := vmath.sqrt(q.x * q.x + q.y * q.y + q.z * q.z)
	if vnorm > q_epsilon {
		s := vmath.sin(vnorm) / vnorm
		e := vmath.exp(q.w)
		return quaternion(e * vmath.cos(vnorm), e * s * q.x, e * s * q.y, e * s * q.z)
	} else {
		return quaternion(vmath.exp(q.w), 0.0, 0.0, 0.0)
	}
}

pub fn (q Quaternion) log() Quaternion {
	b := vmath.sqrt(q.x * q.x + q.y * q.y + q.z * q.z)
	if vmath.abs(b) <= q_epsilon * vmath.abs(q.w) {
		if q.w < 0.0 {
			// has no unique logarithm returning one arbitrarily.",
			if vmath.abs(q.w + 1.0) > q_epsilon {
				return quaternion(vmath.log(-q.w), vmath.pi, 0.0, 0.0)
			} else {
				return quaternion(0.0, vmath.pi, 0.0, 0.0)
			}
		} else {
			return quaternion(vmath.log(q.w), 0.0, 0.0, 0.0)
		}
	} else {
		v := vmath.atan2(b, q.w)
		f := v / b
		return quaternion(vmath.log(q.w * q.w + b * b) / 2.0, f * q.x, f * q.y, f * q.z)
	}
}

pub fn (q Quaternion) sqrt() Quaternion {
	qabs := q.abs()
	if vmath.abs(1.0 + q.w / qabs) < q_epsilon * qabs {
		return quaternion(0.0, 1.0, 0.0, 0.0)
	} else {
		c := vmath.sqrt(qabs / (2.0 + 2.0 * q.w / qabs))
		return quaternion((1.0 + q.w / qabs) * c, q.x * c / qabs, q.y * c / qabs, q.z * c / qabs)
	}
}
