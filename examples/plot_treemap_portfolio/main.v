module main

import vsl.plot

fn main() {
	// Define investment portfolio data
	labels := ['Portfolio', 'Stocks', 'Bonds', 'Real Estate', 'Tech Stocks', 'Healthcare Stocks',
		'Energy Stocks', 'Government Bonds', 'Corporate Bonds', 'Commercial', 'Residential']

	parents := ['', 'Portfolio', 'Portfolio', 'Portfolio', 'Stocks', 'Stocks', 'Stocks', 'Bonds',
		'Bonds', 'Real Estate', 'Real Estate']

	values := [1000000.0, 600000, 250000, 150000, 300000, 200000, 100000, 150000, 100000, 90000,
		60000]

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add treemap trace
	plt.treemap(
		labels:       labels
		parents:      parents
		values:       values
		branchvalues: 'total'
		maxdepth:     3
		name:         'Investment Portfolio'
		pathbar:      plot.PathBar{
			visible:   true
			side:      'top'
			edgeshape: 'rounded'
			thickness: 20
		}
	)

	// Configure the plot layout
	plt.layout(
		title:         'Investment Portfolio Distribution - Treemap'
		width:         700
		height:        500
		paper_bgcolor: '#ffffff'
		showlegend:    false
	)

	// Display the plot
	plt.show()!
}
