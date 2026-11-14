// Airy functions as solutions of the turning-point equation y'' = x y.
//
// x = 0 is the turning point: the solutions oscillate for x < 0 and decay (Ai) or grow
// (Bi) for x > 0. This example integrates the equation with classical RK4 from x = 3 back
// toward the turning point, starting from the exact values of Ai and Bi there, and compares
// the integrated solutions with the series and asymptotic evaluation in vsl.fun.
module main

import math
import vsl.fun

// deriv returns the state (y, y') derivative for the Airy equation y'' = x y.
fn deriv(x f64, state [2]f64) [2]f64 {
	return [state[1], x * state[0]]!
}

// rk4_step advances the Airy state from x by step h (h may be negative).
fn rk4_step(x f64, state [2]f64, h f64) [2]f64 {
	k1 := deriv(x, state)
	k2 := deriv(x + h / 2, [state[0] + h / 2 * k1[0], state[1] + h / 2 * k1[1]]!)
	k3 := deriv(x + h / 2, [state[0] + h / 2 * k2[0], state[1] + h / 2 * k2[1]]!)
	k4 := deriv(x + h, [state[0] + h * k3[0], state[1] + h * k3[1]]!)
	return [state[0] + h / 6 * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]),
		state[1] + h / 6 * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1])]!
}

fn main() {
	start := 3.0
	steps := 20000
	h := -(start + 4.0) / steps // integrate backwards from x = 3 to x = -4

	// Start from the exact values of Ai and Bi at x = 3, then integrate backwards.
	ai_start := fun.airy(start)
	bi_start := fun.airy(start)
	mut ai_state := [ai_start.ai, ai_start.aip]!
	mut bi_state := [bi_start.bi, bi_start.bip]!
	mut x := start
	mut max_ai_error := 0.0
	mut max_bi_error := 0.0
	for _ in 0 .. steps {
		ai_state = rk4_step(x, ai_state, h)
		bi_state = rk4_step(x, bi_state, h)
		x += h
		exact := fun.airy(x)
		max_ai_error = math.max(max_ai_error, math.abs(ai_state[0] - exact.ai))
		max_bi_error = math.max(max_bi_error, math.abs(bi_state[0] - exact.bi))
	}

	println("Airy equation y'' = x y, integrated with RK4 (${steps} steps) from x = ${start} to x = ${x:.2f}")
	println('max |RK4 Ai - fun.airy Ai| over the path: ${max_ai_error:.3e}')
	println('max |RK4 Bi - fun.airy Bi| over the path: ${max_bi_error:.3e}')
	println('')
	println('Turning-point behaviour at selected x (x = 0 is the turning point):')
	for point in [-6.0, -2.0, 0.0, 2.0, 6.0] {
		v := fun.airy(point)
		println('  x = ${point:6.2f}   Ai = ${v.ai:+.6e}   Bi = ${v.bi:+.6e}')
	}
	println('')
	println("Wronskian Ai*Bi' - Ai'*Bi at x = 0 is 1/pi = ${1 / math.pi:.12f}; computed: ${fun.airy(0).ai * fun.airy(0).bip - fun.airy(0).aip * fun.airy(0).bi:.12f}")
}
