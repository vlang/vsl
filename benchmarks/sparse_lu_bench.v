module main

import math
import os
import time
import vsl.la

const system_size = 256
const warmup_runs = 2
const timed_samples = 7

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
	for index in 0 .. left.len {
		result = math.max(result, math.abs(left[index] - right[index]))
	}
	return result
}

fn true_residual_norm(matrix &la.CSRMatrix[f64], solution []f64, rhs []f64) !f64 {
	product := matrix.matvec(solution)!
	mut norm_squared := 0.0
	for index in 0 .. rhs.len {
		residual := product[index] - rhs[index]
		norm_squared += residual * residual
	}
	return math.sqrt(norm_squared)
}

fn validate_solution(matrix &la.CSRMatrix[f64], solution []f64, rhs []f64, expected []f64) {
	residual_norm := true_residual_norm(matrix, solution, rhs) or { panic(err) }
	if max_abs_difference(solution, expected) > 1e-10 || residual_norm > 1e-10 {
		panic('sparse LU benchmark solution failed validation')
	}
}

fn validate_solve(matrix &la.CSRMatrix[f64], factor &la.SparseLU, rhs []f64, expected []f64) {
	solution := factor.solve(rhs) or { panic(err) }
	validate_solution(matrix, solution, rhs, expected)
}

fn main() {
	mut entries := la.Triplet.new[f64](system_size, system_size, 3 * system_size - 2)
	mut expected := []f64{len: system_size}
	for row in 0 .. system_size {
		expected[row] = f64(row % 11 - 5) / 5.0
		if row > 0 {
			entries.put(row, row - 1, -1.0) or { panic(err) }
		}
		entries.put(row, row, 4.0) or { panic(err) }
		if row + 1 < system_size {
			entries.put(row, row + 1, -1.0) or { panic(err) }
		}
	}
	matrix := entries.to_csr() or { panic(err) }
	rhs := matrix.matvec(expected) or { panic(err) }
	mut second_expected := []f64{len: system_size}
	for index in 0 .. system_size {
		second_expected[index] = 2.0 * expected[index]
	}
	second_rhs := matrix.matvec(second_expected) or { panic(err) }
	factor := matrix.factorize_lu() or { panic(err) }
	validate_solve(matrix, factor, rhs, expected)
	validate_solve(matrix, factor, second_rhs, second_expected)

	mut factorization_samples := []f64{cap: timed_samples}
	for _ in 0 .. warmup_runs {
		matrix.factorize_lu() or { panic(err) }
	}
	for _ in 0 .. timed_samples {
		started := time.sys_mono_now()
		matrix.factorize_lu() or { panic(err) }
		factorization_samples << f64(time.sys_mono_now() - started) / 1e3
	}

	mut solve_samples := []f64{cap: timed_samples}
	for _ in 0 .. warmup_runs {
		validate_solve(matrix, factor, rhs, expected)
		validate_solve(matrix, factor, second_rhs, second_expected)
	}
	for sample in 0 .. timed_samples {
		current_rhs := if sample % 2 == 0 { rhs } else { second_rhs }
		current_expected := if sample % 2 == 0 { expected } else { second_expected }
		started := time.sys_mono_now()
		solution := factor.solve(current_rhs) or { panic(err) }
		elapsed := f64(time.sys_mono_now() - started) / 1e3
		solve_samples << elapsed
		validate_solution(matrix, solution, current_rhs, current_expected)
	}
	factorization_samples.sort()
	solve_samples.sort()

	println('# cpu=${cpu_model()}, threads=1, n=${system_size}, tridiagonal f64 CSR')
	println('# warmups=${warmup_runs}, samples=${timed_samples}')
	println('# solve reuses one factor across two right-hand sides')
	println('operation,median_us,min_us,max_us')
	factorization_median := factorization_samples[timed_samples / 2]
	factorization_min := factorization_samples[0]
	factorization_max := factorization_samples[timed_samples - 1]
	solve_median := solve_samples[timed_samples / 2]
	solve_min := solve_samples[0]
	solve_max := solve_samples[timed_samples - 1]
	factorization_values := '${factorization_median:.3f},${factorization_min:.3f},' +
		'${factorization_max:.3f}'
	println('factorization,${factorization_values}')
	println('solve,${solve_median:.3f},${solve_min:.3f},${solve_max:.3f}')
}
