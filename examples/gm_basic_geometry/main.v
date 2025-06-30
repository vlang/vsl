module main

import vsl.gm
import math

fn main() {
	println('🎯 VSL Geometry Module (gm) - Basic Examples')
	println('═'.repeat(50))

	// Example 1: Creating and working with 3D points
	println('\n📍 Example 1: 3D Points and Distances')
	println('-'.repeat(40))

	p1 := gm.Point.new(0.0, 0.0, 0.0) // Origin
	p2 := gm.Point.new(1.0, 1.0, 1.0) // Unit cube corner
	p3 := gm.Point.new(2.0, 0.0, 0.0) // Point on X-axis
	p4 := gm.Point.new(0.0, 3.0, 4.0) // Classic 3-4-5 triangle point

	println('Point 1 (Origin): ${p1}')
	println('Point 2 (Unit cube): ${p2}')
	println('Point 3 (X-axis): ${p3}')
	println('Point 4 (3-4-5): ${p4}')

	// Calculate distances between points
	d12 := gm.dist_point_point(p1, p2)
	d13 := gm.dist_point_point(p1, p3)
	d14 := gm.dist_point_point(p1, p4)

	println('\nDistances from origin:')
	println('  → Unit cube corner: ${d12:.4f} (should be √3 ≈ ${math.sqrt(3):.4f})')
	println('  → X-axis point: ${d13:.4f}')
	println('  → 3-4-5 point: ${d14:.4f} (should be 5.0)')

	// Example 2: Working with segments
	println('\n📏 Example 2: Segments and Vectors')
	println('-'.repeat(40))

	seg1 := gm.Segment.new(p1, p2)
	seg2 := gm.Segment.new(p2, p3)
	seg3 := gm.Segment.new(p1, p4)

	println('Segment 1: ${seg1}')
	println('Segment 2: ${seg2}')
	println('Segment 3: ${seg3}')

	// Example 3: Vector operations
	println('\n🔢 Example 3: Vector Mathematics')
	println('-'.repeat(40))

	v1 := seg1.vector(1.0) // Unit vector from origin to unit cube
	v2 := seg3.vector(1.0) // Vector from origin to 3-4-5 point

	println('Vector 1: [${v1[0]:.2f}, ${v1[1]:.2f}, ${v1[2]:.2f}]')
	println('Vector 2: [${v2[0]:.2f}, ${v2[1]:.2f}, ${v2[2]:.2f}]')

	// Dot product
	dot_product := gm.vector_dot(v1, v2)
	println('Dot product v1·v2: ${dot_product:.4f}')

	// Vector norms
	norm1 := gm.vector_norm(v1)
	norm2 := gm.vector_norm(v2)
	println('|v1| = ${norm1:.4f}')
	println('|v2| = ${norm2:.4f}')

	// Angle between vectors (using dot product formula)
	cos_angle := dot_product / (norm1 * norm2)
	angle_rad := math.acos(cos_angle)
	angle_deg := angle_rad * 180.0 / math.pi
	println('Angle between vectors: ${angle_deg:.2f}°')

	// Example 4: Vector arithmetic
	println('\n➕ Example 4: Vector Addition and Scaling')
	println('-'.repeat(40))

	v3 := gm.vector_add(1.0, v1, 2.0, v2) // v1 + 2*v2
	println('v1 + 2*v2 = [${v3[0]:.2f}, ${v3[1]:.2f}, ${v3[2]:.2f}]')

	v4 := gm.vector_new(0.5, v2) // Scale v2 by 0.5
	println('0.5 * v2 = [${v4[0]:.2f}, ${v4[1]:.2f}, ${v4[2]:.2f}]')

	// Example 5: Point displacement
	println('\n🚀 Example 5: Point Displacement')
	println('-'.repeat(40))

	p5 := p1.disp(1.0, 2.0, 3.0) // Move origin by (1,2,3)
	p6 := p2.clone() // Clone a point

	println('Original origin: ${p1}')
	println('Displaced origin: ${p5}')
	println('Cloned unit cube point: ${p6}')

	// Example 6: Scaled segments
	println('\n📐 Example 6: Scaled Segments')
	println('-'.repeat(40))

	seg_half := seg1.scaled(0.5) // Half-length segment
	seg_double := seg1.scaled(2.0) // Double-length segment

	println('Original segment: ${seg1}')
	println('Half-scale: ${seg_half}')
	println('Double-scale: ${seg_double}')

	println('\n✅ Geometry basics demonstration complete!')
	println('🎯 This shows fundamental point, segment, and vector operations in 3D space')
}
