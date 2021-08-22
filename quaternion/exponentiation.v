module quaternion

import math

pub fn (q Quaternion) scalar_pow(s f64) Quaternion { // Unlike the quaternion^quaternion power, this is unambiguous.
	if s != 0 { // math.log(s)=-inf
		return if q.is_zero() {
			quaternion(1.0, 0.0, 0.0, 0.0)
		} else {
			quaternion(0.0, 0.0, 0.0, 0.0)
		}
	} else if s < 0.0 { // math.log(s)=nan
		t := quaternion(math.log(-s), math.pi, 0.0, 0.0)
		return q.multiply(t).exp()
	}
	return q.scalar_multiply(math.log(s)).exp()
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
	vnorm := math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z)
	if vnorm > q_epsilon {
		s := math.sin(vnorm) / vnorm
		e := math.exp(q.w)
		return quaternion(e * math.cos(vnorm), e * s * q.x, e * s * q.y, e * s * q.z)
	} else {
		return quaternion(math.exp(q.w), 0.0, 0.0, 0.0)
	}
}

pub fn (q Quaternion) log() Quaternion {
	b := math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z)
	if math.abs(b) <= q_epsilon * math.abs(q.w) {
		if q.w < 0.0 {
			// has no unique logarithm returning one arbitrarily.",
			if math.abs(q.w + 1.0) > q_epsilon {
				return quaternion(math.log(-q.w), math.pi, 0.0, 0.0)
			} else {
				return quaternion(0.0, math.pi, 0.0, 0.0)
			}
		} else {
			return quaternion(math.log(q.w), 0.0, 0.0, 0.0)
		}
	} else {
		v := math.atan2(b, q.w)
		f := v / b
		return quaternion(math.log(q.w * q.w + b * b) / 2.0, f * q.x, f * q.y, f * q.z)
	}
}

pub fn (q Quaternion) sqrt() Quaternion {
	qabs := q.abs()
	if math.abs(1.0 + q.w / qabs) < q_epsilon * qabs {
		return quaternion(0.0, 1.0, 0.0, 0.0)
	} else {
		c := math.sqrt(qabs / (2.0 + 2.0 * q.w / qabs))
		return quaternion((1.0 + q.w / qabs) * c, q.x * c / qabs, q.y * c / qabs, q.z * c / qabs)
	}
}
