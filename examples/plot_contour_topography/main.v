module main

import vsl.plot
import math

fn main() {
	// Generate a 2D grid for topographical data
	grid_size := 50
	mut x_coords := []f64{}
	mut y_coords := []f64{}
	mut z_matrix := [][]f64{}

	// Create coordinate arrays
	for i in 0 .. grid_size {
		x_coords << f64(i) * 0.2 - 5.0  // Range from -5 to 5
		y_coords << f64(i) * 0.2 - 5.0
	}

	// Generate elevation data (simulating terrain)
	for i in 0 .. grid_size {
		mut row := []f64{}
		for j in 0 .. grid_size {
			x := x_coords[i]
			y := y_coords[j]

			// Create interesting topography with multiple peaks and valleys
			elevation := 3.0 * math.exp(-(x*x + y*y) / 10.0) +  // Central peak
						2.0 * math.exp(-((x-2)*(x-2) + (y+2)*(y+2)) / 5.0) +  // Secondary peak
						1.5 * math.exp(-((x+3)*(x+3) + (y-1)*(y-1)) / 3.0) +  // Third peak
						0.5 * math.sin(x) * math.cos(y)  // Add some texture

			row << elevation
		}
		z_matrix << row
	}

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add a contour trace
	plt.contour(
		x: x_coords
		y: y_coords
		z: z_matrix
		colorscale: 'Viridis'
		contours: plot.Contours{
			start: 0.0
			end: 4.0
			size: 0.2
			showlines: true
			showlabels: true
			coloring: 'lines'
		}
		line: plot.Line{
			width: 1.5
		}
	)

	// Configure the plot layout
	plt.layout(
		title: 'Topographical Contour Map'
		xaxis: plot.Axis{
			title: plot.AxisTitle{text: 'X Coordinate (km)'}
			showgrid: true
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Y Coordinate (km)'}
			showgrid: true
			scaleanchor: 'x'  // Keep aspect ratio
		}
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
	)

	// Display the plot
	plt.show()!
}
