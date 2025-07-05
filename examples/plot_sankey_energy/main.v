module main

import vsl.plot

fn main() {
	// Create a Sankey diagram for energy flow analysis
	// Showing energy sources -> processing -> end uses
	
	// Define nodes (energy sources, processes, end uses)
	node_labels := [
		// Sources (0-4)
		'Solar', 'Wind', 'Nuclear', 'Coal', 'Natural Gas',
		// Processing (5-8)  
		'Power Grid', 'Heating Plant', 'Refinery', 'Distribution',
		// End Uses (9-12)
		'Residential', 'Commercial', 'Industrial', 'Transportation'
	]
	
	// Define flows between nodes
	// Source indices
	sources := [
		0, 1, 2, 3, 4,    // Sources to Power Grid
		0, 4,             // Sources to Heating
		3, 4,             // Sources to Refinery
		5, 6, 7,          // Processing to Distribution
		8, 8, 8, 8        // Distribution to End Uses
	]
	
	// Target indices  
	targets := [
		5, 5, 5, 5, 5,    // To Power Grid
		6, 6,             // To Heating Plant
		7, 7,             // To Refinery
		8, 8, 8,          // To Distribution
		9, 10, 11, 12     // To End Uses
	]
	
	// Flow values (energy amounts in TWh)
	values := [
		120.0, 150.0, 200.0, 180.0, 220.0,  // Sources to Grid
		80.0, 100.0,                         // Sources to Heating
		50.0, 70.0,                          // Sources to Refinery
		600.0, 120.0, 80.0,                  // Processing to Distribution
		250.0, 200.0, 300.0, 150.0          // Distribution to End Uses
	]
	
	// Create node colors
	node_colors := [
		// Sources - green tones
		'#2E8B57', '#32CD32', '#9ACD32', '#8B4513', '#4682B4',
		// Processing - blue tones
		'#1E90FF', '#4169E1', '#0000CD', '#191970',
		// End uses - orange/red tones
		'#FF6347', '#FF4500', '#FF8C00', '#FFA500'
	]
	
	// Create link colors (lighter versions)
	link_colors := [
		'rgba(46,139,87,0.3)', 'rgba(50,205,50,0.3)', 'rgba(154,205,50,0.3)', 
		'rgba(139,69,19,0.3)', 'rgba(70,130,180,0.3)',
		'rgba(46,139,87,0.3)', 'rgba(70,130,180,0.3)',
		'rgba(139,69,19,0.3)', 'rgba(70,130,180,0.3)',
		'rgba(30,144,255,0.3)', 'rgba(65,105,225,0.3)', 'rgba(0,0,205,0.3)',
		'rgba(255,99,71,0.3)', 'rgba(255,69,0,0.3)', 'rgba(255,140,0,0.3)', 'rgba(255,165,0,0.3)'
	]
	
	// Create a new plot instance
	mut plt := plot.Plot.new()
	
	// Add Sankey diagram
	plt.sankey(
		node: plot.SankeyNode{
			label: node_labels
			color: node_colors
			thickness: 20.0
			pad: 10.0
		}
		link: plot.SankeyLink{
			source: sources
			target: targets
			value: values
			color: link_colors
		}
		orientation: 'h'
		valueformat: '.1f'
		valuesuffix: ' TWh'
		name: 'Energy Flow Analysis'
	)
	
	// Configure the plot layout
	plt.layout(
		title: 'Energy Flow Analysis: Sources to End Uses'
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
		width: 1000
		height: 700
	)

	// Display the plot
	println('Sankey energy flow diagram created successfully!')
	plt.show()!
}
