module main

import vsl.plot

fn main() {
	plot.new_plot()
		.add_trace(
			trace_type: .pie,
			labels: ['Nitrogen', 'Oxygen', 'Argon', 'Other'],
			values: [78., 21, 0.9, 0.1],
			pull: [0., 0.1, 0, 0],
			hole: 0.25
		)
		.set_layout(
			title: 'Gases in the atmosphere',
			width: 750,
			height: 750
		)
		.show() or { panic(err) }
}
