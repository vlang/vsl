module main

import vsl.gm
import math
import rand

fn main() {
	println('🗂️ VSL Geometry Module - Spatial Binning System')
	println('═'.repeat(55))

	// Example 1: Basic 2D binning system
	println('\n📦 Example 1: 2D Spatial Binning')
	println('-'.repeat(35))

	// Create a 2D binning system for a 10x10 area with 5x5 bins
	xmin_2d := [0.0, 0.0]
	xmax_2d := [10.0, 10.0]
	ndiv_2d := [5, 5]

	mut bins_2d := gm.Bins.new(xmin_2d, xmax_2d, ndiv_2d)

	println('2D Binning System:')
	println('  Domain: [${xmin_2d[0]}, ${xmax_2d[0]}] × [${xmin_2d[1]}, ${xmax_2d[1]}]')
	println('  Divisions: ${ndiv_2d[0]} × ${ndiv_2d[1]} = ${ndiv_2d[0] * ndiv_2d[1]} bins')
	println('  Bin size: ${bins_2d.size[0]:.1f} × ${bins_2d.size[1]:.1f}')

	// Add some interesting 2D points
	points_2d := [
		[1.5, 2.3], // bin (0,1)
		[3.7, 4.1], // bin (1,2)
		[6.2, 1.8], // bin (3,0)
		[8.9, 7.4], // bin (4,3)
		[2.1, 8.6], // bin (1,4)
		[5.5, 5.5], // bin (2,2) - center
		[9.1, 9.8], // bin (4,4) - corner
		[0.2, 0.1], // bin (0,0) - origin corner
	]

	point_names := [
		'Point A',
		'Point B',
		'Point C',
		'Point D',
		'Point E',
		'Center',
		'Far Corner',
		'Origin Corner',
	]

	// Insert points into binning system
	for i, coords in points_2d {
		bins_2d.append(coords, i, unsafe { nil })
		bin_idx := bins_2d.calc_index(coords)
		println('  ${point_names[i]:12} (${coords[0]:4.1f}, ${coords[1]:4.1f}) → bin ${bin_idx}')
	}

	// Example 2: 3D binning for particle simulation
	println('\n🎯 Example 2: 3D Particle System')
	println('-'.repeat(35))

	// Create a 3D cube with 4x4x4 bins for particle simulation
	xmin_3d := [0.0, 0.0, 0.0]
	xmax_3d := [8.0, 8.0, 8.0]
	ndiv_3d := [4, 4, 4]

	mut bins_3d := gm.Bins.new(xmin_3d, xmax_3d, ndiv_3d)

	println('3D Particle Binning System:')
	println('  Domain: ${xmin_3d[0]}×${xmin_3d[1]}×${xmin_3d[2]} to ${xmax_3d[0]}×${xmax_3d[1]}×${xmax_3d[2]}')
	println('  Divisions: ${ndiv_3d[0]}×${ndiv_3d[1]}×${ndiv_3d[2]} = ${ndiv_3d[0] * ndiv_3d[1] * ndiv_3d[2]} bins')
	println('  Bin size: ${bins_3d.size[0]}×${bins_3d.size[1]}×${bins_3d.size[2]}')

	// Generate random particles
	num_particles := 50
	mut particles := [][]f64{}

	println('\nGenerating ${num_particles} random particles...')

	for i in 0 .. num_particles {
		x := rand.f64_in_range(0.0, 8.0) or { 4.0 }
		y := rand.f64_in_range(0.0, 8.0) or { 4.0 }
		z := rand.f64_in_range(0.0, 8.0) or { 4.0 }

		particle := [x, y, z]
		particles << particle
		bins_3d.append(particle, i, unsafe { nil })
	}

	// Analyze bin occupancy
	mut bin_counts := map[int]int{}
	for particle in particles {
		bin_idx := bins_3d.calc_index(particle)
		bin_counts[bin_idx] = bin_counts[bin_idx] + 1
	}

	println('Bin occupancy analysis:')
	mut total_occupied_bins := 0
	mut max_particles := 0
	mut min_particles := num_particles

	for _, count in bin_counts {
		if count > 0 {
			total_occupied_bins++
			if count > max_particles {
				max_particles = count
			}
			if count < min_particles {
				min_particles = count
			}
		}
	}

	println('  Total bins: ${ndiv_3d[0] * ndiv_3d[1] * ndiv_3d[2]}')
	println('  Occupied bins: ${total_occupied_bins}')
	println('  Empty bins: ${ndiv_3d[0] * ndiv_3d[1] * ndiv_3d[2] - total_occupied_bins}')
	println('  Max particles per bin: ${max_particles}')
	println('  Min particles per bin: ${min_particles}')
	println('  Average particles per occupied bin: ${f64(num_particles) / f64(total_occupied_bins):.2f}')

	// Example 3: Spatial search demonstration
	println('\n🔍 Example 3: Spatial Search Simulation')
	println('-'.repeat(40))

	// Find particles near a specific location
	search_center := [4.0, 4.0, 4.0] // Center of the cube
	search_radius := 2.0

	println('Searching for particles near ${search_center} within radius ${search_radius}')

	// Get the bin index for the search center
	center_bin := bins_3d.calc_index(search_center)
	println('Search center is in bin ${center_bin}')

	// Find all particles within search radius (brute force for demonstration)
	mut nearby_particles := []int{}
	for i, particle in particles {
		distance := math.sqrt((particle[0] - search_center[0]) * (particle[0] - search_center[0]) +
			(particle[1] - search_center[1]) * (particle[1] - search_center[1]) +
			(particle[2] - search_center[2]) * (particle[2] - search_center[2]))

		if distance <= search_radius {
			nearby_particles << i
		}
	}

	println('Found ${nearby_particles.len} particles within search radius:')
	for particle_id in nearby_particles {
		particle := particles[particle_id]
		distance := math.sqrt((particle[0] - search_center[0]) * (particle[0] - search_center[0]) +
			(particle[1] - search_center[1]) * (particle[1] - search_center[1]) +
			(particle[2] - search_center[2]) * (particle[2] - search_center[2]))
		bin_idx := bins_3d.calc_index(particle)
		println('  Particle ${particle_id:2}: (${particle[0]:5.2f}, ${particle[1]:5.2f}, ${particle[2]:5.2f}) distance: ${distance:.3f}, bin: ${bin_idx}')
	}

	// Example 4: Performance analysis
	println('\n⚡ Example 4: Performance Analysis')
	println('-'.repeat(35))

	// Create larger systems to compare
	large_size := 100
	large_particles := 1000

	xmin_large := [0.0, 0.0, 0.0]
	xmax_large := [f64(large_size), f64(large_size), f64(large_size)]
	ndiv_large := [10, 10, 10] // 1000 bins

	mut bins_large := gm.Bins.new(xmin_large, xmax_large, ndiv_large)

	println('Large-scale binning system:')
	println('  Domain: ${large_size}×${large_size}×${large_size}')
	println('  Bins: ${ndiv_large[0]}×${ndiv_large[1]}×${ndiv_large[2]} = ${ndiv_large[0] * ndiv_large[1] * ndiv_large[2]}')
	println('  Particles: ${large_particles}')
	println('  Bin volume: ${bins_large.size[0] * bins_large.size[1] * bins_large.size[2]:.1f}')
	println('  Expected particles per bin: ${f64(large_particles) / f64(ndiv_large[0] * ndiv_large[1] * ndiv_large[2]):.2f}')

	// Theoretical performance improvement
	brute_force_comparisons := large_particles * (large_particles - 1) / 2
	binned_comparisons := large_particles * f64(large_particles) / f64(ndiv_large[0] * ndiv_large[1] * ndiv_large[2])

	println('\nTheoretical performance (for neighbor search):')
	println('  Brute force comparisons: ${brute_force_comparisons}')
	println('  Binned approach comparisons: ${binned_comparisons:.0f}')
	println('  Performance improvement: ${f64(brute_force_comparisons) / binned_comparisons:.1f}x faster')

	println('\n✅ Spatial binning demonstration complete!')
	println('🎯 This shows efficient spatial organization for fast neighbor searches')
	println('💡 Perfect for particle simulations, collision detection, and spatial queries')
}
