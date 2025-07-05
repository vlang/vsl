module main

import vsl.plot
import vsl.util
import math

fn main() {
	// Generate time series data (simulating daily stock prices over 30 days)
	days := 30
	x := util.arange(days)

	// Generate realistic stock price data with trend and volatility
	mut prices := []f64{}
	mut base_price := 100.0

	for i in 0 .. days {
		// Add daily trend (slight upward bias)
		daily_trend := 0.5 * math.sin(f64(i) * 0.1) + 0.2

		// Add random volatility (simplified random walk)
		volatility := 2.0 * math.sin(f64(i) * 0.3) * math.cos(f64(i) * 0.7)

		base_price += daily_trend + volatility
		prices << base_price
	}

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add a line trace for the time series
	plt.line(
		x: x
		y: prices
		name: 'Stock Price'
		line: plot.Line{
			color: '#1f77b4'  // Professional blue color
			width: 2.5
		}
	)

	// Configure the plot layout for time series
	plt.layout(
		title: 'Stock Price Time Series - 30 Day Trend'
		xaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Days'}
			showgrid: true
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Price ($)'}
			showgrid: true
		}
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
	)

	// Display the plot
	plt.show()!
}
