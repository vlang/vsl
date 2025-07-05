module main

import json
import vsl.plot
import math

fn main() {
	// Generate sample data with different distributions
	// Dataset 1: Normal distribution (heights in cm)
	mut heights := []f64{}
	for i in 0 .. 100 {
		// Simulate normal distribution around 170cm with std dev of 10
		val := 170.0 + 10.0 * math.sin(f64(i) * 0.628) + 5.0 * math.cos(f64(i) * 1.257)
		heights << val
	}

	// Dataset 2: Bimodal distribution (reaction times in ms)
	mut reaction_times := []f64{}
	for i in 0 .. 100 {
		if i < 50 {
			// Fast reactions (expert group)
			val := 200.0 + 20.0 * math.sin(f64(i) * 0.314)
			reaction_times << val
		} else {
			// Slow reactions (novice group)
			val := 280.0 + 25.0 * math.cos(f64(i-50) * 0.314)
			reaction_times << val
		}
	}

	// Dataset 3: Skewed distribution (income data)
	mut incomes := []f64{}
	for i in 0 .. 100 {
		// Right-skewed distribution
		base := 30000.0
		skew_factor := math.exp(f64(i) / 50.0) - 1.0
		val := base + skew_factor * 10000.0
		incomes << val
	}

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Combine all data with labels (similar to box plot approach)
	all_heights := heights.map(f64(it))
	all_reaction_times := reaction_times.map(f64(it))
	all_incomes := incomes.map(f64(it))

	// Create grouped violin plots (each dataset as separate category)

	// Violin plot for Heights
	plt.violin(
		y: all_heights
		x: ['Heights'].repeat(all_heights.len)  // Create x array with category names
		name: 'Heights (cm)'
		side: 'both'
		points: 'outliers'
		box: plot.Box{
			visible: true
			width: 0.3
		}
		meanline: plot.Line{
			visible: true
		}
		line: plot.Line{
			color: '#4ECDC4'
		}
		fillcolor: '#4ECDC4'
		opacity: 0.6
	)

	plt.violin(
		y: all_reaction_times
		x: ['Reaction Times'].repeat(all_reaction_times.len)  // Create x array
		name: 'Reaction Times (ms)'
		side: 'both'
		points: 'outliers'
		box: plot.Box{
			visible: true
			width: 0.3
		}
		meanline: plot.Line{
			visible: true
		}
		line: plot.Line{
			color: '#45B7D1'
		}
		fillcolor: '#45B7D1'
		opacity: 0.6
	)

	plt.violin(
		y: all_incomes
		x: ['Annual Income'].repeat(all_incomes.len)  // Create x array
		name: 'Annual Income ($)'
		side: 'both'
		points: 'outliers'
		box: plot.Box{
			visible: true
			width: 0.3
		}
		meanline: plot.Line{
			visible: true
		}
		line: plot.Line{
			color: '#96CEB4'
		}
		fillcolor: '#96CEB4'
		opacity: 0.6
	)

	// Configure the plot layout
	plt.layout(
		title: 'Distribution Comparison with Violin Plots'
		xaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Variables'}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Values'}
		}
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
		showlegend: true
	)

	// Display the plot
	plt.show()!
}
