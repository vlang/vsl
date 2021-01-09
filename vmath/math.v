
module vmath

// degrees convert from degrees to radians.
pub fn degrees(radians f64) f64 {
	return radians * (180.0 / pi)
}

// radians convert from radians to degrees.
pub fn radians(degrees f64) f64 {
	return degrees * (pi / 180.0)
}

fn is_odd_int(x f64) bool {
	xi, xf := modf(x)
	return xf == 0 && (i64(xi) & 1) == 1
}

fn is_neg_int(x f64) bool {
	if x < 0 {
		_, xf := modf(x)
		return xf == 0
	}
	return false
}
