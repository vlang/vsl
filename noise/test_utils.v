module noise

import rand

fn setup_generator() !Generator {
	rand.seed([u32(3155200429), u32(3208395956)])
	mut gen := Generator.new()
	gen.randomize()
	return gen
}
