module plot

struct SamplePlottable {
	title string
}

fn (s &SamplePlottable) to_plot() &Plot {
	mut plt := Plot.new()
	plt.layout(title: s.title)
	return plt
}

fn test_render_dispatches_to_to_plot() {
	value := &SamplePlottable{'Plottable title'}
	plt := render(value)
	assert plt.layout.title == 'Plottable title'
	assert plt.traces.len == 0
}

fn test_render_preserves_traces() {
	mut value := &SamplePlottable{'With trace'}
	mut plt := render(value)
	plt.scatter(
		name: 'points'
		x:    [f64(1.0), 2.0]
		y:    [f64(3.0), 4.0]
	)
	assert plt.traces.len == 1
}
