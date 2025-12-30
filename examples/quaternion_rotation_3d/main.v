module main

import vsl.quaternion
import vsl.plot
import math

// Rotate a 3D point using quaternion rotation
fn rotate_point(q quaternion.Quaternion, px f64, py f64, pz f64) (f64, f64, f64) {
	// Treat point as pure quaternion (0, px, py, pz)
	p := quaternion.quaternion(0.0, px, py, pz)

	// Get conjugate (inverse for unit quaternion)
	q_conj := q.conjugate()

	// Rotate: p' = q * p * q⁻¹
	rotated := q.multiply(p).multiply(q_conj)

	// Extract vector part
	return rotated.x, rotated.y, rotated.z
}

fn main() {
	// Create rotation: 45 degrees around normalized axis (1, 1, 1)
	axis := [1.0, 1.0, 1.0]
	axis_norm := math.sqrt(axis[0] * axis[0] + axis[1] * axis[1] + axis[2] * axis[2])
	axis_normalized := [axis[0] / axis_norm, axis[1] / axis_norm, axis[2] / axis_norm]

	angle := math.pi / 4.0 // 45 degrees
	q := quaternion.from_axis_anglef3(angle, axis_normalized[0], axis_normalized[1], axis_normalized[2])

	println('Rotation quaternion: ${q}')
	println('Quaternion magnitude: ${q.abs()}')

	// Define a unit cube vertices
	vertices := [
		[-1.0, -1.0, -1.0],
		[1.0, -1.0, -1.0],
		[1.0, 1.0, -1.0],
		[-1.0, 1.0, -1.0],
		[-1.0, -1.0, 1.0],
		[1.0, -1.0, 1.0],
		[1.0, 1.0, 1.0],
		[-1.0, 1.0, 1.0],
	]

	// Rotate vertices
	mut x_rotated := []f64{}
	mut y_rotated := []f64{}
	mut z_rotated := []f64{}

	for v in vertices {
		x, y, z := rotate_point(q, v[0], v[1], v[2])
		x_rotated << x
		y_rotated << y
		z_rotated << z
		println('(${v[0]:.2f}, ${v[1]:.2f}, ${v[2]:.2f}) -> (${x:.2f}, ${y:.2f}, ${z:.2f})')
	}

	// Original cube coordinates
	x_orig := vertices.map(it[0])
	y_orig := vertices.map(it[1])
	z_orig := vertices.map(it[2])

	// Create plot
	mut plt := plot.Plot.new()

	// Plot original cube (gray, smaller markers)
	plt.scatter3d(
		x:      x_orig
		y:      y_orig
		z:      z_orig
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_orig.len, init: 8.0}
			color: []string{len: x_orig.len, init: '#888888'}
		}
		name:   'Original Cube'
	)

	// Plot rotated cube (red, larger markers)
	plt.scatter3d(
		x:      x_rotated
		y:      y_rotated
		z:      z_rotated
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_rotated.len, init: 12.0}
			color: []string{len: x_rotated.len, init: '#FF0000'}
		}
		name:   'Rotated Cube'
	)

	// Add edges for better visualization (simplified - just some key edges)
	// Front face edges
	edge_indices := [
		[0, 1],
		[1, 2],
		[2, 3],
		[3, 0], // front face
		[4, 5],
		[5, 6],
		[6, 7],
		[7, 4], // back face
		[0, 4],
		[1, 5],
		[2, 6],
		[3, 7], // connecting edges
	]

	// Original cube edges
	for edge in edge_indices {
		mut x_edge := []f64{}
		mut y_edge := []f64{}
		mut z_edge := []f64{}
		x_edge << vertices[edge[0]][0]
		x_edge << vertices[edge[1]][0]
		y_edge << vertices[edge[0]][1]
		y_edge << vertices[edge[1]][1]
		z_edge << vertices[edge[0]][2]
		z_edge << vertices[edge[1]][2]

		plt.scatter3d(
			x:    x_edge
			y:    y_edge
			z:    z_edge
			mode: 'lines'
			line: plot.Line{
				color: '#CCCCCC'
				width: 1.0
			}
		)
	}

	// Rotated cube edges
	for edge in edge_indices {
		mut x_edge := []f64{}
		mut y_edge := []f64{}
		mut z_edge := []f64{}
		x_edge << x_rotated[edge[0]]
		x_edge << x_rotated[edge[1]]
		y_edge << y_rotated[edge[0]]
		y_edge << y_rotated[edge[1]]
		z_edge << z_rotated[edge[0]]
		z_edge << z_rotated[edge[1]]

		plt.scatter3d(
			x:    x_edge
			y:    y_edge
			z:    z_edge
			mode: 'lines'
			line: plot.Line{
				color: '#FF6666'
				width: 2.0
			}
		)
	}

	plt.layout(
		title: 'Quaternion 3D Rotation Visualization'
	)

	plt.show()!

	println('\nPlot displayed! Rotate and zoom to see the rotation effect.')
}
