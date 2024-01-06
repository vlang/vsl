module noise

import rand
import vsl.float.float64

fn test_perlin2d() {
	rand.seed([u32(3155200429), u32(3208395956)])

	mut gen := Perlin.new()
	gen.randomize()

	result := gen.perlin2d(0.125, 0.125)
	expected := 0.4948387311305851

	assert float64.tolerance(result, expected, 1.0e-6)
}
