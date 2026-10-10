module gm

import math

fn test_point_creation_clone_displacement_and_distance() {
	a := Point.new(1.0, 2.0, 3.0)
	b := a.disp(2.0, -1.0, 2.0)
	assert a.str() == '{1.0, 2.0, 3.0}'
	assert b.x == 3.0
	assert b.y == 1.0
	assert b.z == 5.0
	assert dist_point_point(a, b) == 3.0
	assert a.clone().x == a.x
}

fn test_point_addition_and_subtraction_operators() {
	a := Point.new(1.0, 2.0, 3.0)
	b := Point.new(4.0, 6.0, 8.0)
	sum := (*a) + (*b)
	difference := (*b) - (*a)
	assert sum.x == 5.0
	assert sum.y == 8.0
	assert sum.z == 11.0
	assert difference.x == 3.0
	assert difference.y == 4.0
	assert difference.z == 5.0
	assert a.x == 1.0
	assert b.x == 4.0
}

fn test_point_scalar_multiplication_and_division() {
	a := Point.new(2.0, -4.0, 8.0)
	scaled := a.scale(0.5)
	divided := a.div_scalar(2.0)

	assert scaled.x == 1.0
	assert scaled.y == -2.0
	assert scaled.z == 4.0
	assert divided.x == 1.0
	assert divided.y == -2.0
	assert divided.z == 4.0
	assert a.x == 2.0
	assert a.y == -4.0
	assert a.z == 8.0
}

fn test_segment_length_vector_and_point_line_distance() {
	a := Point.new(0.0, 0.0, 0.0)
	b := Point.new(2.0, 0.0, 0.0)
	segment := Segment.new(a, b)
	assert segment.len() == 2.0
	assert segment.vector(0.5) == [1.0, 0.0, 0.0]
	assert math.abs(dist_point_line(Point.new(1.0, 1.0, 0.0), a, b, 1e-12) - 1.0) < 1e-12
}

fn test_point_limits_and_bounding_box_queries() {
	a := Point.new(-1.0, 2.0, 0.0)
	b := Point.new(3.0, -2.0, 4.0)
	minimum, maximum := points_lims([a, b])
	assert minimum == [-1.0, -2.0, 0.0]
	assert maximum == [3.0, 2.0, 4.0]
	empty_minimum, empty_maximum := points_lims([]&Point{})
	assert empty_minimum == [0.0, 0.0, 0.0]
	assert empty_maximum == [0.0, 0.0, 0.0]
	assert is_point_in(Point.new(0.0, 0.0, 2.0), minimum, maximum, 0.0)
	assert !is_point_in(Point.new(4.0, 0.0, 2.0), minimum, maximum, 0.0)
}
