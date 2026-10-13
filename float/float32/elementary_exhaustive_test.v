module float32

import math
import vsl.float.float64 as f64m

// Exhaustive verification over complete f32 binades: every single f32
// input in the range is checked against the double-double reference
// (float64 *_dd functions, validated against 200-bit references),
// rounded to f32 by exact midpoint comparison. Unlike the sampled and
// directed evidence elsewhere, this is exhaustive for these ranges:
// there is no input in [0.5, 2) for log or in [0.5, 1) for exp whose
// f32 result could round the wrong way. Extending this style of proof
// to all ranges and functions is the remaining work of vlang/vsl#65.

// ref_f32 rounds a double-double pair to the nearest f32.
fn ref_f32(hi f64, lo f64) f32 {
	y := f32(hi)
	r := (hi - f64(y)) + lo
	if r == 0.0 {
		return y
	}
	bits := math.f32_bits(y)
	mut up_bits := bits
	mut dn_bits := bits
	if y >= 0.0 {
		up_bits = bits + 1
		dn_bits = bits - 1
	} else {
		up_bits = bits - 1
		dn_bits = bits + 1
	}
	if r > 0.0 {
		up := math.f32_from_bits(up_bits)
		if r > (f64(up) - f64(y)) / 2.0 {
			return up
		}
	} else {
		dn := math.f32_from_bits(dn_bits)
		if -r > (f64(y) - f64(dn)) / 2.0 {
			return dn
		}
	}
	return y
}

// Small exhaustive range that always runs: every f32 in [1, 1 + 2^-11).
fn test_log_exhaustive_narrow_range() {
	mut mismatches := 0
	for b := u32(0x3F800000); b < 0x3F802000; b++ {
		x := math.f32_from_bits(b)
		rh, rl := f64m.log_dd(f64(x))
		if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
			mismatches++
		}
	}
	assert mismatches == 0, 'log exhaustive [1, 1+2^-11): ${mismatches} mismatches over 8192 inputs'
}

// Full-binade exhaustive proofs, gated behind -d exhaustive because
// each range takes ~35 s: run with
//   v -d exhaustive test float/float32/elementary_exhaustive_test.v
fn test_log_exhaustive_over_binade_1_2() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F800000); b < 0x40000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [1, 2): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_quarter_half() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3E800000); b < 0x3F000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [0.25, 0.5): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_negative_binades() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xBE000000); b < 0xBF000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [-0.5, -0.125): ${mismatches} mismatches over 16777216 inputs'
	}
}
