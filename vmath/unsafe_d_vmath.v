module vmath

import math

// f32_bits returns the IEEE 754 binary representation of f,
// with the sign bit of f and the result in the same bit position.
// f32_bits(f32_from_bits(x)) == x.
pub fn f32_bits(f f32) u32 {
	return math.f32_bits(f)
}

// f32_from_bits returns the floating-point number corresponding
// to the IEEE 754 binary representation b, with the sign bit of b
// and the result in the same bit position.
// f32_from_bits(f32_bits(x)) == x.
pub fn f32_from_bits(b u32) f32 {
	return math.f32_from_bits(b)
}

// f64_bits returns the IEEE 754 binary representation of f,
// with the sign bit of f and the result in the same bit position,
// and f64_bits(f64_from_bits(x)) == x.
pub fn f64_bits(f f64) u64 {
	return math.f64_bits(f)
}

// f64_from_bits returns the floating-point number corresponding
// to the IEEE 754 binary representation b, with the sign bit of b
// and the result in the same bit position.
// f64_from_bits(f64_bits(x)) == x.
pub fn f64_from_bits(b u64) f64 {
	return math.f64_from_bits(b)
}
