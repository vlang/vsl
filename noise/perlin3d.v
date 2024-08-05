module noise

// perlin3d is a function that return a single value of perlin noise for a given 3d position
pub fn (generator Generator) perlin3d(x f64, y f64, z f64) f64 {
	xi := int(x) & 0xFF
	yi := int(y) & 0xFF
	zi := int(z) & 0xFF
	xf := x - int(x)
	yf := y - int(y)
	zf := z - int(z)
	u := fade(xf)
	v := fade(yf)
	w := fade(zf)

	pxi := generator.perm[xi]
	pxi_yi := generator.perm[pxi + yi]
	pxi_yi1 := generator.perm[pxi + yi + 1]
	pxi1 := generator.perm[xi + 1]
	pxi1_yi := generator.perm[pxi1 + yi]
	pxi1_yi1 := generator.perm[pxi1 + yi + 1]

	aaa := generator.perm[pxi_yi + zi]
	aba := generator.perm[pxi_yi1 + zi]
	aab := generator.perm[pxi_yi + zi + 1]
	abb := generator.perm[pxi_yi1 + zi + 1]
	baa := generator.perm[pxi1_yi + zi]
	bba := generator.perm[pxi1_yi1 + zi]
	bab := generator.perm[pxi1_yi + zi + 1]
	bbb := generator.perm[pxi1_yi1 + zi + 1]

	mut x1 := lerp(grad3d(aaa, xf, yf, zf), grad3d(baa, xf - 1, yf, zf), u)
	mut x2 := lerp(grad3d(aba, xf, yf - 1, zf), grad3d(bba, xf - 1, yf - 1, zf), u)
	y1 := lerp(x1, x2, v)
	x1 = lerp(grad3d(aab, xf, yf, zf - 1), grad3d(bab, xf - 1, yf, zf - 1), u)
	x2 = lerp(grad3d(abb, xf, yf - 1, zf - 1), grad3d(bbb, xf - 1, yf - 1, zf - 1), u)
	y2 := lerp(x1, x2, v)

	return (lerp(y1, y2, w) + 1) / 2
}

// grad3d is a function that returns a single value of gradient noise for a given 3d position
fn grad3d(hash int, x f64, y f64, z f64) f64 {
	match hash & 0xF {
		0x0 { return x + y }
		0x1 { return -x + y }
		0x2 { return x - y }
		0x3 { return -x - y }
		0x4 { return x + z }
		0x5 { return -x + z }
		0x6 { return x - z }
		0x7 { return -x - z }
		0x8 { return y + z }
		0x9 { return -y + z }
		0xA { return y - z }
		0xB { return -y - z }
		0xC { return y + x }
		0xD { return -y + z }
		0xE { return y - x }
		0xF { return -y - z }
		else { return 0 }
	}
}
