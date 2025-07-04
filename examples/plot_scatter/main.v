module main

import vsl.plot
import vsl.util

fn main() {
	// Generate sample data representing a wave pattern
	// This creates a sinusoidal wave with some variation
	y := [
		0.0, // Starting point
		1, // Rising phase
		3, // Peak region
		1, // Falling phase
		0, // Zero crossing
		-1, // Negative phase
		-3, // Negative peak
		-1, // Rising from negative
		0, // Zero crossing again
		1, // Positive phase
		3, // Peak again
		1, // Falling
		0, // Return to start
	]

	// Generate corresponding x-values using VSL's utility function
	// arange creates sequential numbers: [0, 1, 2, ..., len-1]
	x := util.arange(y.len)

	// Create a new plot instance
	// This initializes the plotting backend (uses Plotly.js internally)
	mut plt := plot.Plot.new()

	// Add a scatter trace with both lines and markers
	plt.scatter(
		x:      x               // X-axis data points
		y:      y               // Y-axis data points
		mode:   'lines+markers' // Display both connecting lines and point markers
		marker: plot.Marker{
			size:  []f64{len: x.len, init: 10.0}         // All markers size 10 pixels
			color: []string{len: x.len, init: '#FF0000'} // All markers red color
		}
		line:   plot.Line{
			color: '#FF0000' // Line color matches markers (red)
		}
	)

	// Configure the plot layout and appearance
	plt.layout(
		title: 'Scatter plot example' // Main plot title
	)

	// Render the plot and open in default browser
	// This generates an HTML file with interactive JavaScript plot
	plt.show()!
}
