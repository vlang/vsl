module main

import vsl.fit

fn main() {
	// Real-world style scenario:
	// A raw sensor reading (x) is biased compared to a trusted reference (y).
	// We fit y = a + b*x and use it as a calibration equation.
	sensor_raw := [
		0.0,
		5.0,
		10.0,
		20.0,
		30.0,
		40.0,
		50.0,
	]
	reference := [
		0.8,
		6.2,
		11.5,
		21.9,
		32.0,
		42.3,
		53.0,
	]

	a, b := fit.linear(sensor_raw, reference)
	println('== linear calibration ==')
	println('model: y = a + b*x')
	println('a (offset) = ${a:.6f}')
	println('b (gain)   = ${b:.6f}')

	// Apply calibration to unseen sensor values.
	new_measurements := [7.5, 15.0, 35.0, 47.0]
	println('')
	println('calibrated predictions:')
	for x in new_measurements {
		y_hat := a + b * x
		println('  raw=${x:6.2f} -> calibrated=${y_hat:8.4f}')
	}

	// Inspect residuals on training data to verify behavior.
	println('')
	println('training residuals (y - y_hat):')
	mut mae := 0.0
	for i, x in sensor_raw {
		y_hat := a + b * x
		r := reference[i] - y_hat
		mae += abs(r)
		println('  x=${x:6.2f} y=${reference[i]:8.4f} y_hat=${y_hat:8.4f} residual=${r:8.4f}')
	}
	mae /= f64(sensor_raw.len)
	println('mean absolute residual = ${mae:.6f}')
}

fn abs(x f64) f64 {
	return if x < 0.0 { -x } else { x }
}
