module main

import vsl.gm
import math

fn main() {
	println('🎮 VSL Geometry Module - Interactive Geometry Playground')
	println('═'.repeat(60))

	// Interactive demonstration of various geometric concepts

	// Demo 1: Geometric transformations
	println('\n🔄 Demo 1: Geometric Transformations')
	println('-'.repeat(40))

	original_shape := create_cube_vertices(2.0)
	println('Original cube vertices (side length 2.0):')
	for i, vertex in original_shape {
		println('  Vertex ${i + 1}: ${vertex}')
	}

	// Translation
	translated_shape := transform_translate(original_shape, 3.0, 2.0, 1.0)
	println('\nAfter translation (+3, +2, +1):')
	for i, vertex in translated_shape {
		println('  Vertex ${i + 1}: ${vertex}')
	}

	// Scaling
	scaled_shape := transform_scale(original_shape, 1.5)
	println('\nAfter scaling (×1.5):')
	for i, vertex in scaled_shape {
		println('  Vertex ${i + 1}: ${vertex}')
	}

	// Demo 2: Collision detection
	println('\n💥 Demo 2: Sphere Collision Detection')
	println('-'.repeat(40))

	spheres := [
		Sphere{gm.Point.new(0.0, 0.0, 0.0), 2.0}, // Sphere at origin
		Sphere{gm.Point.new(3.0, 0.0, 0.0), 1.5}, // Nearby sphere
		Sphere{gm.Point.new(10.0, 0.0, 0.0), 1.0}, // Distant sphere
		Sphere{gm.Point.new(1.0, 1.0, 0.0), 1.0}, // Overlapping sphere
	]

	println('Collision detection between spheres:')
	for i in 0 .. spheres.len {
		for j in i + 1 .. spheres.len {
			collision_result := detect_sphere_collision(spheres[i], spheres[j])
			status := if collision_result.colliding { '💥 COLLISION' } else { '✅ No collision' }
			println('  Sphere ${i + 1} vs Sphere ${j + 1}: ${status}')
			println('    Distance: ${collision_result.distance:.3f}, Overlap: ${collision_result.overlap:.3f}')
		}
	}

	// Demo 3: Path finding and optimization
	println('\n🗺️ Demo 3: Path Finding Algorithms')
	println('-'.repeat(35))

	// Create a simple maze-like environment with obstacles
	obstacles := [
		gm.Point.new(3.0, 2.0, 0.0),
		gm.Point.new(3.0, 3.0, 0.0),
		gm.Point.new(3.0, 4.0, 0.0),
		gm.Point.new(6.0, 1.0, 0.0),
		gm.Point.new(6.0, 2.0, 0.0),
	]

	start_point := gm.Point.new(0.0, 0.0, 0.0)
	goal_point := gm.Point.new(8.0, 5.0, 0.0)

	println('Pathfinding from ${start_point} to ${goal_point}')
	println('Obstacles at:')
	for i, obstacle in obstacles {
		println('  Obstacle ${i + 1}: ${obstacle}')
	}

	// Simple A* inspired path (simplified for demonstration)
	path := find_simple_path(start_point, goal_point, obstacles)

	println('Calculated path:')
	mut total_path_length := 0.0
	for i, waypoint in path {
		if i > 0 {
			seg := gm.Segment.new(path[i - 1], waypoint)
			segment_length := seg.len()
			total_path_length += segment_length
			println('  Step ${i}: ${waypoint} (segment: ${segment_length:.2f})')
		} else {
			println('  Start: ${waypoint}')
		}
	}

	direct_distance := gm.dist_point_point(start_point, goal_point)
	efficiency := direct_distance / total_path_length

	println('Path analysis:')
	println('  Total path length: ${total_path_length:.2f}')
	println('  Direct distance: ${direct_distance:.2f}')
	println('  Path efficiency: ${efficiency:.3f} (1.0 = optimal)')

	// Demo 4: Geometric puzzle solver
	println('\n🧩 Demo 4: Triangle Puzzle Solver')
	println('-'.repeat(35))

	// Given three sides, find the triangle properties
	triangle_sides := [
		[3.0, 4.0, 5.0], // Right triangle
		[5.0, 5.0, 5.0], // Equilateral triangle
		[3.0, 7.0, 9.0], // Scalene triangle
		[2.0, 2.0, 4.0], // Degenerate triangle
	]

	for i, sides in triangle_sides {
		println('Triangle ${i + 1} with sides [${sides[0]}, ${sides[1]}, ${sides[2]}]:')
		triangle_analysis := analyze_triangle(sides[0], sides[1], sides[2])

		println('  Type: ${triangle_analysis.type}')
		println('  Valid: ${triangle_analysis.valid}')
		if triangle_analysis.valid {
			println('  Area: ${triangle_analysis.area:.3f}')
			println('  Perimeter: ${triangle_analysis.perimeter:.3f}')
			println('  Angles: [${triangle_analysis.angles[0]:.1f}°, ${triangle_analysis.angles[1]:.1f}°, ${triangle_analysis.angles[2]:.1f}°]')
		}
		println('')
	}

	// Demo 5: Physics simulation preview
	println('\n⚡ Demo 5: Physics Simulation Preview')
	println('-'.repeat(40))

	// Simulate bouncing ball physics
	ball_position := gm.Point.new(0.0, 0.0, 10.0)
	ball_velocity := [5.0, 3.0, 0.0]
	gravity := -9.81
	ground_level := 0.0
	damping := 0.8 // Energy loss on bounce
	dt := 0.1

	println('Bouncing ball simulation:')
	println('Initial: ${ball_position}, velocity: [${ball_velocity[0]}, ${ball_velocity[1]}, ${ball_velocity[2]}]')

	mut current_pos := [ball_position.x, ball_position.y, ball_position.z]
	mut current_vel := ball_velocity.clone()
	mut time := 0.0
	mut bounces := 0

	for time < 5.0 && bounces < 5 {
		time += dt

		// Update velocity with gravity
		current_vel[2] += gravity * dt

		// Update position
		current_pos[0] += current_vel[0] * dt
		current_pos[1] += current_vel[1] * dt
		current_pos[2] += current_vel[2] * dt

		// Check for ground collision
		if current_pos[2] <= ground_level && current_vel[2] < 0 {
			current_pos[2] = ground_level
			current_vel[2] = -current_vel[2] * damping // Bounce with damping
			bounces++

			pos_point := gm.Point.new(current_pos[0], current_pos[1], current_pos[2])
			println('  Bounce ${bounces} at t=${time:.2f}s: ${pos_point}, vel=[${current_vel[0]:.2f}, ${current_vel[1]:.2f}, ${current_vel[2]:.2f}]')
		}
	}

	final_pos := gm.Point.new(current_pos[0], current_pos[1], current_pos[2])
	println('Final position: ${final_pos}')

	// Demo 6: Fractal geometry preview
	println('\n🌿 Demo 6: Fractal Geometry Preview')
	println('-'.repeat(35))

	// Generate points for a simple 2D fractal (Sierpinski triangle approximation)
	fractal_points := generate_sierpinski_points(5, 1.0)

	println('Sierpinski triangle approximation (${fractal_points.len} points):')
	for i, point in fractal_points {
		if i < 10 { // Show first 10 points
			println('  Point ${i + 1}: ${point}')
		} else if i == 10 {
			println('  ... and ${fractal_points.len - 10} more points')
			break
		}
	}

	// Analyze fractal properties
	min_coords, max_coords := gm.points_lims(fractal_points.map(&it))
	fractal_width := max_coords[0] - min_coords[0]
	fractal_height := max_coords[1] - min_coords[1]

	println('Fractal bounding box: ${fractal_width:.3f} × ${fractal_height:.3f}')

	println('\n🎯 Interactive geometry playground complete!')
	println('💡 This demonstrates transformations, collision detection, pathfinding,')
	println('   triangle analysis, physics simulation, and fractal generation')
}

// Helper structures and functions

struct Sphere {
	center gm.Point
	radius f64
}

struct CollisionResult {
	colliding bool
	distance  f64
	overlap   f64
}

struct TriangleAnalysis {
	valid     bool
	type      string
	area      f64
	perimeter f64
	angles    [3]f64
}

fn create_cube_vertices(size f64) []&gm.Point {
	half := size / 2.0
	return [
		gm.Point.new(-half, -half, -half), // Bottom face
		gm.Point.new(half, -half, -half),
		gm.Point.new(half, half, -half),
		gm.Point.new(-half, half, -half),
		gm.Point.new(-half, -half, half), // Top face
		gm.Point.new(half, -half, half),
		gm.Point.new(half, half, half),
		gm.Point.new(-half, half, half),
	]
}

fn transform_translate(points []&gm.Point, dx f64, dy f64, dz f64) []&gm.Point {
	return points.map(it.disp(dx, dy, dz))
}

fn transform_scale(points []&gm.Point, factor f64) []&gm.Point {
	return points.map(gm.Point.new(it.x * factor, it.y * factor, it.z * factor))
}

fn detect_sphere_collision(s1 Sphere, s2 Sphere) CollisionResult {
	distance := gm.dist_point_point(s1.center, s2.center)
	sum_radii := s1.radius + s2.radius
	colliding := distance < sum_radii
	overlap := if colliding { sum_radii - distance } else { 0.0 }

	return CollisionResult{colliding, distance, overlap}
}

fn find_simple_path(start &gm.Point, goal &gm.Point, obstacles []&gm.Point) []&gm.Point {
	// Simplified pathfinding: try direct path, if blocked add waypoints
	mut path := [start]

	// Check if direct path is clear
	is_clear := check_path_clear(start, goal, obstacles, 1.0)

	if is_clear {
		path << goal
	} else {
		// Add intermediate waypoints to avoid obstacles
		intermediate := gm.Point.new((start.x + goal.x) / 2.0, goal.y + 2.0, start.z)
		path << intermediate
		path << goal
	}

	return path
}

fn check_path_clear(start &gm.Point, end &gm.Point, obstacles []&gm.Point, clearance f64) bool {
	for obstacle in obstacles {
		distance := gm.dist_point_line(obstacle, start, end, 1e-10)
		if distance < clearance {
			return false
		}
	}
	return true
}

fn analyze_triangle(a f64, b f64, c f64) TriangleAnalysis {
	perimeter := a + b + c

	// Check triangle inequality
	valid := a + b > c && a + c > b && b + c > a

	if !valid {
		return TriangleAnalysis{false, 'Invalid', 0.0, perimeter, [0.0, 0.0, 0.0]!}
	}

	// Calculate area using Heron's formula
	s := perimeter / 2.0
	area := math.sqrt(s * (s - a) * (s - b) * (s - c))

	// Calculate angles using law of cosines
	angle_a := math.acos((b * b + c * c - a * a) / (2.0 * b * c)) * 180.0 / math.pi
	angle_b := math.acos((a * a + c * c - b * b) / (2.0 * a * c)) * 180.0 / math.pi
	angle_c := 180.0 - angle_a - angle_b

	// Determine triangle type
	mut triangle_type := 'Scalene'
	if math.abs(a - b) < 0.001 && math.abs(b - c) < 0.001 {
		triangle_type = 'Equilateral'
	} else if math.abs(a - b) < 0.001 || math.abs(b - c) < 0.001 || math.abs(a - c) < 0.001 {
		triangle_type = 'Isosceles'
	}

	// Check if right triangle
	sides := [a, b, c]
	mut sorted_sides := sides.clone()
	sorted_sides.sort()
	hyp_sq := sorted_sides[2] * sorted_sides[2]
	other_sq := sorted_sides[0] * sorted_sides[0] + sorted_sides[1] * sorted_sides[1]

	if math.abs(hyp_sq - other_sq) < 0.001 {
		triangle_type += ' Right'
	}

	return TriangleAnalysis{valid, triangle_type, area, perimeter, [angle_a, angle_b, angle_c]!}
}

fn generate_sierpinski_points(iterations int, size f64) []gm.Point {
	mut points := []gm.Point{}

	// Start with the three vertices of an equilateral triangle
	vertices := [
		gm.Point.new(0.0, 0.0, 0.0),
		gm.Point.new(size, 0.0, 0.0),
		gm.Point.new(size / 2.0, size * math.sqrt(3.0) / 2.0, 0.0),
	]

	// Start at a random point
	mut current := gm.Point.new(size / 4.0, size / 4.0, 0.0)

	for i in 0 .. (1 << iterations) { // 2^iterations points
		// Pick a random vertex
		vertex_idx := i % 3
		target := vertices[vertex_idx]

		// Move halfway towards the target
		current = gm.Point.new((current.x + target.x) / 2.0, (current.y + target.y) / 2.0,
			(current.z + target.z) / 2.0)

		points << current
	}

	return points
}
