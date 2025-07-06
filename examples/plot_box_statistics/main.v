module main

import vsl.plot

fn main() {
	// Generate sample data for different groups (e.g., test scores from different classes)
	// Group A: High-performing class
	group_a := [85.0, 87, 89, 90, 92, 88, 91, 93, 86, 89, 94, 87, 90, 88, 92, 89, 91, 90, 88, 93]

	// Group B: Average-performing class
	group_b := [75.0, 78, 72, 79, 81, 76, 74, 80, 77, 73, 82, 75, 78, 76, 79, 74, 77, 80, 73, 81]

	// Group C: Variable-performing class (wider distribution)
	group_c := [65.0, 95, 70, 85, 60, 90, 75, 80, 55, 88, 72, 92, 68, 83, 62, 87, 78, 91, 58, 86]

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add box plots for each group
	plt.box(
		x:         ['Class A'] // Explicit x position
		y:         group_a
		name:      'Class A (High Performers)'
		boxpoints: 'outliers' // Show outlier points
		marker:    plot.Marker{
			color: ['#2E8B57'] // Sea green
		}
	)

	plt.box(
		x:         ['Class B'] // Explicit x position
		y:         group_b
		name:      'Class B (Average Performers)'
		boxpoints: 'outliers'
		marker:    plot.Marker{
			color: ['#4682B4'] // Steel blue
		}
	)

	plt.box(
		x:         ['Class C'] // Explicit x position
		y:         group_c
		name:      'Class C (Variable Performers)'
		boxpoints: 'outliers'
		marker:    plot.Marker{
			color: ['#CD853F'] // Peru
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
		showlegend:    true
	)

	// Display the plot
	plt.show()!
}
