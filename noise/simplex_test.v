module noise

import vsl.float.float64

fn test_simplex_1d() {
	gen := setup_generator()
	result := gen.simplex_1d(0.287)
	expected := 0.6265919368243218
	assert float64.tolerance(result, expected, 1.0e-6)
}

fn test_simplex_2d() {
	gen := setup_generator()
	result := gen.simplex_2d(0.287, 0.475)
	expected := -0.5129587127209102
	assert float64.tolerance(result, expected, 1.0e-6)
}

fn test_simplex_3d() {
	gen := setup_generator()
	result := gen.simplex_3d(0.287, 0.475, 1.917)
	expected := 0.04713919454998936
	assert float64.tolerance(result, expected, 1.0e-6)
}

fn test_simplex_4d() {
	gen := setup_generator()
	result := gen.simplex_4d(0.287, 0.475, 1.917, 0.684)
	expected := -0.04864075883031525
	assert float64.tolerance(result, expected, 1.0e-6)
}
