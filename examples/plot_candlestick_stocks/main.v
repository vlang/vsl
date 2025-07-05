module main

import vsl.plot
import vsl.util
import math

fn main() {
	// Generate sample OHLC (Open, High, Low, Close) data for 20 trading days
	days := 20
	dates := util.arange(days)

	mut open_prices := []f64{}
	mut high_prices := []f64{}
	mut low_prices := []f64{}
	mut close_prices := []f64{}

	mut current_price := 100.0

	for i in 0 .. days {
		// Open price (previous close + gap)
		gap := 2.0 * math.sin(f64(i) * 0.3)
		open_price := current_price + gap

		// Generate intraday volatility
		volatility := 5.0 + 2.0 * math.sin(f64(i) * 0.1)

		// High and low for the day
		mut high_price := open_price + volatility * math.abs(math.sin(f64(i) * 0.7))
		mut low_price := open_price - volatility * math.abs(math.cos(f64(i) * 0.5))

		// Close price (trend + random walk)
		trend := 0.5 * math.sin(f64(i) * 0.2)
		close_price := open_price + trend + 1.5 * math.sin(f64(i) * 0.9)

		// Ensure high >= max(open, close) and low <= min(open, close)
		if high_price < math.max(open_price, close_price) {
			high_price = math.max(open_price, close_price) + 0.5
		}
		if low_price > math.min(open_price, close_price) {
			low_price = math.min(open_price, close_price) - 0.5
		}

		open_prices << open_price
		high_prices << high_price
		low_prices << low_price
		close_prices << close_price

		current_price = close_price
	}

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add candlestick trace
	plt.candlestick(
		x: dates
		open: open_prices
		high: high_prices
		low: low_prices
		close: close_prices
		name: 'Stock Price'
		increasing: plot.Increasing{
			line: plot.Line{
				color: '#2E8B57'  // Green for bullish candles
				width: 1.0
			}
			marker: plot.Marker{
				color: ['#2E8B57']
			}
		}
		decreasing: plot.Decreasing{
			line: plot.Line{
				color: '#DC143C'  // Red for bearish candles
				width: 1.0
			}
			marker: plot.Marker{
				color: ['#DC143C']
			}
		}
	)

	// Configure the plot layout
	plt.layout(
		title: 'Stock Price Candlestick Chart - 20 Trading Days'
		xaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Trading Day'}
			showgrid: true
			rangeslider: plot.RangeSlider{
				visible: false  // Disable range slider for simplicity
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Price ($)'}
			showgrid: true
		}
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
		showlegend: false
	)

	// Display the plot
	plt.show()!
}
