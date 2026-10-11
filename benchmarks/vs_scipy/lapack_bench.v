module main

import math
import time
import vsl.lapack

const warmup_count = 2
const iteration_count = 5

fn main() {
	$if vsl_lapack_lapacke ? {
		println('VSL LAPACK comparison | LAPACKE | f64 | median of 5')
	} $else {
		println('VSL LAPACK comparison | pure V | f64 | median of 5')
	}
	for n in [64, 128, 256] {
		general_row_major := make_general_matrix(n, false)
		qr_input := make_qr_matrix(n)
		symmetric := make_symmetric_matrix(n)
		rhs := make_rhs(n)
		benchmark_case('dgesv', n, general_row_major, rhs)
		benchmark_case('dgetrf', n, general_row_major, [])
		benchmark_case('dpotrf', n, symmetric, [])
		benchmark_case('dgeqrf', n, qr_input, [])
	}
}

fn benchmark_case(operation string, n int, input []f64, rhs []f64) {
	for _ in 0 .. warmup_count {
		_ = execute(operation, n, input, rhs)
	}
	mut samples := []f64{cap: iteration_count}
	mut checksum := f64(0)
	for _ in 0 .. iteration_count {
		started := time.sys_mono_now()
		checksum = execute(operation, n, input, rhs)
		samples << f64(time.sys_mono_now() - started) / 1_000_000.0
	}
	samples.sort()
	println('${operation} ${n}x${n} | median ${samples[iteration_count / 2]:.3} ms | checksum ${checksum:.12}')
}

fn execute(operation string, n int, input []f64, rhs []f64) f64 {
	mut a := input.clone()
	match operation {
		'dgesv' {
			mut b := rhs.clone()
			mut pivots := []int{len: n}
			info := lapack.dgesv(n, 1, mut a, n, mut pivots, mut b, 1)
			if info != 0 {
				panic('dgesv returned ${info}')
			}
			return sum_values(b)
		}
		'dgetrf' {
			mut pivots := []int{len: n}
			info := lapack.dgetrf(n, n, mut a, n, mut pivots)
			if info != 0 {
				panic('dgetrf returned ${info}')
			}
			return diagonal_sum(a, n)
		}
		'dpotrf' {
			info := lapack.dpotrf(.lower, n, mut a, n)
			if info != 0 {
				panic('dpotrf returned ${info}')
			}
			return diagonal_sum(a, n)
		}
		'dgeqrf' {
			mut tau := []f64{len: n}
			info := lapack.dgeqrf(n, n, mut a, n, mut tau)
			if info != 0 {
				panic('dgeqrf returned ${info}')
			}
			return diagonal_sum(a, n) + sum_values(tau)
		}
		else {
			panic('unsupported LAPACK operation ${operation}')
		}
	}
}

fn make_general_matrix(n int, column_major bool) []f64 {
	mut values := []f64{len: n * n}
	for row in 0 .. n {
		for col in 0 .. n {
			mut value := f64((row * 13 + col * 17 + 3) % 29 - 14) / f64(4 * n)
			if row == col {
				value += f64(n) + 2.0
			}
			index := if column_major { col * n + row } else { row * n + col }
			values[index] = value
		}
	}
	return values
}

fn make_qr_matrix(n int) []f64 {
	$if vsl_lapack_lapacke ? {
		return make_general_matrix(n, false)
	} $else {
		return make_general_matrix(n, true)
	}
}

fn make_symmetric_matrix(n int) []f64 {
	mut values := []f64{len: n * n}
	for row in 0 .. n {
		for col in 0 .. n {
			low := math.min(row, col)
			high := math.max(row, col)
			mut value := f64((low * 13 + high * 17 + 3) % 29 - 14) / f64(4 * n)
			if row == col {
				value = f64(n) + 2.0 + f64(row) * 0.25
			}
			values[row * n + col] = value
		}
	}
	return values
}

fn make_rhs(n int) []f64 {
	mut values := []f64{len: n}
	for i in 0 .. n {
		values[i] = f64(i % 17 - 8) / 8.0
	}
	return values
}

fn diagonal_sum(values []f64, n int) f64 {
	mut result := f64(0)
	for i in 0 .. n {
		result += values[i * n + i]
	}
	return result
}

fn sum_values(values []f64) f64 {
	mut result := f64(0)
	for value in values {
		result += value
	}
	return result
}
