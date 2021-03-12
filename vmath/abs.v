module vmath

// Returns the absolute value.
pub fn abs(x f64) f64 {
	return if x > 0.0 {
		x
	} else {
		-x
	}
}
