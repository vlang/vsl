module graph

import vsl.plot

fn test_graph_implements_plottable() {
	g := Graph.new(
		[[0, 1], [1, 2]],
		[f64(1.0), 1.0],
		[[f64(0.0), 0.0], [1.0, 0.0], [1.0, 1.0]],
		[],
	)
	plt := plot.render(g)
	assert plt.layout.title == 'Graph'
	// One vertex marker trace plus one line trace per edge.
	assert plt.traces.len == 3
}

fn test_graph_plot_skips_incomplete_vertices() {
	g := Graph.new([], [], [[f64(0.0)], [1.0, 1.0]], [])
	plt := plot.render(g)
	assert plt.traces.len == 1
}
