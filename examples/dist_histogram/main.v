module main

import vsl.dist

fn main() {
	lims := [0.0, 1, 2, 3, 4, 5]

	mut hist := dist.Histogram.new(lims)

	values := [
		0.0,
		0.1,
		0.2,
		0.3,
		0.9,
		1,
		1,
		1,
		1.2,
		1.3,
		1.4,
		1.5,
		1.99,
		2,
		2.5,
		3,
		3.5,
		4.1,
		4.5,
		4.9,
		-3,
		-2,
		-1,
		5,
		6,
		7,
		8,
	]

	hist.count(values, true)!
	labels := hist.gen_labels('%g')!

	hist_text := dist.text_hist(labels, hist.counts, 0)!

	println(hist_text)
	println('density = ${hist.density(values.len)!}')
	println('density area = ${hist.density_area(values.len)!}')

	weights := values.map(1.0 + it / 10.0)
	mut weighted_hist := dist.WeightedHistogram.new(lims)
	total_weight := weighted_hist.count(values, weights, true)!
	println('weighted counts = ${weighted_hist.counts}')
	println('weighted density = ${weighted_hist.density(total_weight)!}')
	println('weighted density area = ${weighted_hist.density_area(total_weight)!}')

	auto_edges := dist.histogram_bin_edges(values, .auto)!
	mut auto_hist := dist.Histogram.new(auto_edges)
	auto_hist.count(values, true)!
	println('automatic edges = ${auto_edges}')
	println('automatic counts = ${auto_hist.counts}')
}
