module noise

import math

const f2 = 0.5 * (math.sqrt(3.0) - 1.0)
const g2 = (3.0 - math.sqrt(3)) / 6.0

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
