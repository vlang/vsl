module main

import vsl.plot

fn main() {
	// Define financial waterfall data (quarterly profit analysis)
	categories := ['Q1 Revenue', 'Q2 Growth', 'Q3 Growth', 'Q4 Growth', 'Total Revenue',
		'Operating Costs', 'Marketing', 'R&D', 'Net Profit']

	values := [100000.0, 25000, 30000, 15000, 0, -45000, -20000, -15000, 0]

	// Define measure types for each bar
	measures := ['absolute', 'relative', 'relative', 'relative', 'total', 'relative', 'relative',
		'relative', 'total']

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add waterfall trace
	plt.waterfall(
		x:           categories
		y:           values
		measure:     measures
		name:        'Financial Analysis'
		orientation: 'v'
		connector:   plot.Connector{
			visible: true
			mode:    'between'
			line:    plot.Line{
				color: '#888888'
				width: 1.0
				dash:  'dot'
			}
		}
		increasing:  plot.Increasing{
			marker: plot.Marker{
				color: ['#2E8B57'] // Green for positive values
			}
		}
		decreasing:  plot.Decreasing{
			marker: plot.Marker{
				color: ['#DC143C'] // Red for negative values
			}
		}
		totals:      plot.Totals{
			marker: plot.Marker{
				color: ['#4682B4'] // Blue for totals
			}
		}
		text:        ['$100K', '+$25K', '+$30K', '+$15K', '$170K', '-$45K', '-$20K', '-$15K', '$90K']
	)

	// Configure the plot layout
	plt.layout(
		title:         'Quarterly Financial Performance - Waterfall Analysis'
		xaxis:         plot.Axis{
			title:     plot.AxisTitle{
				text: 'Categories'
			}
			tickangle: -45
		}
		yaxis:         plot.Axis{
			title:    plot.AxisTitle{
				text: 'Amount ($)'
			}
			showgrid: true
		}
		plot_bgcolor:  '#f8f9fa'
		paper_bgcolor: '#ffffff'
		showlegend:    false
	)

	// Display the plot
	plt.show()!
}
