module main

import vsl.quaternion
import vsl.plot
import math

// Simplified FFT-like processing for quaternion signals
// In practice, you'd use vsl.fft for actual FFT operations
fn process_quaternion_signal(signal []quaternion.Quaternion) []f64 {
	// Extract magnitude of each quaternion as signal strength
	mut magnitudes := []f64{cap: signal.len}
	for q in signal {
		magnitudes << q.abs()
	}
	return magnitudes
}

fn main() {
	// Generate a quaternion-valued signal
	// Simulate a rotating object's orientation over time
	n_samples := 100

	mut quaternion_signal := []quaternion.Quaternion{cap: n_samples}
	mut time_points := []f64{cap: n_samples}

	println('Generating quaternion signal...')

	// Create a signal with time-varying rotation
	for i in 0 .. n_samples {
		t := f64(i) / f64(n_samples - 1)
		time_points << t

		// Rotate around x-axis with frequency 2 Hz
		angle_x := 2.0 * math.pi * 2.0 * t
		q_x := quaternion.from_axis_anglef3(angle_x, 1.0, 0.0, 0.0)

		// Add smaller rotation around y-axis (frequency 5 Hz)
		angle_y := 2.0 * math.pi * 5.0 * t * 0.1
		q_y := quaternion.from_axis_anglef3(angle_y, 0.0, 1.0, 0.0)

		// Compose rotations
		q_total := q_y.multiply(q_x)
		quaternion_signal << q_total
	}

	println('Signal length: ${quaternion_signal.len} samples')

	// Process signal: extract magnitudes
	magnitudes := process_quaternion_signal(quaternion_signal)

	// Extract quaternion components for visualization
	mut w_vals := []f64{}
	mut x_vals := []f64{}
	mut y_vals := []f64{}
	mut z_vals := []f64{}

	for q in quaternion_signal {
		w_vals << q.w
		x_vals << q.x
		y_vals << q.y
		z_vals << q.z
	}

	// Create plots
	println('Generating plots...')

	// Plot 1: Quaternion components over time
	mut plt1 := plot.Plot.new()
	plt1.scatter(
		x:    time_points
		y:    w_vals
		mode: 'lines'
		name: 'w (scalar)'
		line: plot.Line{
			color: '#FF0000'
		}
	)
	plt1.scatter(
		x:    time_points
		y:    x_vals
		mode: 'lines'
		name: 'x'
		line: plot.Line{
			color: '#00FF00'
		}
	)
	plt1.scatter(
		x:    time_points
		y:    y_vals
		mode: 'lines'
		name: 'y'
		line: plot.Line{
			color: '#0000FF'
		}
	)
	plt1.scatter(
		x:    time_points
		y:    z_vals
		mode: 'lines'
		name: 'z'
		line: plot.Line{
			color: '#FF00FF'
		}
	)

	plt1.layout(
		title: 'Quaternion Signal Components (Time Domain)'
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
	plt1.show()!

	// Plot 2: Signal magnitude
	mut plt2 := plot.Plot.new()
	plt2.scatter(
		x:    time_points
		y:    magnitudes
		mode: 'lines'
		name: 'Signal Magnitude'
		line: plot.Line{
			color: '#0066FF'
			width: 2.0
		}
	)

	plt2.layout(
		title: 'Quaternion Signal Magnitude'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Time'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Magnitude |q|'
			}
		}
	)
	plt2.show()!

	// Plot 3: 3D visualization of quaternion path
	mut plt3 := plot.Plot.new()
	plt3.scatter3d(
		x:      x_vals
		y:      y_vals
		z:      z_vals
		mode:   'lines+markers'
		marker: plot.Marker{
			size:  []f64{len: x_vals.len, init: 3.0}
			color: []string{len: x_vals.len, init: '#0066FF'}
		}
		line:   plot.Line{
			color: '#0066FF'
			width: 2.0
		}
		name:   'Quaternion Path (x-y-z components)'
	)

	plt3.layout(
		title: 'Quaternion Signal 3D Path'
	)
	plt3.show()!

	println('\nPlots displayed!')
	println('Plot 1: Quaternion components over time (time domain)')
	println('Plot 2: Signal magnitude')
	println('Plot 3: 3D path of quaternion vector components')
	println('\nNote: For actual FFT, use vsl.fft module on quaternion components separately.')
}
