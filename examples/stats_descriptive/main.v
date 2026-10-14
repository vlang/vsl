module main

import vsl.dist
import vsl.stats

fn main() {
	samples := [1.2, 1.5, 1.7, 2.1, 2.4, 2.8, 3.0, 3.6]
	summary := stats.summarize(samples, 1)!
	q25 := stats.quantile(samples, 0.25)!
	edges := dist.histogram_bin_edges(samples, .auto)!
	mut histogram := dist.Histogram.new(edges)
	histogram.count(samples, true)!

	println('count = ${summary.count}')
	println('mean = ${summary.mean}, sample stddev = ${summary.stddev}')
	println('min = ${summary.min}, q25 = ${q25}, max = ${summary.max}')
	println('automatic edges = ${edges}')
	println('histogram counts = ${histogram.counts}')
}
