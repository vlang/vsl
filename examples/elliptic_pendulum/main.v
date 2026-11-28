module main

import math
import vsl.fun

fn main() {
	length := 1.0
	gravity := 9.80665
	omega := math.sqrt(gravity / length)
	theta0 := math.pi / 3.0
	k := math.sin(theta0 / 2.0)
	m := k * k

	complete := fun.ellipk(m) or {
		eprintln('ellipk failed: ${err}')
		return
	}
	period := 4.0 * complete / omega
	small_angle_period := 2.0 * math.pi / omega
	println('Initial angle: ${theta0 * 180.0 / math.pi:.1f} degrees')
	println('K(m) = ${complete:.12f}')
	println('Period: ${period:.12f} s (small-angle approximation ${small_angle_period:.12f} s)')

	// The exact solution uses sn with a quarter-period phase shift.
	for t in [f64(0.0), 0.25, 0.5, 1.0] {
		jacobi := fun.ellipj(complete + omega * t, m) or {
			eprintln('ellipj failed: ${err}')
			return
		}
		theta := 2.0 * math.asin(k * jacobi.sn)
		println('t=${t:.2f} s, theta=${theta * 180.0 / math.pi:.6f} degrees')
	}
}
