module main

import vsl.gm
import math

fn main() {
	println('🔬 VSL Geometry Module - Advanced Geometric Analysis')
	println('═'.repeat(60))

	// Example 1: Point cloud analysis and clustering
	println('\n☁️ Example 1: Point Cloud Analysis')
	println('-'.repeat(35))

	// Generate multiple clusters of points
	cluster1_center := gm.Point.new(2.0, 2.0, 0.0)
	cluster2_center := gm.Point.new(8.0, 3.0, 0.0)
	cluster3_center := gm.Point.new(5.0, 8.0, 0.0)

	mut point_cloud := []gm.Point{}

	// Generate points around cluster 1
	cluster1_points := [
		gm.Point.new(1.5, 1.8, 0.2),
		gm.Point.new(2.3, 2.1, -0.1),
		gm.Point.new(1.9, 2.4, 0.3),
		gm.Point.new(2.1, 1.7, -0.2),
	]

	// Generate points around cluster 2
	cluster2_points := [
		gm.Point.new(7.8, 2.9, 0.1),
		gm.Point.new(8.2, 3.2, -0.3),
		gm.Point.new(7.9, 3.1, 0.2),
		gm.Point.new(8.1, 2.8, 0.0),
	]

	// Generate points around cluster 3
	cluster3_points := [
		gm.Point.new(4.9, 7.8, 0.1),
		gm.Point.new(5.1, 8.2, -0.1),
		gm.Point.new(4.8, 8.1, 0.2),
		gm.Point.new(5.2, 7.9, -0.2),
	]

	// Add points to combined cloud
	for pt in cluster1_points {
		point_cloud << pt
	}
	for pt in cluster2_points {
		point_cloud << pt
	}
	for pt in cluster3_points {
		point_cloud << pt
	}

	println('Point cloud with ${point_cloud.len} points in 3 clusters:')

	// Analyze distances to cluster centers
	cluster_centers := [cluster1_center, cluster2_center, cluster3_center]
	cluster_names := ['Cluster 1', 'Cluster 2', 'Cluster 3']

	for i, center in cluster_centers {
		println('\n${cluster_names[i]} (center: ${center}):')
		mut total_distance := 0.0
		mut count := 0

		for point in point_cloud {
			distance := gm.dist_point_point(point, center)
			if distance < 2.0 { // Points within 2 units are considered part of this cluster
				println('  ${point} → distance: ${distance:.3f}')
				total_distance += distance
				count++
			}
		}

		if count > 0 {
			avg_distance := total_distance / f64(count)
			println('  Average distance from center: ${avg_distance:.3f}')
			println('  Points in cluster: ${count}')
		}
	}

	// Example 2: Bounding box and convex hull analysis
	println('\n📦 Example 2: Bounding Box Analysis')
	println('-'.repeat(35))

	// Calculate bounding box for the point cloud
	min_coords, max_coords := gm.points_lims(point_cloud.map(&it))

	bounding_box_volume := (max_coords[0] - min_coords[0]) * (max_coords[1] - min_coords[1]) * (max_coords[2] - min_coords[2])

	println('Point cloud bounding box:')
	println('  Min coordinates: [${min_coords[0]:.2f}, ${min_coords[1]:.2f}, ${min_coords[2]:.2f}]')
	println('  Max coordinates: [${max_coords[0]:.2f}, ${max_coords[1]:.2f}, ${max_coords[2]:.2f}]')
	println('  Dimensions: ${max_coords[0] - min_coords[0]:.2f} × ${max_coords[1] - min_coords[1]:.2f} × ${max_coords[2] - min_coords[2]:.2f}')
	println('  Volume: ${bounding_box_volume:.3f}')

	// Test point containment
	test_points_containment := [
		gm.Point.new(3.0, 4.0, 0.0), // Inside
		gm.Point.new(0.0, 0.0, 0.0), // Outside
		gm.Point.new(9.0, 9.0, 0.0), // Outside
		gm.Point.new(5.0, 5.0, 0.1), // Inside
	]

	println('\nPoint containment test:')
	for point in test_points_containment {
		is_inside := gm.is_point_in(point, min_coords, max_coords, 0.001)
		status := if is_inside { 'INSIDE' } else { 'OUTSIDE' }
		println('  ${point} → ${status}')
	}

	// Example 3: Line intersection and geometry
	println('\n📏 Example 3: Line Geometry Analysis')
	println('-'.repeat(35))

	// Define several lines in 3D space
	line1_start := gm.Point.new(0.0, 0.0, 0.0)
	line1_end := gm.Point.new(10.0, 0.0, 0.0) // X-axis line

	line2_start := gm.Point.new(0.0, 0.0, 0.0)
	line2_end := gm.Point.new(0.0, 10.0, 0.0) // Y-axis line

	line3_start := gm.Point.new(5.0, -2.0, 0.0)
	line3_end := gm.Point.new(5.0, 12.0, 0.0) // Vertical line through x=5

	lines := [
		gm.Segment.new(line1_start, line1_end),
		gm.Segment.new(line2_start, line2_end),
		gm.Segment.new(line3_start, line3_end),
	]
	line_names := ['X-axis line', 'Y-axis line', 'Vertical line x=5']

	println('Line definitions:')
	for i, seg in lines {
		name := line_names[i]

		println('  ${name}: ${seg.a} → ${seg.b} (length: ${seg.len():.2f})')
	}

	// Test points for line distance calculations
	test_points_lines := [
		gm.Point.new(5.0, 1.0, 0.0), // Near X-axis line
		gm.Point.new(1.0, 5.0, 0.0), // Near Y-axis line
		gm.Point.new(5.0, 5.0, 0.0), // On vertical line
		gm.Point.new(3.0, 3.0, 2.0), // Above all lines
	]

	println('\nPoint-to-line distance analysis:')
	for i, test_point in test_points_lines {
		println('  Test point ${i + 1}: ${test_point}')

		for j, seg in lines {
			name := line_names[j]

			distance := gm.dist_point_line(test_point, seg.a, seg.b, 1e-10)
			println('    → ${name}: ${distance:.3f}')
		}
		println('')
	}

	// Example 4: Point-in-line detection
	println('\n🎯 Example 4: Point-Line Alignment Detection')
	println('-'.repeat(45))

	// Test if points lie on lines
	candidate_points := [
		gm.Point.new(3.0, 0.0, 0.0), // Should be on X-axis
		gm.Point.new(0.0, 7.0, 0.0), // Should be on Y-axis
		gm.Point.new(5.0, 6.0, 0.0), // Should be on vertical line
		gm.Point.new(2.0, 2.0, 0.0), // Not on any line
		gm.Point.new(5.0, 0.0, 0.1), // Close to X-axis but slightly off
	]

	tolerance_distance := 0.1
	tolerance_inline := 0.1
	zero_threshold := 1e-10

	println('Testing point-line alignment (tolerance: ${tolerance_distance}):')

	for i, point in candidate_points {
		println('  Point ${i + 1}: ${point}')

		for j, seg in lines {
			name := line_names[j]

			is_on_line := gm.is_point_in_line(point, seg.a, seg.b, zero_threshold, tolerance_distance,
				tolerance_inline)

			status := if is_on_line { '✓ ON LINE' } else { '✗ off line' }
			distance := gm.dist_point_line(point, seg.a, seg.b, zero_threshold)

			println('    ${name}: ${status} (dist: ${distance:.3f})')
		}
		println('')
	}

	// Example 5: Vector field analysis
	println('\n🧭 Example 5: Vector Field Analysis')
	println('-'.repeat(35))

	// Create a simple vector field (like a flow field)
	field_points := [
		gm.Point.new(0.0, 0.0, 0.0),
		gm.Point.new(2.0, 0.0, 0.0),
		gm.Point.new(4.0, 0.0, 0.0),
		gm.Point.new(0.0, 2.0, 0.0),
		gm.Point.new(2.0, 2.0, 0.0),
		gm.Point.new(4.0, 2.0, 0.0),
	]

	// Define vectors at each point (simple radial field)
	center_point := gm.Point.new(2.0, 1.0, 0.0)

	println('Vector field analysis (radial field from ${center_point}):')

	for point in field_points {
		// Calculate vector from center to point
		direction_vector := [point.x - center_point.x, point.y - center_point.y, point.z - center_point.z]
		magnitude := gm.vector_norm(direction_vector)

		// Normalize the vector
		mut unit_vector := []f64{}
		if magnitude > 0.001 {
			unit_vector = gm.vector_new(1.0 / magnitude, direction_vector)
		} else {
			unit_vector = [0.0, 0.0, 0.0]
		}

		println('  At ${point}:')
		println('    Direction: [${unit_vector[0]:6.3f}, ${unit_vector[1]:6.3f}, ${unit_vector[2]:6.3f}]')
		println('    Magnitude: ${magnitude:6.3f}')

		// Calculate angle from horizontal
		if magnitude > 0.001 {
			angle := math.atan2(unit_vector[1], unit_vector[0]) * 180.0 / math.pi
			println('    Angle: ${angle:6.1f}°')
		}
		println('')
	}

	// Calculate field divergence (simplified)
	println('Vector field properties:')
	mut total_divergence := 0.0
	for point in field_points {
		distance := gm.dist_point_point(point, center_point)
		if distance > 0.001 {
			// Simple divergence approximation (1/r for radial field)
			divergence := 1.0 / distance
			total_divergence += divergence
		}
	}
	avg_divergence := total_divergence / f64(field_points.len)
	println('  Average divergence: ${avg_divergence:.3f}')

	println('\n✅ Advanced geometric analysis complete!')
	println('🎯 This demonstrates point cloud analysis, bounding boxes, line geometry,')
	println('   alignment detection, and vector field analysis')
}
