module main

import vsl.quaternion
import vsl.plot
import math

// Rotate a 3D point using quaternion rotation
fn rotate_point(q quaternion.Quaternion, px f64, py f64, pz f64) (f64, f64, f64) {
	p := quaternion.quaternion(0.0, px, py, pz)
	q_conj := q.conjugate()
	rotated := q.multiply(p).multiply(q_conj)
	return rotated.x, rotated.y, rotated.z
}

fn main() {
	// Define a point to rotate
	px, py, pz := 1.0, 0.0, 0.0

	println('Original point: (${px}, ${py}, ${pz})')
	println('')

	// Create multiple rotations
	// Rotation 1: 90 degrees around x-axis
	q1 := quaternion.from_axis_anglef3(math.pi / 2.0, 1.0, 0.0, 0.0)
	println('Rotation 1: 90° around x-axis')
	println('Quaternion: ${q1}')

	// Rotation 2: 90 degrees around y-axis
	q2 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 1.0, 0.0)
	println('Rotation 2: 90° around y-axis')
	println('Quaternion: ${q2}')

	// Rotation 3: 90 degrees around z-axis
	q3 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0)
	println('Rotation 3: 90° around z-axis')
	println('Quaternion: ${q3}')
	println('')

	// Apply rotations individually
	x1, y1, z1 := rotate_point(q1, px, py, pz)
	println('After rotation 1: (${x1:.3f}, ${y1:.3f}, ${z1:.3f})')

	x2, y2, z2 := rotate_point(q2, px, py, pz)
	println('After rotation 2: (${x2:.3f}, ${y2:.3f}, ${z2:.3f})')

	x3, y3, z3 := rotate_point(q3, px, py, pz)
	println('After rotation 3: (${x3:.3f}, ${y3:.3f}, ${z3:.3f})')
	println('')

	// Compose rotations: q2 * q1 (apply q1 first, then q2)
	q_composed_12 := q2.multiply(q1)
	println('Composed rotation q2 * q1:')
	println('Quaternion: ${q_composed_12}')
	x_comp_12, y_comp_12, z_comp_12 := rotate_point(q_composed_12, px, py, pz)
	println('Result: (${x_comp_12:.3f}, ${y_comp_12:.3f}, ${z_comp_12:.3f})')
	println('')

	// Compose all three: q3 * q2 * q1
	q_composed_all := q3.multiply(q2).multiply(q1)
	println('Composed rotation q3 * q2 * q1:')
	println('Quaternion: ${q_composed_all}')
	x_comp_all, y_comp_all, z_comp_all := rotate_point(q_composed_all, px, py, pz)
	println('Result: (${x_comp_all:.3f}, ${y_comp_all:.3f}, ${z_comp_all:.3f})')
	println('')

	// Visualize the rotation path
	steps := 20
	mut x_path := []f64{}
	mut y_path := []f64{}
	mut z_path := []f64{}
	mut labels := []string{}

	// Start point
	x_path << px
	y_path << py
	z_path << pz
	labels << 'Start'

	// After q1
	x_path << x1
	y_path << y1
	z_path << z1
	labels << 'After q1'

	// After q2 * q1
	x_path << x_comp_12
	y_path << y_comp_12
	z_path << z_comp_12
	labels << 'After q2*q1'

	// After q3 * q2 * q1
	x_path << x_comp_all
	y_path << y_comp_all
	z_path << z_comp_all
	labels << 'After q3*q2*q1'

	// Create intermediate steps for smooth visualization
	mut x_smooth := []f64{}
	mut y_smooth := []f64{}
	mut z_smooth := []f64{}

	// Smooth path from start to q1
	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q_interp := quaternion.id().slerp(q1, t)
		x, y, z := rotate_point(q_interp, px, py, pz)
		x_smooth << x
		y_smooth << y
		z_smooth << z
	}

	// Smooth path from q1 to q2*q1
	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q_interp := q1.slerp(q_composed_12, t)
		x, y, z := rotate_point(q_interp, px, py, pz)
		x_smooth << x
		y_smooth << y
		z_smooth << z
	}

	// Smooth path from q2*q1 to q3*q2*q1
	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q_interp := q_composed_12.slerp(q_composed_all, t)
		x, y, z := rotate_point(q_interp, px, py, pz)
		x_smooth << x
		y_smooth << y
		z_smooth << z
	}

	// Create plot
	mut plt := plot.Plot.new()

	// Plot smooth path
	plt.scatter3d(
		x:    x_smooth
		y:    y_smooth
		z:    z_smooth
		mode: 'lines'
		line: plot.Line{
			color: '#0066FF'
			width: 2.0
		}
		name: 'Rotation Path'
	)

	// Plot key points
	plt.scatter3d(
		x:      x_path
		y:      y_path
		z:      z_path
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_path.len, init: 15.0}
			color: ['#00FF00', '#FFFF00', '#FF8800', '#FF0000']
		}
		name:   'Key Points'
	)

	plt.layout(
		title: 'Quaternion Rotation Composition Visualization'
	)

	plt.show()!

	println('\nPlot displayed!')
	println('Green = Start, Yellow = After q1, Orange = After q2*q1, Red = After q3*q2*q1')
	println('Note: Order matters! q2 * q1 means apply q1 first, then q2.')
}
