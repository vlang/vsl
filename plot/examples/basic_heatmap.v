module main
import vsl.plot


z := [[1.0, 0, 30, 50, 1], [20.0, 1, 60, 80, 30], [30.0, 60, 1, -10, 20]]
x := ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
y := ['Morning', 'Afternoon', 'Evening']

mut plt := plot.new_plot()

plt.add_trace(
	trace_type: .heatmap
	x_str: x
	y_str: y
	z: z
)
plt.set_layout(
	title: 'Heatmap Basic Implementation'
	width: 750
	height: 750
)

plt.show()?
