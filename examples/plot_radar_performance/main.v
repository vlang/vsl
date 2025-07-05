module main

import vsl.plot
import math

fn main() {
	// Define performance metrics for employee evaluation
	metrics := ['Communication', 'Technical Skills', 'Leadership', 'Problem Solving',
				'Teamwork', 'Innovation', 'Time Management']

	// Employee A scores (out of 10)
	employee_a_scores := [8.5, 9.0, 7.0, 8.8, 9.2, 7.5, 8.0]

	// Employee B scores (out of 10)
	employee_b_scores := [7.0, 8.5, 9.0, 7.5, 8.0, 9.5, 6.5]

	// Convert metrics to angles (in degrees)
	num_metrics := metrics.len
	mut angles := []f64{}
	for i in 0 .. num_metrics {
		angle := f64(i) * 360.0 / f64(num_metrics)
		angles << angle
	}
	// Close the polygon by adding the first point at the end
	angles << 0.0

	// Close the data arrays for the polygon
	mut emp_a_closed := employee_a_scores.clone()
	emp_a_closed << employee_a_scores[0]

	mut emp_b_closed := employee_b_scores.clone()
	emp_b_closed << employee_b_scores[0]

	// Create a new plot instance
	mut plt := plot.Plot.new()

	// Add radar traces
	plt.scatterpolar(
		r: emp_a_closed
		theta: angles
		mode: 'lines+markers'
		name: 'Employee A'
		fill: 'toself'
		fillcolor: 'rgba(255, 107, 107, 0.3)'
		line: plot.Line{
			color: '#FF6B6B'
			width: 2.0
		}
		marker: plot.Marker{
			color: ['#FF6B6B']
			size: [6.0]
		}
	)

	plt.scatterpolar(
		r: emp_b_closed
		theta: angles
		mode: 'lines+markers'
		name: 'Employee B'
		fill: 'toself'
		fillcolor: 'rgba(78, 205, 196, 0.3)'
		line: plot.Line{
			color: '#4ECDC4'
			width: 2.0
		}
		marker: plot.Marker{
			color: ['#4ECDC4']
			size: [6.0]
		}
	)

	// Configure the plot layout for polar coordinates
	plt.layout(
		title: 'Employee Performance Radar Chart'
		polar: plot.Polar{
			radialaxis: plot.RadialAxis{
				visible: true
				range: [0.0, 10.0]
				tickvals: [0.0, 2.0, 4.0, 6.0, 8.0, 10.0]
			}
			angularaxis: plot.AngularAxis{
				tickvals: angles[..num_metrics]  // Exclude the duplicate first point
				ticktext: metrics
				direction: 'clockwise'
				period: 360.0
			}
		}
		showlegend: true
		width: 600
		height: 600
		paper_bgcolor: '#ffffff'
	)

	// Display the plot
	plt.show()!
}
