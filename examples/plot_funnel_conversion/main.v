module main

import vsl.plot

fn main() {
	// Define conversion funnel data for a website
	stages := ['Website Visitors', 'Product Views', 'Add to Cart', 'Begin Checkout', 'Complete Purchase']

	counts := [10000.0, 5000, 1500, 800, 350]

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add funnel trace
	plt.funnel(
		x: stages
		y: counts
		name: 'Conversion Funnel'
		orientation: 'v'
		connector: plot.Connector{
			visible: true
			line: plot.Line{
				color: '#888888'
				width: 2.0
			}
		}
		marker: plot.Marker{
			color: ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57']
		}
		text: ['10,000 visitors', '5,000 views (50%)', '1,500 carts (30%)',
			   '800 checkouts (53%)', '350 purchases (44%)']
	)

	// Configure the plot layout
	plt.layout(
		title: 'Website Conversion Funnel Analysis'
		xaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Conversion Stage'}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Number of Users'}
			showgrid: true
		}
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
		showlegend: false
	)

	// Display the plot
	plt.show()!
}
