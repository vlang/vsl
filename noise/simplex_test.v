module noise

import rand
import vsl.float.float64

fn test_simplex_1d() {
	rand.seed([u32(3155200429), u32(3208395956)])
	mut generator := Generator.new()
	generator.randomize()
	result := generator.simplex_1d(0.287)
	expected := -0.3544283326507284
	assert float64.tolerance(result, expected, 1.0e-6), 'result: ${result} | expected: ${expected}'
}

fn test_simplex_2d() {
	rand.seed([u32(3075200429), u32(3094395956)])
	mut generator := Generator.new()
	generator.randomize()
	result := generator.simplex_2d(0.287, 0.475)
	expected := -0.536372951514375
	assert float64.tolerance(result, expected, 1.0e-6), 'result: ${result} | expected: ${expected}'
}

fn test_simplex_3d() {
	rand.seed([u32(3155200429), u32(3208395956)])
	mut generator := Generator.new()
	generator.randomize()
	result := generator.simplex_3d(0.287, 0.475, 1.917)
	expected := 0.5077722448079138
	assert float64.tolerance(result, expected, 1.0e-6), 'result: ${result} | expected: ${expected}'
}

fn test_simplex_4d() {
	rand.seed([u32(3075200429), u32(3094395956)])
	mut generator := Generator.new()
	generator.randomize()
	result := generator.simplex_4d(0.287, 0.475, 1.917, 0.684)
	expected := -0.07732601450154215
	assert float64.tolerance(result, expected, 1.0e-6), 'result: ${result} | expected: ${expected}'
}
