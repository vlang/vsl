module noise

import math
import rand

// implemented according to the example implementation on wikipedia
// https://en.wikipedia.org/wiki/Perlin_noise#Implementation

struct Vec2 {
	x f32
	y f32
}

[inline]
fn random_gradient() ?Vec2 {
	nr := rand.f32_in_range(0.0, math.pi * 2)?
	return Vec2{
		x: math.cosf(nr)
		y: math.sinf(nr)
	}
}

[inline]
fn interpolate(a f32, b f32, w f32) f32 {
	return ((a - b) * w) + a
}

[inline]
fn dot(ix int, iy int, x f32, y f32) ?f32 {
	vec := random_gradient()?
	dx := x - f32(ix)
	dy := y - f32(iy)
	return dx * vec.x + dy * vec.y
}

// gets the noise value at coordinate (x, y)
[inline]
pub fn perlin(x f32, y f32) ?f32 {
	x1 := int(math.floor(x))
	y1 := int(math.floor(y))
	x2 := x1 + 1
	y2 := y1 + 1

	sx := x - f32(x1)
	sy := y - f32(y2)

	n0 := dot(x1, y1, x, y)?
	n1 := dot(x2, y1, x, y)?
	first := interpolate(n0, n1, sx)

	n2 := dot(x1, y2, x, y)?
	n3 := dot(x2, y2, x, y)?
	second := interpolate(n2, n3, sx)

	return interpolate(first, second, sy)
}

// creates a 2d array of perlin noise of size `w` times `h`
pub fn perlin_many(w int, h int) ?[][]f32 {
	mut res := [][]f32{len: h, init: []f32{len: w}}
	for i, a in res {
		for j, _ in a {
			val := perlin(j, i)?
			res[i][j] = val
		}
	}
	return res
}
