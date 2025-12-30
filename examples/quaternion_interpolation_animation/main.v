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
	// Start rotation: 0 degrees around x-axis
	q_start := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)

	// End rotation: 180 degrees around x-axis
	q_end := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

	// Point to rotate
	px, py, pz := 1.0, 0.0, 0.0

	// Generate rotation path using SLERP
	steps := 50
	mut x_path := []f64{}
	mut y_path := []f64{}
	mut z_path := []f64{}
	mut t_vals := []f64{}

	println('Generating SLERP interpolation path...')
	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q_interp := q_start.slerp(q_end, t)
		x, y, z := rotate_point(q_interp, px, py, pz)
		x_path << x
		y_path << y
		z_path << z
		t_vals << t

		if i % 10 == 0 {
			println('t=${t:.2f}: point=(${x:.3f}, ${y:.3f}, ${z:.3f}), quaternion=${q_interp}')
		}
	}

	// Also generate LERP and NLERP paths for comparison
	mut x_lerp := []f64{}
	mut y_lerp := []f64{}
	mut z_lerp := []f64{}

	mut x_nlerp := []f64{}
	mut y_nlerp := []f64{}
	mut z_nlerp := []f64{}

	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)

		// LERP (normalized)
		q_lerp := q_start.lerp(q_end, t).normalized()
		x, y, z := rotate_point(q_lerp, px, py, pz)
		x_lerp << x
		y_lerp << y
		z_lerp << z

		// NLERP
		q_nlerp := q_start.nlerp(q_end, t)
		x_nlerp_val, y_nlerp_val, z_nlerp_val := rotate_point(q_nlerp, px, py, pz)
		x_nlerp << x_nlerp_val
		y_nlerp << y_nlerp_val
		z_nlerp << z_nlerp_val
	}

	// Create plot
	mut plt := plot.Plot.new()

	// Plot SLERP path (blue, smooth)
	plt.scatter3d(
		x:      x_path
		y:      y_path
		z:      z_path
		mode:   'lines+markers'
		marker: plot.Marker{
			size:  []f64{len: x_path.len, init: 4.0}
			color: []string{len: x_path.len, init: '#0066FF'}
		}
		line:   plot.Line{
			color: '#0066FF'
			width: 3.0
		}
		name:   'SLERP (Spherical Linear)'
	)

	// Plot NLERP path (green)
	plt.scatter3d(
		x:    x_nlerp
		y:    y_nlerp
		z:    z_nlerp
		mode: 'lines'
		line: plot.Line{
			color: '#00FF00'
			width: 2.0
			dash:  'dash'
		}
		name: 'NLERP (Normalized Linear)'
	)

	// Plot LERP path (red, dashed)
	plt.scatter3d(
		x:    x_lerp
		y:    y_lerp
		z:    z_lerp
		mode: 'lines'
		line: plot.Line{
			color: '#FF0000'
			width: 2.0
			dash:  'dot'
		}
		name: 'LERP (Linear)'
	)

	// Mark start point (green)
	plt.scatter3d(
		x:      [px]
		y:      [py]
		z:      [pz]
		mode:   'markers'
		marker: plot.Marker{
			size:  [20.0]
			color: ['#00FF00']
		}
		name:   'Start Point'
	)

	// Mark end point (red)
	x_end, y_end, z_end := rotate_point(q_end, px, py, pz)
	plt.scatter3d(
		x:      [x_end]
		y:      [y_end]
		z:      [z_end]
		mode:   'markers'
		marker: plot.Marker{
			size:  [20.0]
			color: ['#FF0000']
		}
		name:   'End Point'
	)

	plt.layout(
		title: 'Quaternion Interpolation Comparison (SLERP vs NLERP vs LERP)'
	)

	plt.show()!

	println('\nPlot displayed! Compare the smoothness of different interpolation methods.')
	println('SLERP follows the shortest path on the 4D sphere.')
}
