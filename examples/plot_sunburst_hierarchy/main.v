module main

import vsl.plot

fn main() {
	// Define hierarchical data for a company organization
	labels := ['Company', 'Engineering', 'Sales', 'Marketing', 'Frontend', 'Backend', 'DevOps',
		'Inside Sales', 'Field Sales', 'Digital Marketing', 'Content Marketing']

	parents := ['', 'Company', 'Company', 'Company', 'Engineering', 'Engineering', 'Engineering',
		'Sales', 'Sales', 'Marketing', 'Marketing']

	values := [100.0, 40, 30, 20, 15, 20, 5, 15, 15, 12, 8]

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add sunburst trace
	plt.sunburst(
		labels:       labels
		parents:      parents
		values:       values
		branchvalues: 'total'
		maxdepth:     3
		name:         'Organization Structure'
		// The sunburst will automatically color-code the segments
	)

	// Configure the plot layout
	plt.layout(
		title:         'Company Organization - Sunburst Chart'
		width:         600
		height:        600
		paper_bgcolor: '#ffffff'
		showlegend:    false
	)

	// Display the plot
	plt.show()!
}
