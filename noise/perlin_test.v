module noise

import rand

fn test_perlin() {
	rand.seed([u32(1), 0])
	assert noise.perlin(0.0, 0.0) or { assert false } == -0.6457864046096802
}

fn test_perlin_many() {
	rand.seed([u32(1), 0])
	assert noise.perlin_many(2, 2) or { assert false } == [
		[f32(-0.6457864046096802), 0.0279612485319376], 
		[f32(0.2286834865808487), -0.5146363377571106]
	]
}