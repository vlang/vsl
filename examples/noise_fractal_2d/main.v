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

	mut x := []f64{}
	mut y := []f64{}
	mut z := []f64{}

	// 5 layers of simplex noise
	octaves := 5
	persistence := 0.5

	for xx in 0 .. 200 {
		for yy in 0 .. 200 {
			mut total := 0.0
			mut frequency := 1.0
			mut amplitude := 1.0
			mut max_value := 0.0

			for _ in 0 .. octaves {
				total += generator.simplex_2d(0.03 * xx * frequency, 0.03 * yy * frequency) * amplitude
				max_value += amplitude
				amplitude *= persistence
				frequency *= 2.0
			}

			// Normalize to [-1, 1]
			total /= max_value
			x << xx
			y << yy
			z << total
		}
	}

	mut plt := plot.Plot.new()
	plt.heatmap(
		x: x
		y: y
		z: z
	)
	plt.layout(
		title: 'Pink `fractal` noise 2d example'
	)
	plt.show()!
}
