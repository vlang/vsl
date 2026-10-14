module main

import vsl.stats

fn main() {
	measurements := [9.8, 10.1, 10.0, 9.9, 10.2]
	summary := stats.summarize(measurements, 1) or { panic(err) }
	println('count: ${summary.count}')
	println('mean: ${summary.mean}')
	println('sample variance: ${summary.variance}')
	println('sample standard deviation: ${summary.stddev}')
	println('range: ${summary.min}..${summary.max}')
	median := stats.quantile(measurements, 0.5) or { panic(err) }
	println('median: ${median}')
}
