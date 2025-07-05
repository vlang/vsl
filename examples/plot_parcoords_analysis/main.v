module main

import vsl.plot
import math

// Helper function to clamp values between min and max
fn clamp(value f64, min f64, max f64) f64 {
	if value < min {
		return min
	}
	if value > max {
		return max
	}
	return value
}

fn main() {
	// Generate multi-dimensional data for parallel coordinates analysis
	// Simulating employee performance metrics
	
	n_employees := 100
	
	// Generate correlated performance metrics
	mut experience := []f64{}
	mut salary := []f64{}
	mut performance := []f64{}
	mut satisfaction := []f64{}
	mut education := []f64{}
	
	for i in 0 .. n_employees {
		// Experience (years): 0-20
		exp := (20.0 * f64(i) / f64(n_employees)) + 2.0 * math.sin(f64(i) * 0.314)
		experience_val := clamp(exp, 0.0, 20.0)
		
		// Salary correlated with experience (K USD)
		salary_val := 40.0 + 3.0 * experience_val + 10.0 * math.sin(f64(i) * 0.157)
		
		// Performance score (1-10) correlated with experience and salary
		perf_val := 5.0 + 0.2 * experience_val + 0.05 * (salary_val - 50.0) + 2.0 * math.cos(f64(i) * 0.628)
		
		// Job satisfaction (1-10) correlated with salary and performance
		sat_val := 4.0 + 0.06 * salary_val + 0.3 * perf_val + 1.5 * math.sin(f64(i) * 0.471)
		
		// Education level (1-5: High School to PhD)
		edu_val := 2.0 + 0.1 * experience_val + 0.02 * salary_val + 0.5 * math.cos(f64(i) * 0.942)
		
		experience << experience_val
		salary << clamp(salary_val, 35.0, 120.0)
		performance << clamp(perf_val, 1.0, 10.0)
		satisfaction << clamp(sat_val, 1.0, 10.0)
		education << clamp(edu_val, 1.0, 5.0)
	}
	
	// Create a new plot instance
	mut plt := plot.Plot.new()
	
	// Create dimensions for parallel coordinates
	dimensions := [
		plot.Dimension{
			label: 'Experience (years)'
			values: experience
			range: [0.0, 20.0]
		},
		plot.Dimension{
			label: 'Salary (K USD)'
			values: salary
			range: [35.0, 120.0]
		},
		plot.Dimension{
			label: 'Performance (1-10)'
			values: performance
			range: [1.0, 10.0]
		},
		plot.Dimension{
			label: 'Satisfaction (1-10)'
			values: satisfaction
			range: [1.0, 10.0]
		},
		plot.Dimension{
			label: 'Education (1-5)'
			values: education
			range: [1.0, 5.0]
		}
	]
	
	// Add parallel coordinates plot
	plt.parcoords(
		dimensions: dimensions
		line: plot.ParallelLine{
			color: performance  // Color by performance score
			colorscale: 'Viridis'
			showscale: true
		}
		name: 'Employee Performance Analysis'
	)
	
	// Configure the plot layout
	plt.layout(
		title: 'Multi-Dimensional Employee Performance Analysis'
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
		width: 900
		height: 600
	)

	// Display the plot
	println('Parallel coordinates analysis created successfully!')
	plt.show()!
}
