module noise

import math { abs }
import rand

const single_perlin = f32(0.507784553)

const square_perlin = [
	[0.500000000,  0.504999951, 0.509999224],
	[0.495004925, 0.500004925, 0.505004826],
	[0.490038810, 0.495038569, 0.500038804],
]

fn test_perlin2d() {
	rand.seed([u32(114764230), 293925637])

	// Test single point
	assert abs(noise.perlin2d(0.125, 0.125) - single_perlin) < 1.0e-6

	// Test 3x3 grid
	for i in 0..3 {
		for j in 0..3 {
			ii := i*0.01
			jj := j*0.01
			assert abs(noise.perlin2d(f32(ii), f32(jj)) - square_perlin[i][j]) < 1.0e-6
		}
	}
}