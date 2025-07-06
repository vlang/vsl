module main

import vsl.plot

fn main() {
	// Create minimal violin plot
	mut plt := plot.Plot.new()

	// Simple data
	data := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

	plt.violin(
		y:    data
		name: 'Test Data'
		x0:   'Test'
	)

	// Debug the JSON generation
	plt.debug_json()

	println('Simple violin test completed')
}
