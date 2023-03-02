module main

import vsl.plot

mut plt := plot.new_plot()

plt.add_trace(
	trace_type: .pie
	labels: ['Nitrogen', 'Oxygen', 'Argon', 'Other']
	values: [78.0, 21, 0.9, 0.1]
	pull: [0.0, 0.1, 0, 0]
	hole: 0.25
)
plt.set_layout(
	title: 'Gases in the atmosphere'
	width: 750
	height: 750
)
plt.show()!
