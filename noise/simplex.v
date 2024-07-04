module noise

import math

// skewing factors for 2d case
const f2 = 0.5 * (math.sqrt(3.0) - 1.0)
const g2 = (3.0 - math.sqrt(3)) / 6.0
// skewing factors for 3d case
const f3 = f64(1.0 / 3.0)
const g3 = f64(1.0 / 6.0)

fn grad_1d(hash int, x f64) f64 {
	h := hash & 15
	mut grad := 1.0 + f64(h & 7)
	grad = if h & 8 == 0 { grad } else { -grad }
	return grad * x
}

fn grad_2d(hash int, x f64, y f64) f64 {
	h := hash & 7
	u := if h < 4 { x } else { y }
	v := if h < 4 { y } else { x }
	return (if h & 1 == 0 {
		u
	} else {
		-u
	}) + (if h & 2 == 0 {
		2.0 * v
	} else {
		-2.0 * v
	})
}

fn grad_3d(hash int, x f64, y f64, z f64) f64 {
	h := hash & 15
	u := if h < 8 { x } else { y }
	v := if h < 4 {
		y
	} else {
		if h == 12 || h == 14 { x } else { z }
	}
	return (if h & 1 == 0 {
		u
	} else {
		-u
	}) + (if h & 2 == 0 {
		v
	} else {
		-v
	})
}

fn grad_4d(hash int, x f64, y f64, z f64, t f64) f64 {
	h := hash & 31
	u := if h < 24 { x } else { y }
	v := if h < 16 { y } else { z }
	w := if h < 8 { z } else { t }
	return (if h & 1 == 0 {
		u
	} else {
		-u
	}) + (if h & 2 == 0 {
		v
	} else {
		-v
	}) + (if h & 4 == 0 {
		w
	} else {
		-w
	})
}

pub fn simplex_1d(x f64) f64 {
	i0 := int(x)
	i1 := i0 + 1
	x0 := x - i0
	x1 := x0 - 1

	mut t0 := 1.0 - x0 * x0
	t0 *= t0
	n0 := t0 * t0 * grad_1d(permutations[i0 & 0xff], x0)

	mut t1 := 1.0 - x1 * x1
	t1 *= t1
	n1 := t1 * t1 * grad_1d(permutations[i1 & 0xff], x1)

	// we scale it to [-1, 1]
	return 0.395 * (n0 + n1)
}

pub fn simplex_2d(x f64, y f64) f64 {
	// skew the input space to determine which simplex cell we're in
	s := (x + y) * noise.f2
	i := int(x + s)
	j := int(y + s)

	// unskew the cell origin back to x, y space
	t := f64(i + j) * noise.g2
	// distances from the cell origin
	x0 := x - (i - t)
	y0 := y - (j - t)

	i1, j1 := if x0 > y0 {
		// lower triangle
		1, 0
	} else {
		// upper triangle
		0, 1
	}

	x1 := x0 - f64(i1) + noise.g2
	y1 := y0 - f64(j1) + noise.g2
	x2 := x0 - 1.0 + noise.g2 * 2.0
	y2 := y0 - 1.0 + noise.g2 * 2.0

	// avoid oob
	ii := i & 0xff
	jj := j & 0xff

	// calculate the 3 corners
	mut t0 := 0.5 - x0 * x0 - y0 * y0
	mut n0 := 0.0
	if t0 < 0 {
		n0 = 0.0
	} else {
		t0 *= t0
		n0 = t0 * t0 * grad_2d(permutations[ii + permutations[jj]], x0, y0)
	}

	mut t1 := 0.5 - x1 * x1 - y1 * y1
	mut n1 := 0.0
	if t1 < 0 {
		n1 = 0.0
	} else {
		t1 *= t1
		n1 = t1 * t1 * grad_2d(permutations[ii + i1 + permutations[jj + j1]], x1, y1)
	}

	mut t2 := 0.5 - x2 * x2 - y2 * y2
	mut n2 := 0.0
	if t2 < 0 {
		n2 = 0.0
	} else {
		t2 *= t2
		n2 = t2 * t2 * grad_2d(permutations[ii + 1 + permutations[jj + 1]], x2, y2)
	}

	// scale the return value to [-1, 1]
	return 40.0 * (n0 + n1 + n2)
}

pub fn simplex_3d(x f64, y f64, z f64) f64 {
	// skew the input space to determine which simplex cell we're in
	s := (x + y + z) * f3
	xs := x + s
	ys := y + s
	zs := z + s
	i := int(xs)
	j := int(ys)
	k := int(zs)

	// unskew the cell origin back to x, y, z space
	t := f64(i + j + k) * g3
	// distances from cell origin
	x0 := x - (i - t)
	y0 := y - (j - t)
	z0 := z - (k - t)

  mut i1 := 0
  mut j1 := 0
  mut k1 := 0
	mut i2 := 0
	mut j2 := 0
	mut k2 := 0

	if x0 >= y0 {
		if y0 >= z0 {
			i1 = 1
			j1 = 0
			k1 = 0
			i2 = 1
			j2 = 1
			k2 = 0
		}
		else if x0 >= z0 {
			i1 = 1
			j1 = 0
			k1 = 0
			i2 = 1
			j2 = 0
			k2 = 1
		}
		else {
			i1 = 0
			j1 = 0
			k1 = 1
			i2 = 1
			j2 = 0
			k2 = 1
		}
	} else {
		if y0 < z0 {
			i1 = 0
			j1 = 0
			k1 = 1
			i2 = 0
			j2 = 1
			k2 = 1
		}
		else if x0 < z0 {
			i1 = 0
			j1 = 1
			k1 = 0
			i2 = 0
			j2 = 1
			k2 = 1
		}
		else {
			i1 = 0
			j1 = 1
			k1 = 0
			i2 = 1
			j2 = 1
			k2 = 0
		}
	}

	// offsets for corners in x, y, z coords
	x1 := x0 - i1 + g3
	y1 := y0 - j1 + g3
	z1 := z0 - k1 + g3
  x2 := x0 - i2 + 2.0 * g3
	y2 := y0 - j2 + 2.0 * g3
	z2 := z0 - k2 + 2.0 * g3
	x3 := x0 - 1.0 + 3.0 * g3
	y3 := y0 - 1.0 + 3.0 * g3
	z3 := z0 - 1.0 + 3.0 * g3

  ii := i & 0xff
  jj := j & 0xff
	kk := k & 0xff

	mut t0 := 0.6 - x0 * x0 - y0 * y0 - z0 * z0
	mut n0 := 0.0
  if t0 < 0 {
		n0 = 0.0
	} else {
    t0 *= t0
		n0 = t0 * t0 * grad_3d(permutations[ii + permutations[jj + permutations[kk]]], x0, y0, z0)
	}

	mut t1 := 0.6 - x1 * x1 - y1 * y1 - z1 * z1
	mut n1 := 0.0
	if t1 < 0 {
		n1 = 0.0
	} else {
		t1 *= t1
		n1 = t1 * t1 * grad_3d(permutations[ii + i1 + permutations[jj + j1 + permutations[kk + k1]]], x1, y1, z1)
	}

	mut t2 := 0.6 - x2 * x2 - y2 * y2 - z2 * z2
	mut n2 := 0.0
	if t2 < 0 {
		n2 = 0.0
	} else {
		t2 *= t2
		n2 = t2 * t2 * grad_3d(permutations[ii + i2 + permutations[jj + j2 + permutations[kk + k2]]], x2, y2, z2)
	}

	mut t3 := 0.6 - x3 * x3 - y3 * y3 - z3 * z3
	mut n3 := 0.0
	if t3 < 0 {
		n3 = 0.0
	} else {
		t3 *= t3
		n3 = t3 * t3 * grad_3d(permutations[ii + 1 + permutations[jj + 1 + permutations[kk + 1]]], x3, y3, z3)
	}

	// scale the return value to [-1, 1]
	return 32.0 * (n0 + n1 + n2 + n3)
}
