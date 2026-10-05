module noise

fn setup_generator() Generator {
	mut gen := Generator.new()
	gen.perm = permutations.clone()
	return gen
}
