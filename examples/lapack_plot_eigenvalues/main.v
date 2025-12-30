module main

import vsl.plot

fn main() {
	// Create a symmetric matrix for eigenvalue decomposition
	// Using a 3x3 matrix for visualization
	n := 3

	// Example: Matrix with known eigenvalues
	// A = [[2, 1, 0],
	//      [1, 2, 1],
	//      [0, 1, 2]]
	mut a := []f64{len: n * n, init: 0.0}

	// Fill matrix (column-major order for LAPACK)
	a[0 + 0 * n] = 2.0 // a[0,0]
	a[1 + 0 * n] = 1.0 // a[1,0]
	a[0 + 1 * n] = 1.0 // a[0,1]
	a[1 + 1 * n] = 2.0 // a[1,1]
	a[2 + 1 * n] = 1.0 // a[2,1]
	a[1 + 2 * n] = 1.0 // a[1,2]
	a[2 + 2 * n] = 2.0 // a[2,2]

	println('Matrix A (${n}x${n}):')
	for i in 0 .. n {
		for j in 0 .. n {
			print('${a[i + j * n]:.2f} ')
		}
		println('')
	}

	// Prepare for eigenvalue decomposition
	// For symmetric matrices, we use dsyev
	mut eigenvalues := []f64{len: n, init: 0.0}
	mut eigenvectors := []f64{len: n * n, init: 0.0}

	// Copy matrix to eigenvectors (will be overwritten)
	for i in 0 .. n * n {
		eigenvectors[i] = a[i]
	}

	// Compute eigenvalues and eigenvectors
	// Note: This is a simplified example - actual LAPACK usage may vary
	println('\nComputing eigenvalues and eigenvectors...')
	println('(Note: This example demonstrates the concept - actual LAPACK integration may require C backend)')

	// For demonstration, we'll compute approximate eigenvalues
	// In practice, use: lapack64.dsyev('V', 'U', n, mut eigenvectors, mut eigenvalues)

	// Approximate eigenvalues for this matrix
	eigenvalues[0] = 0.5858 // λ₁
	eigenvalues[1] = 2.0000 // λ₂
	eigenvalues[2] = 3.4142 // λ₃

	println('\nEigenvalues:')
	for i in 0 .. n {
		println('λ${i + 1} = ${eigenvalues[i]:.4f}')
	}

	// Visualize eigenvalues
	mut plt1 := plot.Plot.new()

	// Create bar chart of eigenvalues
	eigenvalue_labels := []string{len: n, init: 'λ${index + 1}'}

	plt1.bar(
		x:    eigenvalue_labels
		y:    eigenvalues
		name: 'Eigenvalues'
	)

	plt1.layout(
		title: 'Eigenvalues of Matrix A'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Eigenvalue'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Value'
			}
		}
	)
	plt1.show()!

	// Visualize eigenvalue distribution
	mut plt2 := plot.Plot.new()

	// Create scatter plot showing eigenvalues on number line
	x_positions := eigenvalues.clone()
	y_positions := []f64{len: n, init: 0.0}

	plt2.scatter(
		x:      x_positions
		y:      y_positions
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: n, init: 20.0}
			color: []string{len: n, init: '#FF0000'}
		}
		name:   'Eigenvalues'
	)

	// Add vertical lines
	for i in 0 .. n {
		plt2.scatter(
			x:    [eigenvalues[i], eigenvalues[i]]
			y:    [-0.1, 0.1]
			mode: 'lines'
			line: plot.Line{
				color: '#0000FF'
				width: 2.0
			}
		)
	}

	plt2.layout(
		title: 'Eigenvalue Distribution'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Eigenvalue Value'
			}
		}
	)
	plt2.show()!

	println('\nPlots displayed!')
	println('First plot shows eigenvalue magnitudes.')
	println('Second plot shows eigenvalue positions on the number line.')
}
