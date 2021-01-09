
module vmath

// max returns the maximum value of the two provided.
pub fn max(a f64, b f64) f64 {
	if a > b {
		return a
	}
	return b
}

// min returns the minimum value of the two provided.
pub fn min(a f64, b f64) f64 {
	if a < b {
		return a
	}
	return b
}

pub fn minmax(a f64, b f64) (f64, f64) {
	if a < b {
		return a, b
	}
	return b, a
}
