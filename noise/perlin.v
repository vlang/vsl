module noise

import math
import rand

@[inline]
fn random_gradient() !(f32, f32) {
	nr := rand.f32_in_range(0.0, math.pi * 2) or { return err }
	return math.cosf(nr), math.sinf(nr)
}

@[inline]
fn interpolate(a f32, b f32, w f32) f32 {
	return ((a - b) * w) + a
}

@[inline]
fn dot(ix int, iy int, x f32, y f32) !f32 {
	vec_x, vec_y := random_gradient()!
	dx := x - f32(ix)
	dy := y - f32(iy)
	return dx * vec_x + dy * vec_y
}

// perlin2d is a function that returns a perlin noise value for a given x and y coordinate
pub fn perlin2d(x f32, y f32) !f32 {
	x1 := int(math.floor(x))
	y1 := int(math.floor(y))
	x2 := x1 + 1
	y2 := y1 + 1

	sx := x - f32(x1)
	sy := y - f32(y2)

	n0 := dot(x1, y1, x, y)!
	n1 := dot(x2, y1, x, y)!
	first := interpolate(n0, n1, sx)

	n2 := dot(x1, y2, x, y)!
	n3 := dot(x2, y2, x, y)!
	second := interpolate(n2, n3, sx)

	return interpolate(first, second, sy)
}

// perlin2d_space is a function that returns a 2d array of perlin noise values for a given width and height
pub fn perlin2d_space(w int, h int) ![][]f32 {
	mut res := [][]f32{len: h, init: []f32{len: w}}
	for i, a in res {
		for j, _ in a {
			val := perlin2d(j, i)!
			res[i][j] = val
		}
	}
	return res
}
