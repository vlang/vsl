module float32

import math
import vsl.float.float64 as f64m

// Exhaustive verification over complete f32 binades: every single f32
// input in the range is checked against the double-double reference
// (float64 *_dd functions, validated against 200-bit references),
// rounded to f32 by exact midpoint comparison. Since the f32
// implementations also evaluate via *_dd, these tests exhaustively
// verify the f32 rounding step and the robustness of the *_dd
// evaluation over every input in range (no NaNs, no crashes, no
// midpoint flips); the independent correctness anchors for the *_dd
// values themselves are the 200-bit mpmath tables and directed hard
// cases in elementary_test.v, elementary_hard_cases_test.v and the
// float64 dd suites. This suite is also what caught the f64 double
// rounding in log (input 0x41178feb) before the *_dd rewrite.
// Unlike the sampled and
// directed evidence elsewhere, this is exhaustive for these ranges:
// log [0.25, 4) plus [2^-10, 2^-9) and [1024, 2048), exp [0.25, 2),
// [-1, -0.125), [8, 16) and [-16, -8), sin/cos [0.5, 2) and [64, 128),
// sin (-1, -0.5], tan [1, 2) across the pi/2 pole, and at least two
// complete binades in different regimes for every other function,
// plus edge regimes: near-zero cancellation for expm1/log1p/sinh/tanh,
// underflow-to-subnormal outputs for exp/exp2, every positive
// subnormal input for log, and trig reduction at [1024, 2048).
// Several ranges are contiguous with no gaps: log [0.25, 256),
// exp [0.25, 64) and (-64, -0.125], and sin/cos [0.5, 2048).
// There is no input
// in those ranges whose f32 result could round the wrong way.
// Extending this style of proof to every range is the remaining work
// of vlang/vsl#65; a full f64 exhaustive pass is impossible (2^52
// inputs per binade), so f64 relies on the double-double evaluation
// validated against 200-bit references.
//
// Run this in dev mode: `v -prod test` compiles assert statements
// out, which would make these checks vacuous (verified empirically
// with a deliberately failing assert, which passes under -prod).

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
		half := (f64(up) - f64(y)) / 2.0
		if r > half || (r == half && bits % 2 == 1) {
			return up
		}
	} else {
		dn := math.f32_from_bits(dn_bits)
		half := (f64(y) - f64(dn)) / 2.0
		if -r > half || (-r == half && bits % 2 == 1) {
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

// Additional ranges that exercise different argument-reduction paths:
// exp with k != 0 scaling in both signs, log with nonzero binary
// exponents in both directions, and trig past pi/2.

fn test_exp_exhaustive_over_binade_1_2() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F800000); b < 0x40000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [1, 2): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_minus1_minus_half() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xBF000000); b < 0xBF800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-1, -0.5]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_2_4() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40000000); b < 0x40800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [2, 4): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_quarter_half() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3E800000); b < 0x3F000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [0.25, 0.5): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_1_2() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F800000); b < 0x40000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [1, 2): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_1_2() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F800000); b < 0x40000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [1, 2): ${mismatches} mismatches over 8388608 inputs'
	}
}

// Extreme regimes: large and small exponents for exp/log, large
// arguments for trig reduction, negative trig, and tan across its
// pi/2 pole (no f32 input lands close enough to the pole to overflow).

fn test_exp_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_minus16_minus8() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xC1000000); b < 0xC1800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-16, -8]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_1024_2048() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x44800000); b < 0x45000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [1024, 2048): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_tiny() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3A800000); b < 0x3B000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [2^-10, 2^-9): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_64_128() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x42800000); b < 0x43000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [64, 128): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_64_128() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x42800000); b < 0x43000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [64, 128): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_negative_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xBF000000); b < 0xBF800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive (-1, -0.5]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tan_exhaustive_over_binade_1_2() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F800000); b < 0x40000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tan_dd(f64(x))
			if math.f32_bits(tan(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tan exhaustive [1, 2): ${mismatches} mismatches over 8388608 inputs'
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

// A second binade, in a different regime, for each function that so
// far had only one: large exponents for exp2/log2/log10/sinh/cosh,
// negative-argument paths for expm1/log1p/asin, the low acos range,
// the reciprocal atan path, and tanh approaching saturation.

fn test_exp2_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp2_dd(f64(x))
			if math.f32_bits(exp2(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp2 exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log2_exhaustive_over_binade_1024_2048() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x44800000); b < 0x45000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log2_dd(f64(x))
			if math.f32_bits(log2(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log2 exhaustive [1024, 2048): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log10_exhaustive_over_binade_1024_2048() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x44800000); b < 0x45000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log10_dd(f64(x))
			if math.f32_bits(log10(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log10 exhaustive [1024, 2048): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_expm1_exhaustive_over_negative_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xBF000000); b < 0xBF800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.expm1_dd(f64(x))
			if math.f32_bits(expm1(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'expm1 exhaustive (-1, -0.5]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log1p_exhaustive_over_negative_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xBE800000); b < 0xBF000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log1p_dd(f64(x))
			if math.f32_bits(log1p(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log1p exhaustive (-0.5, -0.25]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_asin_exhaustive_over_negative_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xBF000000); b < 0xBF800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.asin_dd(f64(x))
			if math.f32_bits(asin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'asin exhaustive (-1, -0.5]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_acos_exhaustive_over_binade_quarter_half() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3E800000); b < 0x3F000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.acos_dd(f64(x))
			if math.f32_bits(acos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'acos exhaustive [0.25, 0.5): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_atan_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.atan_dd(f64(x))
			if math.f32_bits(atan(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'atan exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sinh_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sinh_dd(f64(x))
			if math.f32_bits(sinh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sinh exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cosh_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cosh_dd(f64(x))
			if math.f32_bits(cosh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cosh exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tanh_exhaustive_over_binade_1_2() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3F800000); b < 0x40000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tanh_dd(f64(x))
			if math.f32_bits(tanh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tanh exhaustive [1, 2): ${mismatches} mismatches over 8388608 inputs'
	}
}

// Edge regimes: near-zero cancellation, underflow to subnormal or
// zero outputs, every positive subnormal input, and large-argument
// trig reduction.

fn test_expm1_exhaustive_over_tiny_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3A800000); b < 0x3B000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.expm1_dd(f64(x))
			if math.f32_bits(expm1(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'expm1 exhaustive [2^-10, 2^-9): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log1p_exhaustive_over_tiny_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3A800000); b < 0x3B000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log1p_dd(f64(x))
			if math.f32_bits(log1p(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log1p exhaustive [2^-10, 2^-9): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sinh_exhaustive_over_tiny_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3A800000); b < 0x3B000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sinh_dd(f64(x))
			if math.f32_bits(sinh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sinh exhaustive [2^-10, 2^-9): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tanh_exhaustive_over_tiny_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x3A800000); b < 0x3B000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tanh_dd(f64(x))
			if math.f32_bits(tanh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tanh exhaustive [2^-10, 2^-9): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_underflow_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xC2800000); b < 0xC3000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-128, -64]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp2_exhaustive_underflow_binade() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xC2800000); b < 0xC3000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp2_dd(f64(x))
			if math.f32_bits(exp2(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp2 exhaustive (-128, -64]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_all_subnormal_inputs() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(1); b < 0x00800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive subnormal inputs: ${mismatches} mismatches over 8388607 inputs'
	}
}

fn test_sin_exhaustive_over_binade_1024_2048() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x44800000); b < 0x45000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [1024, 2048): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_1024_2048() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x44800000); b < 0x45000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [1024, 2048): ${mismatches} mismatches over 8388608 inputs'
	}
}

// Contiguous proven intervals: filling the binades between the
// ranges above so that log [0.25, 16), exp [0.25, 16) and
// (-16, -0.125], and sin/cos [0.5, 128) hold for every input, with
// no gaps.

fn test_log_exhaustive_over_binade_4_8() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40800000); b < 0x41000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [4, 8): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_2_4() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40000000); b < 0x40800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [2, 4): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_4_8() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40800000); b < 0x41000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [4, 8): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_minus2_minus1() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xBF800000); b < 0xC0000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-2, -1]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_minus4_minus2() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xC0000000); b < 0xC0800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-4, -2]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_minus8_minus4() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xC0800000); b < 0xC1000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-8, -4]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_2_4() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40000000); b < 0x40800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [2, 4): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_2_4() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40000000); b < 0x40800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [2, 4): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_4_8() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40800000); b < 0x41000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [4, 8): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_4_8() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40800000); b < 0x41000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [4, 8): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_16_32() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41800000); b < 0x42000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [16, 32): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_16_32() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41800000); b < 0x42000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [16, 32): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_32_64() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x42000000); b < 0x42800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [32, 64): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_32_64() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x42000000); b < 0x42800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [32, 64): ${mismatches} mismatches over 8388608 inputs'
	}
}

// A fifth scale for the principal functions: log/exp extend the
// contiguous intervals, trig tests another argument-reduction range,
// tan spans two poles, and tanh approaches saturation.

fn test_log_exhaustive_over_binade_16_32() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41800000); b < 0x42000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [16, 32): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_32_64() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x42000000); b < 0x42800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [32, 64): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_16_32() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41800000); b < 0x42000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [16, 32): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_minus32_minus16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xC1800000); b < 0xC2000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-32, -16]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_128_256() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x43000000); b < 0x43800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [128, 256): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_128_256() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x43000000); b < 0x43800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [128, 256): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tan_exhaustive_over_binade_2_4() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40000000); b < 0x40800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tan_dd(f64(x))
			if math.f32_bits(tan(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tan exhaustive [2, 4): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tanh_exhaustive_over_binade_2_4() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40000000); b < 0x40800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tanh_dd(f64(x))
			if math.f32_bits(tanh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tanh exhaustive [2, 4): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_64_128() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x42800000); b < 0x43000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [64, 128): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_32_64() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x42000000); b < 0x42800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive [32, 64): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_exp_exhaustive_over_binade_minus64_minus32() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0xC2000000); b < 0xC2800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.exp_dd(f64(x))
			if math.f32_bits(exp(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'exp exhaustive (-64, -32]: ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_256_512() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x43800000); b < 0x44000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [256, 512): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_256_512() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x43800000); b < 0x44000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [256, 512): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tan_exhaustive_over_binade_4_8() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40800000); b < 0x41000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tan_dd(f64(x))
			if math.f32_bits(tan(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tan exhaustive [4, 8): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tanh_exhaustive_over_binade_4_8() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x40800000); b < 0x41000000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tanh_dd(f64(x))
			if math.f32_bits(tanh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tanh exhaustive [4, 8): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_log_exhaustive_over_binade_128_256() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x43000000); b < 0x43800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.log_dd(f64(x))
			if math.f32_bits(log(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'log exhaustive [128, 256): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_sin_exhaustive_over_binade_512_1024() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x44000000); b < 0x44800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.sin_dd(f64(x))
			if math.f32_bits(sin(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'sin exhaustive [512, 1024): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_cos_exhaustive_over_binade_512_1024() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x44000000); b < 0x44800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.cos_dd(f64(x))
			if math.f32_bits(cos(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'cos exhaustive [512, 1024): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tan_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tan_dd(f64(x))
			if math.f32_bits(tan(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tan exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}

fn test_tanh_exhaustive_over_binade_8_16() {
	$if exhaustive ? {
		mut mismatches := 0
		for b := u32(0x41000000); b < 0x41800000; b++ {
			x := math.f32_from_bits(b)
			rh, rl := f64m.tanh_dd(f64(x))
			if math.f32_bits(tanh(x)) != math.f32_bits(ref_f32(rh, rl)) {
				mismatches++
			}
		}
		assert mismatches == 0, 'tanh exhaustive [8, 16): ${mismatches} mismatches over 8388608 inputs'
	}
}
