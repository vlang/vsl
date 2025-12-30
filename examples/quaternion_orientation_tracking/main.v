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
	// Simulate object orientation over time
	// Object starts at identity orientation and rotates through space

	time_steps := 100
	mut orientations := []quaternion.Quaternion{}
	mut time_points := []f64{}

	// Create a sequence of rotations simulating object motion
	// Rotate around different axes over time
	for t in 0 .. time_steps {
		time_val := f64(t) / f64(time_steps - 1)
		time_points << time_val

		// Create time-varying rotation
		// Rotate around x-axis with frequency 1
		angle_x := 2.0 * math.pi * time_val
		q_x := quaternion.from_axis_anglef3(angle_x, 1.0, 0.0, 0.0)

		// Rotate around y-axis with frequency 2
		angle_y := math.pi * time_val
		q_y := quaternion.from_axis_anglef3(angle_y, 0.0, 1.0, 0.0)

		// Compose rotations
		q_total := q_y.multiply(q_x)
		orientations << q_total
	}

	println('Tracking orientation over ${time_steps} time steps...')

	// Track a point on the object (e.g., a unit vector pointing forward)
	point_x, point_y, point_z := 0.0, 0.0, 1.0

	// Rotate the point through all orientations
	mut x_tracked := []f64{}
	mut y_tracked := []f64{}
	mut z_tracked := []f64{}

	for q in orientations {
		x, y, z := rotate_point(q, point_x, point_y, point_z)
		x_tracked << x
		y_tracked << y
		z_tracked << z
	}

	// Extract quaternion components over time
	mut w_vals := []f64{}
	mut x_vals := []f64{}
	mut y_vals := []f64{}
	mut z_vals := []f64{}

	for q in orientations {
		w_vals << q.w
		x_vals << q.x
		y_vals << q.y
		z_vals << q.z
	}

	// Create plots
	println('Generating plots...')

	// Plot 1: 3D trajectory of tracked point
	mut plt1 := plot.Plot.new()
	plt1.scatter3d(
		x:      x_tracked
		y:      y_tracked
		z:      z_tracked
		mode:   'lines+markers'
		marker: plot.Marker{
			size:  []f64{len: x_tracked.len, init: 3.0}
			color: []string{len: x_tracked.len, init: '#0066FF'}
		}
		line:   plot.Line{
			color: '#0066FF'
			width: 2.0
		}
		name:   'Orientation Trajectory'
	)
	plt1.layout(
		title: 'Object Orientation Tracking - 3D Trajectory'
	)
	plt1.show()!

	// Plot 2: Quaternion components over time
	mut plt2 := plot.Plot.new()
	plt2.scatter(
		x:    time_points
		y:    w_vals
		mode: 'lines'
		name: 'w (scalar)'
		line: plot.Line{
			color: '#FF0000'
		}
	)
	plt2.scatter(
		x:    time_points
		y:    x_vals
		mode: 'lines'
		name: 'x'
		line: plot.Line{
			color: '#00FF00'
		}
	)
	plt2.scatter(
		x:    time_points
		y:    y_vals
		mode: 'lines'
		name: 'y'
		line: plot.Line{
			color: '#0000FF'
		}
	)
	plt2.scatter(
		x:    time_points
		y:    z_vals
		mode: 'lines'
		name: 'z'
		line: plot.Line{
			color: '#FF00FF'
		}
	)
	plt2.layout(
		title: 'Quaternion Components Over Time'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Time'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Component Value'
			}
		}
	)
	plt2.show()!

	println('\nPlots displayed!')
	println('First plot shows the 3D trajectory of a tracked point.')
	println('Second plot shows how quaternion components change over time.')
}
