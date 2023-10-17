module main

import math
import vsl.plot
import vsl.fft

fn main() {
	// Example data for FFT
	mut signal := []f64{len: 100, init: math.sin(0.1 * f64(index)) +
		0.5 * math.sin(0.01 * f64(index))}

	// Save a copy of the original signal
	mut original_signal := signal.clone()

	// Create an FFT plan
	mut plan := fft.create_plan(signal)?

	// Perform forward FFT
	fft.forward_fft(plan, mut signal)

	// Get the FFT spectrum
	spectrum := signal.clone()

	// Create a scatter plot for the signal and its spectrum
	mut plt := plot.Plot.new()

	// Add a scatter plot for the original signal
	plt.scatter(
		x: []f64{len: original_signal.len, init: f64(index)}
		y: original_signal
		mode: 'markers'
		marker: plot.Marker{
			size: []f64{len: original_signal.len, init: 8.0}
		}
		name: 'Original Signal'
	)

	// Add a scatter plot for the imaginary part of the spectrum
	plt.scatter(
		x: []f64{len: spectrum.len, init: f64(index)}
		y: spectrum
		mode: 'markers'
		marker: plot.Marker{
			size: []f64{len: spectrum.len, init: 8.0}
		}
		name: 'FFT Spectrum'
	)

	// Set up the layout
	plt.layout(
		title: 'Signal and FFT Spectrum'
	)

	// Show the plot
	plt.show()!
}
