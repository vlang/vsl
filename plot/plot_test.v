module plot

fn test_bar() {
	mut plt := Plot.new()

	plt.bar(
		x: ['China', 'India', 'USA', 'Indonesia', 'Pakistan']
		y: [1411778724.0, 1379217184, 331989449, 271350000, 225200000]
	)
	plt.layout(
		title: 'Countries by population'
	)
	plt.show()!
}

fn test_scatter_hovertemplate_in_json() {
	mut plt := Plot.new()
	mut tr := ScatterTrace{
		x:             [1.0]
		y:             [2.0]
		hovertemplate: 'x=%{x}, y=%{y}<extra></extra>'
	}
	plt.add_trace(tr)
	traces, _ := plt.to_json()
	assert traces.contains('"hovertemplate":"x=%{x}, y=%{y}<extra></extra>"')
}
