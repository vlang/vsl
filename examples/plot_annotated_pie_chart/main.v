module main

import vsl.plot

fn main() {
	labels := ['Apples', 'Bananas', 'Cherries', 'Grapes']
	values := [25.0, 30, 15, 30]

	mut plt := plot.Plot.new()
	plt.pie(
		labels:   labels
		values:   values
		textinfo: 'percent+label'
	)
	plt.layout(
		title: 'Pie Chart with Annotations'
	)
	plt.show()!
}
