module noise

import vsl.float.float64

fn test_perlin_2d() {
	gen := setup_generator()
	result := gen.perlin_2d(0.125, 0.125)
	expected := 0.5077845531050116
	assert float64.tolerance(result, expected, 1.0e-6)
	assert gen.perlin2d(0.125, 0.125) == result
}

fn test_perlin_3d() {
	gen := setup_generator()
	result := gen.perlin_3d(0.125, 0.125, 0.125)
	expected := 0.6107391600293113
	assert float64.tolerance(result, expected, 1.0e-6)
	assert gen.perlin3d(0.125, 0.125, 0.125) == result
}
