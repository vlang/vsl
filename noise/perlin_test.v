module noise

import math { abs }
import rand

const single_perlin = f32(0.9920886)

const square_perlin = [
	[f32(0.9920886), -0.9148169],
	[f32(0.4479326), 0.7049548],
]

fn test_perlin() {
	rand.seed([u32(114764230), 293925637])

	x := perlin(0.0, 0.0)!
	println(' x is ${x:11.9}')
	assert abs(x - noise.single_perlin) < 1.0e-6
}

fn test_perlin_many() {
	rand.seed([u32(114764230), 293925637])
	y := perlin_many(2, 2)!

	println(' y is ${y:13.11}')
	for i, _ in y {
		for j, _ in y[i] {
			assert y[i][j] - noise.square_perlin[i][j] < 1.0e-6
		}
	}
}
