module float32

import math
import vsl.float.float64 as f64m

// Exhaustive verification over complete f32 binades: every single f32
// input in the range is checked against the double-double reference
// (float64 *_dd functions, validated against 200-bit references),
// rounded to f32 by exact midpoint comparison. Unlike the sampled and
// directed evidence elsewhere, this is exhaustive for these ranges:
// log [0.5, 2), exp [0.25, 1) and [-0.5, -0.125), and one complete
// binade for each of the other fourteen functions. There is no input
// in those ranges whose f32 result could round the wrong way.
// Extending this style of proof to every range is the remaining work
// of vlang/vsl#65; a full f64 exhaustive pass is impossible (2^52
// inputs per binade), so f64 relies on the double-double evaluation
// validated against 200-bit references.

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

// The remaining fourteen functions, one complete binade each in a
// well-conditioned range (no poles, no domain boundaries except the
// smooth asin/acos endpoint neighbourhood at 1, and no argument
// reduction beyond the binade itself).

fn test_sin_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tan_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tan_dd(f64(x))
			if math.f32_bits(tan(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tan exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp2_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp2_dd(f64(x))
			if math.f32_bits(exp2(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp2 exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log2_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log2_dd(f64(x))
			if math.f32_bits(log2(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log2 exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log10_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log10_dd(f64(x))
			if math.f32_bits(log10(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log10 exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_expm1_exhaustive_over_binade_quarter_half() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3E800000); b < 0x3F000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.expm1_dd(f64(x))
			if math.f32_bits(expm1(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'expm1 exhaustive [0.25, 0.5): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log1p_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log1p_dd(f64(x))
			if math.f32_bits(log1p(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log1p exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_asin_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.asin_dd(f64(x))
			if math.f32_bits(asin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'asin exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_acos_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.acos_dd(f64(x))
			if math.f32_bits(acos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'acos exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_atan_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.atan_dd(f64(x))
			if math.f32_bits(atan(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'atan exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sinh_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sinh_dd(f64(x))
			if math.f32_bits(sinh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sinh exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cosh_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cosh_dd(f64(x))
			if math.f32_bits(cosh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cosh exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tanh_exhaustive_over_binade_half_1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F000000); b < 0x3F800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tanh_dd(f64(x))
			if math.f32_bits(tanh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tanh exhaustive [0.5, 1): ${mismatches} mismatches over 8388608 inputs'
	}
}
