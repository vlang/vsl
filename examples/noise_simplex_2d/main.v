module main

import rand
import vsl.noise
import vsl.plot

fn main() {
	// Creation of the noise generator.
	// Other noise functions and dimensions count are available.
	rand.seed([u32(3155200429), u32(3208395956)])
	mut generator := noise.Generator.new()
	generator.randomize()

	mut x := []f64{cap: 1600}
	mut y := []f64{cap: 1600}
	mut z := []f64{cap: 1600}

	for xx in 0 .. 40 {
		for yy in 0 .. 40 {
			// We need to scale the coordinates to control the frequency of the noise.
			val := generator.simplex_2d(0.03 * xx, 0.03 * yy)
			x << xx
			y << yy
			z << val
		}
	}

	mut plt := plot.Plot.new()
	plt.heatmap(
		x: x
		y: y
		z: z
	)
	plt.layout(
		title: 'Simplex noise 2d example'
	)
	plt.show()!
}
