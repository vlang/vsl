module gm

import math

// Point holds the Cartesian coordinates of a point in 3D space
@[heap]
pub struct Point {
pub mut:
	x f64
	y f64
	z f64
}

// Segment represents a directed segment from a to b
@[heap]
pub struct Segment {
pub:
	a &Point = unsafe { nil }
	b &Point = unsafe { nil }
}

// Point.new creates a new point
pub fn Point.new(x f64, y f64, z f64) &Point {
	return &Point{x, y, z}
}

// clone creates a new copy of Point
pub fn (o &Point) clone() &Point {
	return &Point{o.x, o.y, o.z}
}

// disp creates a new copy of Point displaced by dx, dy, dz
pub fn (o &Point) disp(dx f64, dy f64, dz f64) &Point {
	return &Point{o.x + dx, o.y + dy, o.z + dz}
}

// str outputs Point
pub fn (o &Point) str() string {
	return '{${o.x}, ${o.y}, ${o.z}}'
}

// dist_point_point computes the unsigned distance from a to b
pub fn dist_point_point(a &Point, b &Point) f64 {
	return math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y) +
		(a.z - b.z) * (a.z - b.z))
}

// len computes the length of Segment == Euclidean norm
pub fn (o &Segment) len() f64 {
	return dist_point_point(o.a, o.b)
}

// New creates a new Segment scaled by m and starting from A
pub fn (o &Segment) scaled(m f64) &Segment {
	return Segment.new(o.a.clone(), Point.new(o.a.x + m * (o.b.x - o.a.x), o.a.y +
		m * (o.b.y - o.a.y), o.a.z + m * (o.b.z - o.a.z)))
}

// vector returns the vector representing Segment from A to B (scaled by m)
pub fn (o &Segment) vector(m f64) []f64 {
	return [m * (o.b.x - o.a.x), m * (o.b.y - o.a.y), m * (o.b.z - o.a.z)]
}

// str outputs Segment
pub fn (o &Segment) str() string {
	return '{${o.a} ${o.b}} len=${o.len()}'
}

// Segment.new creates a new segment from a to b
pub fn Segment.new(a &Point, b &Point) &Segment {
	return &Segment{a, b}
}

// vector_dot returns the dot product between two vectors
pub fn vector_dot(u []f64, v []f64) f64 {
	return u[0] * v[0] + u[1] * v[1] + u[2] * v[2]
}

// vector_norm returns the length (Euclidean norm) of a vector
pub fn vector_norm(u []f64) f64 {
	return math.sqrt(u[0] * u[0] + u[1] * u[1] + u[2] * u[2])
}

// vector_new returns a new vector scaled by m
pub fn vector_new(m f64, u []f64) []f64 {
	return [m * u[0], m * u[1], m * u[2]]
}

// vector_add returns a new vector by adding two other vectors
//  w := α*u + β*v
pub fn vector_add(alpha f64, u []f64, beta f64, v []f64) []f64 {
	return [alpha * u[0] + beta * v[0], alpha * u[1] + beta * v[1], alpha * u[2] + beta * v[2]]
}

// dist_point_line computes the distance from p to line passing through a -> b
pub fn dist_point_line(p &Point, a &Point, b &Point, tol f64) f64 {
	ns := Segment.new(a, b)
	vs := Segment.new(p, a)
	nn := ns.len()
	if nn < tol { // point-point distance
		$if debug {
			print('basicgeom.go: dist_point_line: __WARNING__ point-point distance too small:\n p=${p} a=${a} b=${b}')
		}
		return vs.len()
	}
	n := ns.vector(1.0 / nn)
	v := vs.vector(1.0)
	s := vector_dot(v, n)
	l := vector_add(1.0, v, -s, n) // l := v - dot(v,n) * n
	return vector_norm(l)
}

// points_lims returns the limits of a set of points
pub fn points_lims(pp []&Point) ([]f64, []f64) {
	if pp.len < 1 {
		return [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]
	}
	mut cmin := [pp[0].x, pp[0].y, pp[0].z]
	mut cmax := [pp[0].x, pp[0].y, pp[0].z]
	for i in 1 .. pp.len {
		if pp[i].x < cmin[0] {
			cmin[0] = pp[i].x
		}
		if pp[i].y < cmin[1] {
			cmin[1] = pp[i].y
		}
		if pp[i].z < cmin[2] {
			cmin[2] = pp[i].z
		}
		if pp[i].x > cmax[0] {
			cmax[0] = pp[i].x
		}
		if pp[i].y > cmax[1] {
			cmax[1] = pp[i].y
		}
		if pp[i].z > cmax[2] {
			cmax[2] = pp[i].z
		}
	}
	return cmin, cmax
}

// is_point_in returns whether p is inside box with cmin and cmax
pub fn is_point_in(p &Point, cmin []f64, cmax []f64, tol f64) bool {
	if p.x < cmin[0] - tol || p.x > cmax[0] + tol {
		return false
	}
	if p.y < cmin[1] - tol || p.y > cmax[1] + tol {
		return false
	}
	if p.z < cmin[2] - tol || p.z > cmax[2] + tol {
		return false
	}
	return true
}

// is_point_in_line returns whether p is inside line passing through a and b
pub fn is_point_in_line(p &Point, a &Point, b &Point, zero f64, told f64, tolin f64) bool {
	cmin, cmax := points_lims([a, b])
	d := dist_point_line(p, a, b, zero)
	if d < told && is_point_in(p, cmin, cmax, tolin) {
		return true
	}
	return false
}

// pythagorean_theorem calculates the length of the hypotenuse given the lengths of the other two sides
pub fn pythagorean_theorem(a f64, b f64) f64 {
    return math.sqrt(a * a + b * b)
}

// euclidean_theorem calculates the lengths of segments created by the altitude to the hypotenuse
pub fn euclidean_theorem(a f64, b f64, c f64) (f64, f64) {
    h := (a * b) / c
    p := (h * h) / a
    q := (h * h) / b
    return p, q
}

// triangle_area_sine calculates the area of a triangle given two sides and the angle between them
pub fn triangle_area_sine(a f64, b f64, angle_rad f64) f64 {
    return 0.5 * a * b * math.sin(angle_rad)
}

// triangle_missing_side calculates the length of the missing side of a triangle
// given two sides and the angle between them
pub fn triangle_missing_side(a f64, b f64, angle_rad f64) f64 {
    return math.sqrt(a * a + b * b - 2 * a * b * math.cos(angle_rad))
}

// triangle_area_from_points calculates the area of a triangle given its three vertices
pub fn triangle_area_from_points(p1 &Point, p2 &Point, p3 &Point) f64 {
    a := dist_point_point(p1, p2)
    b := dist_point_point(p2, p3)
    c := dist_point_point(p3, p1)
    s := (a + b + c) / 2  // semi-perimeter
    return math.sqrt(s * (s - a) * (s - b) * (s - c))
}
