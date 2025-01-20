module noise

import rand
import vsl.float.float64

fn setup_generator() !Generator {
	rand.seed([u32(3155200429), u32(3208395956)])
	mut gen := Generator.new()
	gen.randomize()
	return gen
}

fn test_perlin_2d() {
	gen := setup_generator()!
	result := gen.perlin_2d(0.125, 0.125)
	expected := 0.4948387311305851
	assert float64.tolerance(result, expected, 1.0e-6)
}

fn test_perlin_3d() {
	gen := setup_generator()!
	result := gen.perlin_3d(0.125, 0.125, 0.125)
	expected := 0.3713334855776509
	assert float64.tolerance(result, expected, 1.0e-6)
}
