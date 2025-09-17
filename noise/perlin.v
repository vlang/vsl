module noise

// lerp is a function that return a linear interpolation value for 2 given values and a factor
@[inline]
fn lerp(a f64, b f64, x f64) f64 {
	return a + x * (b - a)
}

// fade is a function that return a fade value for a given value
@[inline]
fn fade(t f64) f64 {
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
}

// perlin_grad_2d is a function that return a gradient value for a given hash and 2d position
fn perlin_grad_2d(hash int, x f64, y f64) f64 {
	return match hash & 0xF {
		0x0 { x + y }
		0x1 { -x + y }
		0x2 { x - y }
		0x3 { -x - y }
		0x4 { x }
		0x5 { -x }
		0x6 { x }
		0x7 { -x }
		0x8 { y }
		0x9 { -y }
		0xA { y }
		0xB { -y }
		0xC { y + x }
		0xD { -y }
		0xE { y - x }
		0xF { -y }
		else { 0 }
	}
}

// perlin_grad_3d is a function that returns a single value of gradient gen for a given 3d position
fn perlin_grad_3d(hash int, x f64, y f64, z f64) f64 {
	return match hash & 0xF {
		0x0 { x + y }
		0x1 { -x + y }
		0x2 { x - y }
		0x3 { -x - y }
		0x4 { x + z }
		0x5 { -x + z }
		0x6 { x - z }
		0x7 { -x - z }
		0x8 { y + z }
		0x9 { -y + z }
		0xA { y - z }
		0xB { -y - z }
		0xC { y + x }
		0xD { -y + x }
		0xE { y - x }
		0xF { -y - x }
		else { 0 }
	}
}

// perlin_2d is a function that return a single value of perlin gen for a given 2d position
pub fn (gen Generator) perlin_2d(x f64, y f64) f64 {
	xi := int(x) & 0xFF
	yi := int(y) & 0xFF

	xf := x - int(x)
	yf := y - int(y)

	u := fade(xf)
	v := fade(yf)

	pxi := gen.perm[xi]
	pxi1 := gen.perm[xi + 1]

	aa := gen.perm[pxi + yi]
	ab := gen.perm[pxi + yi + 1]
	ba := gen.perm[pxi1 + yi]
	bb := gen.perm[pxi1 + yi + 1]

	x1 := lerp(perlin_grad_2d(aa, xf, yf), perlin_grad_2d(ba, xf - 1, yf), u)
	x2 := lerp(perlin_grad_2d(ab, xf, yf - 1), perlin_grad_2d(bb, xf - 1, yf - 1), u)

	return (lerp(x1, x2, v) + 1) / 2
}

// perlin_3d is a function that return a single value of perlin gen for a given 3d position
pub fn (gen Generator) perlin_3d(x f64, y f64, z f64) f64 {
	xi := int(x) & 0xFF
	yi := int(y) & 0xFF
	zi := int(z) & 0xFF
	xf := x - int(x)
	yf := y - int(y)
	zf := z - int(z)
	u := fade(xf)
	v := fade(yf)
	w := fade(zf)

	pxi := gen.perm[xi]
	pxi_yi := gen.perm[pxi + yi]
	pxi_yi1 := gen.perm[pxi + yi + 1]
	pxi1 := gen.perm[xi + 1]
	pxi1_yi := gen.perm[pxi1 + yi]
	pxi1_yi1 := gen.perm[pxi1 + yi + 1]

	aaa := gen.perm[pxi_yi + zi]
	aba := gen.perm[pxi_yi1 + zi]
	aab := gen.perm[pxi_yi + zi + 1]
	abb := gen.perm[pxi_yi1 + zi + 1]
	baa := gen.perm[pxi1_yi + zi]
	bba := gen.perm[pxi1_yi1 + zi]
	bab := gen.perm[pxi1_yi + zi + 1]
	bbb := gen.perm[pxi1_yi1 + zi + 1]

	mut x1 := lerp(perlin_grad_3d(aaa, xf, yf, zf), perlin_grad_3d(baa, xf - 1, yf, zf),
		u)
	mut x2 := lerp(perlin_grad_3d(aba, xf, yf - 1, zf), perlin_grad_3d(bba, xf - 1, yf - 1,
		zf), u)
	y1 := lerp(x1, x2, v)
	x1 = lerp(perlin_grad_3d(aab, xf, yf, zf - 1), perlin_grad_3d(bab, xf - 1, yf, zf - 1),
		u)
	x2 = lerp(perlin_grad_3d(abb, xf, yf - 1, zf - 1), perlin_grad_3d(bbb, xf - 1, yf - 1,
		zf - 1), u)
	y2 := lerp(x1, x2, v)

	return (lerp(y1, y2, w) + 1) / 2
}
