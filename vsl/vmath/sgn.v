module vmath

// copysign returns a value with the magnitude of x and the sign of y
pub fn copysign(x f64, y f64) f64 {
	return f64_from_bits((f64_bits(x) & ~sign_mask) | (f64_bits(y) & sign_mask))
}

// signbit returns a value with the boolean representation of the sign for x
pub fn signbit(x f64) bool {
	return f64_bits(x) & sign_mask != 0
}
