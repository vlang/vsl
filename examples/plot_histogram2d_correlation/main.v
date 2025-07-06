module main

import vsl.plot
import math

// Helper function to clamp values between min and max
fn clamp(value f64, min f64, max f64) f64 {
	if value < min {
		return min
	}
	if value > max {
		return max
	}
	return value
}

fn main() {
	// Generate correlated 2D data for histogram analysis
	// Simulating height vs weight correlation

	mut heights := []f64{}
	mut weights := []f64{}

	// Generate realistic height-weight correlation data
	for i in 0 .. 500 {
		// Base height (cm): normal distribution around 170cm
		base_height := 170.0 + 15.0 * math.sin(f64(i) * 0.0314) + 10.0 * math.cos(f64(i) * 0.0628)
		height := clamp(base_height, 150.0, 200.0)

		// Weight correlated with height + some noise
		// BMI relationship: weight = height^2 * BMI / 10000
		// Average BMI around 23, with variation
		bmi := 23.0 + 4.0 * math.sin(f64(i) * 0.0157) + 2.0 * math.cos(f64(i) * 0.0471)
		weight := (height * height * bmi / 10000.0) + 5.0 * math.sin(f64(i) * 0.0942)

		heights << height
		weights << clamp(weight, 45.0, 120.0)
	}

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add 2D histogram
	plt.histogram2d(
		x:          heights
		y:          weights
		nbinsx:     20
		nbinsy:     20
		colorscale: 'Blues'
		showscale:  true
		histfunc:   'count'
		name:       'Height vs Weight Distribution'
	)

	// Configure the plot layout
	plt.layout(
		title:         '2D Histogram: Height vs Weight Correlation Analysis'
		xaxis:         plot.Axis{
			title:    plot.AxisTitle{
				text: 'Height (cm)'
			}
			showgrid: true
		}
		yaxis:         plot.Axis{
			title:    plot.AxisTitle{
				text: 'Weight (kg)'
			}
			showgrid: true
		}
		plot_bgcolor:  '#f8f9fa'
		paper_bgcolor: '#ffffff'
		width:         700
		height:        600
	)

	// Display the plot
	println('2D Histogram correlation analysis created successfully!')
	plt.show()!
}
