module main

import vsl.plot

fn main() {
	// Generate sample data for different groups (e.g., test scores from different classes)
	// Create data in a format that works well with box plots

	// All data combined with group labels
	all_scores := [
		// Class A scores
		85.0,
		87,
		89,
		90,
		92,
		88,
		91,
		93,
		86,
		89,
		94,
		87,
		90,
		88,
		92,
		89,
		91,
		90,
		88,
		93,
		// Class B scores
		75.0,
		78,
		72,
		79,
		81,
		76,
		74,
		80,
		77,
		73,
		82,
		75,
		78,
		76,
		79,
		74,
		77,
		80,
		73,
		81,
		// Class C scores
		65.0,
		95,
		70,
		85,
		60,
		90,
		75,
		80,
		55,
		88,
		72,
		92,
		68,
		83,
		62,
		87,
		78,
		91,
		58,
		86,
	]

	// Create group labels for each score
	group_labels := []string{len: 60, init: match index {
		0...19 { 'Class A (High Performers)' }
		20...39 { 'Class B (Average Performers)' }
		else { 'Class C (Variable Performers)' }
	}}

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add a single box plot with all data grouped
	plt.box(
		x:         group_labels
		y:         all_scores
		boxpoints: 'outliers' // Show outlier points
		marker:    plot.Marker{
			color: ['#2E8B57', '#4682B4', '#CD853F'] // Different colors for each group
		}
	)

	// Configure the plot layout
	plt.layout(
		title:         'Test Score Distribution by Class'
		xaxis:         plot.Axis{
			title: plot.AxisTitle{
				text: 'Class Groups'
			}
		}
		yaxis:         plot.Axis{
			title: plot.AxisTitle{
				text: 'Test Scores'
			}
			range: [50.0, 100.0]
		}
		plot_bgcolor:  '#f8f9fa'
		paper_bgcolor: '#ffffff'
		showlegend:    false
	)

	// Display the plot
	plt.show()!
}
