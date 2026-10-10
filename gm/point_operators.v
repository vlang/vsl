module gm

// Point addition combines Cartesian coordinates component-wise.
pub fn (a &Point) + (b &Point) &Point {
	return &Point{
		x: a.x + b.x
		y: a.y + b.y
		z: a.z + b.z
	}
}

// Point subtraction computes the component-wise displacement from b to a.
pub fn (a &Point) - (b &Point) &Point {
	return &Point{
		x: a.x - b.x
		y: a.y - b.y
		z: a.z - b.z
	}
}
