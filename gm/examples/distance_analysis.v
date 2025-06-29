module main

import vsl.gm
import math

fn main() {
	println('📏 VSL Geometry Module - Distance Analysis')
	println('═'.repeat(50))
	
	// Example 1: Point to line distance analysis
	println('\n🎯 Example 1: Point-to-Line Distance Analysis')
	println('-'.repeat(45))
	
	// Define a line from (0,0,0) to (10,0,0) - X-axis
	line_start := gm.Point.new(0.0, 0.0, 0.0)
	line_end := gm.Point.new(10.0, 0.0, 0.0)
	
	// Test points at various distances from the line
	test_points := [
		gm.Point.new(5.0, 0.0, 0.0),    // On the line
		gm.Point.new(5.0, 1.0, 0.0),    // 1 unit above
		gm.Point.new(5.0, 0.0, 2.0),    // 2 units in Z direction
		gm.Point.new(5.0, 3.0, 4.0),    // 3-4-5 triangle (distance = 5)
		gm.Point.new(15.0, 2.0, 0.0),   // Beyond line end
		gm.Point.new(-2.0, 1.0, 0.0),   // Before line start
	]
	
	descriptions := [
		'On the line',
		'1 unit perpendicular',
		'2 units in Z',
		'3-4-5 triangle',
		'Beyond line end',
		'Before line start',
	]
	
	println('Line: ${line_start} → ${line_end}')
	println('Testing point-to-line distances:')
	
	for i, point in test_points {
		distance := gm.dist_point_line(point, line_start, line_end, 1e-10)
		println('  ${descriptions[i]:18} ${point} → distance: ${distance:.4f}')
	}
	
	// Example 2: Geometric shapes analysis
	println('\n🔺 Example 2: Triangle Analysis')
	println('-'.repeat(35))
	
	// Create a triangle in 3D space
	triangle_a := gm.Point.new(0.0, 0.0, 0.0)
	triangle_b := gm.Point.new(4.0, 0.0, 0.0)
	triangle_c := gm.Point.new(2.0, 3.0, 0.0)
	
	// Calculate side lengths
	side_ab := gm.dist_point_point(triangle_a, triangle_b)
	side_bc := gm.dist_point_point(triangle_b, triangle_c)
	side_ca := gm.dist_point_point(triangle_c, triangle_a)
	
	println('Triangle vertices:')
	println('  A: ${triangle_a}')
	println('  B: ${triangle_b}')
	println('  C: ${triangle_c}')
	println('Side lengths:')
	println('  AB: ${side_ab:.4f}')
	println('  BC: ${side_bc:.4f}')
	println('  CA: ${side_ca:.4f}')
	
	// Calculate triangle perimeter and check triangle type
	perimeter := side_ab + side_bc + side_ca
	println('Perimeter: ${perimeter:.4f}')
	
	// Check if it's a right triangle (Pythagorean theorem)
	sides := [side_ab, side_bc, side_ca]
	mut sorted_sides := sides.clone()
	sorted_sides.sort()
	
	hypotenuse_sq := sorted_sides[2] * sorted_sides[2]
	other_sides_sq := sorted_sides[0] * sorted_sides[0] + sorted_sides[1] * sorted_sides[1]
	
	if math.abs(hypotenuse_sq - other_sides_sq) < 0.0001 {
		println('Triangle type: Right triangle ✓')
	} else {
		println('Triangle type: Not a right triangle')
	}
	
	// Example 3: Circle and sphere analysis
	println('\n⭕ Example 3: Circle Analysis in 3D')
	println('-'.repeat(35))
	
	center := gm.Point.new(5.0, 5.0, 5.0)
	radius := 3.0
	
	// Test points to see if they're inside, on, or outside the sphere
	test_sphere_points := [
		gm.Point.new(5.0, 5.0, 5.0),    // Center
		gm.Point.new(8.0, 5.0, 5.0),    // On surface (radius = 3)
		gm.Point.new(5.0, 7.0, 5.0),    // Inside (distance = 2)
		gm.Point.new(5.0, 5.0, 9.5),    // Outside (distance = 4.5)
		gm.Point.new(2.0, 2.0, 2.0),    // Outside (corner)
	]
	
	sphere_descriptions := [
		'Center point',
		'On surface',
		'Inside sphere',
		'Outside sphere',
		'Corner point',
	]
	
	println('Sphere center: ${center}, radius: ${radius}')
	println('Point analysis:')
	
	for i, point in test_sphere_points {
		distance := gm.dist_point_point(center, point)
		mut status := ''
		if distance < radius - 0.0001 {
			status = 'INSIDE'
		} else if distance > radius + 0.0001 {
			status = 'OUTSIDE'
		} else {
			status = 'ON SURFACE'
		}
		println('  ${sphere_descriptions[i]:15} ${point} → distance: ${distance:.4f} (${status})')
	}
	
	// Example 4: Centroid calculation
	println('\n📐 Example 4: Centroid Calculation')
	println('-'.repeat(35))
	
	// Calculate centroid of multiple points
	cloud_points := [
		gm.Point.new(1.0, 2.0, 3.0),
		gm.Point.new(4.0, 5.0, 6.0),
		gm.Point.new(7.0, 8.0, 9.0),
		gm.Point.new(2.0, 3.0, 1.0),
		gm.Point.new(5.0, 1.0, 4.0),
	]
	
	mut sum_x := 0.0
	mut sum_y := 0.0
	mut sum_z := 0.0
	
	println('Point cloud:')
	for i, point in cloud_points {
		println('  Point ${i + 1}: ${point}')
		sum_x += point.x
		sum_y += point.y
		sum_z += point.z
	}
	
	centroid := gm.Point.new(sum_x / cloud_points.len, sum_y / cloud_points.len, sum_z / cloud_points.len)
	println('Centroid: ${centroid}')
	
	// Calculate distances from each point to centroid
	println('Distances from centroid:')
	for i, point in cloud_points {
		distance := gm.dist_point_point(point, centroid)
		println('  Point ${i + 1}: ${distance:.4f}')
	}
	
	println('\n✅ Distance analysis complete!')
	println('🎯 This demonstrates various geometric distance calculations and shape analysis')
}
