module plot

fn test_bar() {
	mut plt := new_plot()

	plt.add_trace(
		trace_type: .bar
		x_str: ['China', 'India', 'USA', 'Indonesia', 'Pakistan']
		y: [1411778724.0, 1379217184, 331989449, 271350000, 225200000]
	)
	plt.set_layout(
		title: 'Countries by population'
	)
	plt.show()?
}
