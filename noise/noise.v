module noise

import rand

// Generator is a struct holding the permutation table used in perlin and simplex noise
pub struct Generator {
mut:
	perm []int = rand.shuffle_clone(permutations) or { panic(err) }
}

// new is a function that return a new Generator struct
pub fn Generator.new() Generator {
	return Generator{}
}

// randomize is a function that shuffle the permutation set inside the Generator struct
pub fn (mut gen Generator) randomize() {
	gen.perm = rand.shuffle_clone(permutations) or { panic(err) }
}
