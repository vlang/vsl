module main

import vsl.graph
import vsl.ml
import vsl.plot

fn describe(name string, value plot.Plottable) {
	plt := plot.render(value)
	println('${name}: ${plt.traces.len} traces, title="${plt.layout.title}"')
}

fn main() {
	g := graph.Graph.new(
		[[0, 1], [1, 2]],
		[f64(1.0), 1.0],
		[[f64(0.0), 0.0], [1.0, 0.0], [1.0, 1.0]],
		[],
	)
	describe('graph', g)

	mut data := ml.Data.from_raw_x([
		[0.1, 0.7],
		[0.3, 0.8],
		[0.7, 0.2],
		[0.9, 0.3],
	])!
	mut kmeans := ml.Kmeans.new(mut data, 2, 'clusters')
	kmeans.set_centroids_checked([[0.2, 0.75], [0.8, 0.25]])!
	kmeans.find_closest_centroids()
	describe('kmeans', kmeans)

	// Rendering stays opt-in: no browser is opened and no file is written.
	mut plt := plot.render(g)
	traces := plt.traces_json()
	println('graph trace JSON length: ${traces.len}')
}
