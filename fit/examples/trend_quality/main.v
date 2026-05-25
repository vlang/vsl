module main

import math
import vsl.fit

fn main() {
	// Real-world style scenario:
	// Daily KPI trend with moderate noise. We want both the trend and
	// uncertainty/fit-quality indicators.
	days := [
		1.0,
		2.0,
		3.0,
		4.0,
		5.0,
		6.0,
		7.0,
		8.0,
		9.0,
		10.0,
	]
	kpi := [
		101.2,
		102.1,
		103.8,
		104.2,
		105.7,
		106.6,
		107.1,
		108.8,
		109.4,
		110.2,
	]

	a, b, sigma_a, sigma_b, chi2 := fit.linear_sigma(days, kpi)

	println('== trend with uncertainty ==')
	println('model: kpi(day) = a + b*day')
	println('a         = ${a:.6f}')
	println('b         = ${b:.6f} (units/day)')
	println('sigma_a   = ${sigma_a:.6f}')
	println('sigma_b   = ${sigma_b:.6f}')
	println('chi^2     = ${chi2:.6f}')

	mut rmse_acc := 0.0
	for i, d in days {
		pred := a + b * d
		err := kpi[i] - pred
		rmse_acc += err * err
	}
	rmse := math.sqrt(rmse_acc / f64(days.len))
	println('rmse      = ${rmse:.6f}')

	// A simple forward projection using the fitted trend.
	println('')
	println('projection for next 3 days:')
	for d in [11.0, 12.0, 13.0] {
		println('  day ${d:4.0f} -> ${a + b * d:8.3f}')
	}
}
