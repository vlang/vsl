module noise

import rand

pub struct Perlin {
mut:
	perm []int = (rand.shuffle_clone(permutations) or { permutations })
}

// randomize is a function that shuffle the permutation set inside the Perlin struct
// will not shuffle if rand.seed is not changed
pub fn (mut perlin Perlin) randomize() {
	perlin.perm = (rand.shuffle_clone(permutations) or { permutations })
}

// perlin2d is a function that return a single value of perlin noise for a given 2d position
pub fn (perlin Perlin) perlin2d(x f64, y f64) f64 {
	xi := int(x) & 0xFF
	yi := int(y) & 0xFF

	xf := x - int(x)
	yf := y - int(y)

	u := fade(xf)
	v := fade(yf)

	a := perlin.perm[xi] + yi
	aa := perlin.perm[a]
	ab := perlin.perm[a + 1]
	b := perlin.perm[xi + 1] + yi
	ba := perlin.perm[b]
	bb := perlin.perm[b + 1]

	x1 := lerp(grad2d(aa, xf, yf), grad2d(ba, xf - 1, yf), u)
	x2 := lerp(grad2d(ab, xf, yf - 1), grad2d(bb, xf - 1, yf - 1), u)

	return (lerp(x1, x2, v) + 1) / 2
}

fn fade(t f64) f64 {
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
}

fn grad2d(hash int, x f64, y f64) f64 {
	match hash & 0xF {
		0x0 { return x + y }
		0x1 { return -x + y }
		0x2 { return x - y }
		0x3 { return -x - y }
		0x4 { return x }
		0x5 { return -x }
		0x6 { return x }
		0x7 { return -x }
		0x8 { return y }
		0x9 { return -y }
		0xA { return y }
		0xB { return -y }
		0xC { return y + x }
		0xD { return -y }
		0xE { return y - x }
		0xF { return -y }
		else { return 0 }
	}
}

fn lerp(a f64, b f64, x f64) f64 {
	return a + x * (b - a)
}
