module main

import vsl.plot

fn main() {
	// Representative financial use case:
	// visualize intraday regime shifts with OHLC bars.
	dates := [
		'2026-03-01',
		'2026-03-02',
		'2026-03-03',
		'2026-03-04',
		'2026-03-05',
		'2026-03-06',
	]
	open := [100.0, 102.0, 101.0, 99.0, 98.0, 101.0]
	high := [104.0, 103.0, 102.0, 100.0, 102.0, 106.0]
	low := [99.0, 100.0, 97.0, 96.0, 97.0, 100.0]
	close := [103.0, 101.0, 98.0, 97.0, 101.0, 105.0]

	mut plt := plot.Plot.new()
	plt.ohlc(
		x:     dates
		open:  open
		high:  high
		low:   low
		close: close
		name:  'Asset OHLC'
	)

	plt.layout(
		title:         'OHLC Market Regime Snapshot'
		xaxis:         plot.Axis{
			title: plot.AxisTitle{
				text: 'Date'
			}
		}
		yaxis:         plot.Axis{
			title: plot.AxisTitle{
				text: 'Price'
			}
		}
		plot_bgcolor:  '#f8f9fa'
		paper_bgcolor: '#ffffff'
	)

	println('OHLC market regime plot created successfully!')
	plt.show()!
}
