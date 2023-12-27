module noise

import math { abs }
import rand

const single_perlin = f64(0.4948387311305851)

fn test_perlin2d() {
	rand.seed([u32(3155200429), u32(3208395956)])
	mut gen := noise.Perlin{}
	gen.randomize()

	assert abs(gen.perlin2d(0.125, 0.125) - single_perlin) < 1.0e-6
}