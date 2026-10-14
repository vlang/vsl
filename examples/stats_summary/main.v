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
	median_unbiased := stats.quantile_with_method(measurements, 0.5, .median_unbiased) or {
		panic(err)
	}
	println('median (unbiased estimator): ${median_unbiased}')
	weighted_median := stats.quantile_weighted(measurements, [1.0, 1.0, 4.0, 1.0, 1.0], 0.5) or {
		panic(err)
	}
	println('weighted median: ${weighted_median}')
}
