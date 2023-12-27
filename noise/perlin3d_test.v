module noise

import math { abs }
import rand

const single_perlin_3d = f64(0.3713334855776509)

fn test_perlin3d() {
	rand.seed([u32(3155200429), u32(3208395956)])
	mut gen := noise.Perlin{}
	gen.randomize()

	assert abs(gen.perlin3d(0.125, 0.125, 0.125) - single_perlin_3d) < 1.0e-6
}
