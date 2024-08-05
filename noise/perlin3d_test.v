module noise

import rand
import vsl.float.float64

fn test_perlin3d() {
	rand.seed([u32(3155200429), u32(3208395956)])

	mut gen := Generator.new()
	gen.randomize()

	result := gen.perlin3d(0.125, 0.125, 0.125)
	expected := 0.3713334855776509

	assert float64.tolerance(result, expected, 1.0e-6)
}
