module main

import vsl.gm
import math

fn main() {
	println('🚀 VSL Geometry Module - 3D Trajectory Simulation')
	println('═'.repeat(55))
	
	// Example 1: Projectile motion in 3D
	println('\n🎯 Example 1: Projectile Motion Analysis')
	println('-'.repeat(40))
	
	// Initial conditions
	launch_point := gm.Point.new(0.0, 0.0, 10.0)  // Launch from 10m height
	initial_velocity := [20.0, 15.0, 25.0]        // m/s in x, y, z directions
	gravity := [0.0, 0.0, -9.81]                  // Gravity acceleration
	dt := 0.1                                     // Time step (seconds)
	
	println('🚀 Launch conditions:')
	println('  Position: ${launch_point}')
	println('  Velocity: [${initial_velocity[0]:.1f}, ${initial_velocity[1]:.1f}, ${initial_velocity[2]:.1f}] m/s')
	println('  Gravity: [${gravity[0]:.2f}, ${gravity[1]:.2f}, ${gravity[2]:.2f}] m/s²')
	
	mut trajectory_points := [launch_point]
	mut current_pos := [launch_point.x, launch_point.y, launch_point.z]
	mut current_vel := initial_velocity.clone()
	mut time := 0.0
	mut max_height := launch_point.z
	mut max_height_time := 0.0
	
	// Simulate trajectory until ground impact
	for current_pos[2] > 0.0 && time < 20.0 {  // Stop at ground or max time
		time += dt
		
		// Update velocity (v = v0 + a*t)
		current_vel[0] += gravity[0] * dt
		current_vel[1] += gravity[1] * dt
		current_vel[2] += gravity[2] * dt
		
		// Update position (x = x0 + v*t)
		current_pos[0] += current_vel[0] * dt
		current_pos[1] += current_vel[1] * dt
		current_pos[2] += current_vel[2] * dt
		
		// Track maximum height
		if current_pos[2] > max_height {
			max_height = current_pos[2]
			max_height_time = time
		}
		
		// Add point to trajectory (every 0.5 seconds for display)
		if int(time * 10) % 5 == 0 {
			trajectory_points << gm.Point.new(current_pos[0], current_pos[1], current_pos[2])
		}
	}
	
	landing_point := gm.Point.new(current_pos[0], current_pos[1], 0.0)
	total_distance := gm.dist_point_point(launch_point, landing_point)
	flight_time := time
	
	println('\n📊 Trajectory Results:')
	println('  Flight time: ${flight_time:.2f} seconds')
	println('  Landing point: (${landing_point.x:.2f}, ${landing_point.y:.2f}, ${landing_point.z:.2f})')
	println('  Total horizontal distance: ${total_distance:.2f} meters')
	println('  Maximum height: ${max_height:.2f} meters at t=${max_height_time:.2f}s')
	
	println('\n🛤️ Trajectory points (every 0.5s):')
	for i, point in trajectory_points {
		t := f64(i) * 0.5
		println('  t=${t:4.1f}s: ${point}')
	}
	
	// Example 2: Orbital mechanics simulation
	println('\n🌍 Example 2: Circular Orbit Simulation')
	println('-'.repeat(40))
	
	// Simulate a simple circular orbit around origin
	orbit_center := gm.Point.new(0.0, 0.0, 0.0)
	orbit_radius := 50.0
	angular_velocity := 0.1  // rad/s
	orbit_time := 2.0 * math.pi / angular_velocity  // One complete orbit
	
	println('🛰️ Orbital parameters:')
	println('  Center: ${orbit_center}')
	println('  Radius: ${orbit_radius:.1f} units')
	println('  Angular velocity: ${angular_velocity:.3f} rad/s')
	println('  Orbital period: ${orbit_time:.2f} seconds')
	
	mut orbit_points := []gm.Point{}
	num_orbit_points := 16  // 16 points around the orbit
	
	for i in 0 .. num_orbit_points {
		angle := f64(i) * 2.0 * math.pi / f64(num_orbit_points)
		x := orbit_radius * math.cos(angle)
		y := orbit_radius * math.sin(angle)
		z := 0.0  // Circular orbit in xy-plane
		
		orbit_points << gm.Point.new(x, y, z)
	}
	
	println('\n🎯 Orbital trajectory points:')
	for i, point in orbit_points {
		angle := f64(i) * 360.0 / f64(num_orbit_points)
		distance := gm.dist_point_point(orbit_center, point)
		println('  ${angle:5.1f}°: ${point} (r=${distance:.2f})')
	}
	
	// Calculate orbital velocity at each point
	println('\n⚡ Orbital velocities:')
	for i in 0 .. orbit_points.len {
		next_i := (i + 1) % orbit_points.len
		
		seg := gm.Segment.new(orbit_points[i], orbit_points[next_i])
		chord_length := seg.len()
		
		// Approximate tangential velocity
		dt_orbit := orbit_time / f64(num_orbit_points)
		velocity := chord_length / dt_orbit
		
		angle := f64(i) * 360.0 / f64(num_orbit_points)
		println('  ${angle:5.1f}°: velocity ≈ ${velocity:.2f} units/s')
	}
	
	// Example 3: Spiral trajectory
	println('\n🌀 Example 3: 3D Spiral Trajectory')
	println('-'.repeat(35))
	
	// Create a 3D spiral (helix)
	spiral_radius := 10.0
	spiral_pitch := 2.0     // Height increase per revolution
	spiral_revolutions := 3.0
	spiral_points_per_rev := 20
	
	println('🌪️ Spiral parameters:')
	println('  Radius: ${spiral_radius:.1f} units')
	println('  Pitch: ${spiral_pitch:.1f} units per revolution')
	println('  Revolutions: ${spiral_revolutions:.1f}')
	
	mut spiral_points := []gm.Point{}
	total_spiral_points := int(spiral_revolutions * f64(spiral_points_per_rev))
	
	for i in 0 .. total_spiral_points {
		angle := f64(i) * 2.0 * math.pi / f64(spiral_points_per_rev)
		x := spiral_radius * math.cos(angle)
		y := spiral_radius * math.sin(angle)
		z := f64(i) * spiral_pitch / f64(spiral_points_per_rev)
		
		spiral_points << gm.Point.new(x, y, z)
	}
	
	// Analyze spiral properties
	mut spiral_length := 0.0
	for i in 1 .. spiral_points.len {
		segment := gm.Segment.new(spiral_points[i-1], spiral_points[i])
		spiral_length += segment.len()
	}
	
	spiral_start := spiral_points[0]
	spiral_end := spiral_points[spiral_points.len - 1]
	direct_distance := gm.dist_point_point(spiral_start, spiral_end)
	
	println('\n📐 Spiral analysis:')
	println('  Total arc length: ${spiral_length:.2f} units')
	println('  Direct distance: ${direct_distance:.2f} units')
	println('  Efficiency ratio: ${direct_distance / spiral_length:.3f}')
	println('  Start point: ${spiral_start}')
	println('  End point: ${spiral_end}')
	
	// Show some key points along the spiral
	println('\n🎯 Key spiral points:')
	key_indices := [0, total_spiral_points / 4, total_spiral_points / 2, 
	                total_spiral_points * 3 / 4, total_spiral_points - 1]
	key_names := ['Start', 'Quarter', 'Half', 'Three-quarter', 'End']
	
	for i, idx in key_indices {
		if idx < spiral_points.len {
			point := spiral_points[idx]
			revolutions := f64(idx) / f64(spiral_points_per_rev)
			println('  ${key_names[i]:12}: ${point} (${revolutions:.2f} rev)')
		}
	}
	
	// Example 4: Path analysis and optimization
	println('\n📈 Example 4: Path Analysis')
	println('-'.repeat(30))
	
	// Compare different paths between two points
	start := gm.Point.new(0.0, 0.0, 0.0)
	goal := gm.Point.new(10.0, 8.0, 6.0)
	
	// Path 1: Direct line
	direct_path := gm.Segment.new(start, goal)
	direct_length := direct_path.len()
	
	// Path 2: Via waypoint (detour)
	waypoint := gm.Point.new(5.0, 12.0, 3.0)
	path2_seg1 := gm.Segment.new(start, waypoint)
	path2_seg2 := gm.Segment.new(waypoint, goal)
	detour_length := path2_seg1.len() + path2_seg2.len()
	
	// Path 3: Staircase path (Manhattan distance in 3D)
	manhattan_length := math.abs(goal.x - start.x) + math.abs(goal.y - start.y) + math.abs(goal.z - start.z)
	
	println('🛣️ Path comparison from ${start} to ${goal}:')
	println('  Direct path: ${direct_length:.2f} units')
	println('  Via waypoint ${waypoint}: ${detour_length:.2f} units (${detour_length / direct_length:.2f}x longer)')
	println('  Manhattan distance: ${manhattan_length:.2f} units (${manhattan_length / direct_length:.2f}x longer)')
	
	// Calculate angles and directions
	direct_vector := direct_path.vector(1.0)
	println('\n🧭 Direction analysis:')
	println('  Direct vector: [${direct_vector[0]:.2f}, ${direct_vector[1]:.2f}, ${direct_vector[2]:.2f}]')
	
	// Convert to spherical coordinates (approximate)
	distance := vector_norm(direct_vector)
	azimuth := math.atan2(direct_vector[1], direct_vector[0]) * 180.0 / math.pi
	elevation := math.asin(direct_vector[2] / distance) * 180.0 / math.pi
	
	println('  Distance: ${distance:.2f} units')
	println('  Azimuth: ${azimuth:.1f}°')
	println('  Elevation: ${elevation:.1f}°')
	
	println('\n✅ Trajectory simulation complete!')
	println('🎯 This demonstrates 3D motion analysis, orbital mechanics, and path optimization')
}

// Helper function for vector norm calculation
fn vector_norm(v []f64) f64 {
	return math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
}
