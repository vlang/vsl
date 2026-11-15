module main

import math
import os
import time
import vsl.la

const system_size = 128
const solver_tolerance = 1e-8
const solver_max_iterations = 4 * system_size
const gmres_restart = 20
const warmup_runs = 2
const timed_samples = 5

fn cpu_model() string {
	cpuinfo := os.read_file('/proc/cpuinfo') or { return 'unavailable; record externally' }
	for line in cpuinfo.split_into_lines() {
		if line.starts_with('model name') {
			parts := line.split(':')
			if parts.len > 1 {
				return parts[1].trim_space()
			}
		}
	}
	return 'unavailable; record externally'
}

fn max_abs_difference(left []f64, right []f64) f64 {
	mut result := 0.0
	for i in 0 .. left.len {
		result = math.max(result, math.abs(left[i] - right[i]))
	}
	return result
}

fn benchmark_cg(name string, matrix &la.CSRMatrix[f64], rhs []f64, expected []f64, preconditioned bool) {
	for _ in 0 .. warmup_runs {
		result := if preconditioned {
			matrix.preconditioned_conjugate_gradient(rhs, solver_tolerance,
				solver_max_iterations) or { panic(err) }
		} else {
			matrix.conjugate_gradient(rhs, solver_tolerance, solver_max_iterations) or {
				panic(err)
			}
		}
		if !result.converged || max_abs_difference(result.x, expected) > 1e-4 {
			panic('${name} warmup failed to converge to the reference solution')
		}
	}

	mut samples := []f64{cap: timed_samples}
	mut iterations := 0
	mut residual_norm := 0.0
	mut checksum := 0.0
	for _ in 0 .. timed_samples {
		started := time.sys_mono_now()
		result := if preconditioned {
			matrix.preconditioned_conjugate_gradient(rhs, solver_tolerance,
				solver_max_iterations) or { panic(err) }
		} else {
			matrix.conjugate_gradient(rhs, solver_tolerance, solver_max_iterations) or {
				panic(err)
			}
		}
		samples << f64(time.sys_mono_now() - started) / 1e3
		if !result.converged || max_abs_difference(result.x, expected) > 1e-4 {
			panic('${name} timed solve failed to converge to the reference solution')
		}
		iterations = result.iterations
		residual_norm = result.residual_norm
		checksum += result.x[system_size / 2]
	}
	samples.sort()
	println('${name},${iterations},${residual_norm:.6e},${samples[timed_samples / 2]:.3f},${samples[0]:.3f},${samples[timed_samples - 1]:.3f},${checksum:.8f}')
}

fn benchmark_gmres(name string, matrix &la.CSRMatrix[f64], rhs []f64, expected []f64, preconditioned bool) {
	for _ in 0 .. warmup_runs {
		result := if preconditioned {
			matrix.preconditioned_gmres(rhs, solver_tolerance, solver_max_iterations,
				gmres_restart) or { panic(err) }
		} else {
			matrix.gmres(rhs, solver_tolerance, solver_max_iterations, gmres_restart) or {
				panic(err)
			}
		}
		if !result.converged || max_abs_difference(result.x, expected) > 1e-4 {
			panic('${name} warmup failed to converge to the reference solution')
		}
	}

	mut samples := []f64{cap: timed_samples}
	mut iterations := 0
	mut residual_norm := 0.0
	mut checksum := 0.0
	for _ in 0 .. timed_samples {
		started := time.sys_mono_now()
		result := if preconditioned {
			matrix.preconditioned_gmres(rhs, solver_tolerance, solver_max_iterations,
				gmres_restart) or { panic(err) }
		} else {
			matrix.gmres(rhs, solver_tolerance, solver_max_iterations, gmres_restart) or {
				panic(err)
			}
		}
		samples << f64(time.sys_mono_now() - started) / 1e3
		if !result.converged || max_abs_difference(result.x, expected) > 1e-4 {
			panic('${name} timed solve failed to converge to the reference solution')
		}
		iterations = result.iterations
		residual_norm = result.residual_norm
		checksum += result.x[system_size / 2]
	}
	samples.sort()
	println('${name},${iterations},${residual_norm:.6e},${samples[timed_samples / 2]:.3f},${samples[0]:.3f},${samples[timed_samples - 1]:.3f},${checksum:.8f}')
}

fn benchmark_bicgstab(name string, matrix &la.CSRMatrix[f64], rhs []f64, expected []f64, preconditioned bool) {
	for _ in 0 .. warmup_runs {
		result := if preconditioned {
			matrix.preconditioned_bicgstab(rhs, solver_tolerance, solver_max_iterations) or {
				panic(err)
			}
		} else {
			matrix.bicgstab(rhs, solver_tolerance, solver_max_iterations) or { panic(err) }
		}
		if !result.converged || max_abs_difference(result.x, expected) > 1e-4 {
			panic('${name} warmup failed to converge to the reference solution')
		}
	}

	mut samples := []f64{cap: timed_samples}
	mut iterations := 0
	mut residual_norm := 0.0
	mut checksum := 0.0
	for _ in 0 .. timed_samples {
		started := time.sys_mono_now()
		result := if preconditioned {
			matrix.preconditioned_bicgstab(rhs, solver_tolerance, solver_max_iterations) or {
				panic(err)
			}
		} else {
			matrix.bicgstab(rhs, solver_tolerance, solver_max_iterations) or { panic(err) }
		}
		samples << f64(time.sys_mono_now() - started) / 1e3
		if !result.converged || max_abs_difference(result.x, expected) > 1e-4 {
			panic('${name} timed solve failed to converge to the reference solution')
		}
		iterations = result.iterations
		residual_norm = result.residual_norm
		checksum += result.x[system_size / 2]
	}
	samples.sort()
	println('${name},${iterations},${residual_norm:.6e},${samples[timed_samples / 2]:.3f},${samples[0]:.3f},${samples[timed_samples - 1]:.3f},${checksum:.8f}')
}

fn main() {
	mut scale := []f64{len: system_size}
	mut expected := []f64{len: system_size}
	for row in 0 .. system_size {
		scale[row] = math.pow(10.0, 2.0 * f64(row) / f64(system_size - 1))
		expected[row] = f64(row % 13 - 6) / 7.0
	}

	mut entries := la.Triplet.new[f64](system_size, system_size, 3 * system_size)
	for row in 0 .. system_size {
		if row > 0 {
			entries.put(row, row - 1, -0.5 * math.sqrt(scale[row - 1] * scale[row])) or {
				panic(err)
			}
		}
		entries.put(row, row, 2.5 * scale[row]) or { panic(err) }
		if row + 1 < system_size {
			entries.put(row, row + 1, -0.5 * math.sqrt(scale[row] * scale[row + 1])) or {
				panic(err)
			}
		}
	}
	matrix := entries.to_csr() or { panic(err) }
	rhs := matrix.matvec(expected) or { panic(err) }

	println('# cpu=${cpu_model()}, threads=1, n=${system_size}, SPD diagonally-scaled tridiagonal')
	println('# tolerance=${solver_tolerance}, max_iterations=${solver_max_iterations}, restart=${gmres_restart}, warmups=${warmup_runs}, samples=${timed_samples}')
	println('solver,iterations,residual_norm,median_us,min_us,max_us,solution_checksum')
	benchmark_cg('cg', matrix, rhs, expected, false)
	benchmark_cg('jacobi_pcg', matrix, rhs, expected, true)
	benchmark_gmres('gmres', matrix, rhs, expected, false)
	benchmark_gmres('right_jacobi_gmres', matrix, rhs, expected, true)
	benchmark_bicgstab('bicgstab', matrix, rhs, expected, false)
	benchmark_bicgstab('right_jacobi_bicgstab', matrix, rhs, expected, true)
}
