module la

import math

// SparseLU is a reusable, pure-V LU factorization of a square f64 CSR matrix.
// The internal rows contain both the unit-lower multipliers and upper factor.
pub struct SparseLU {
	size int
mut:
	rows        []map[int]f64
	permutation []int
}

// factorize_lu computes a partial-pivoted LU factorization without converting
// the matrix to dense storage. It returns an error for nonsquare or malformed
// CSR input, non-finite values, singular pivots, or non-finite elimination
// results. Singularity is determined by an exactly zero pivot; no condition
// estimate or near-singularity threshold is applied.
pub fn (a &CSRMatrix[f64]) factorize_lu() !&SparseLU {
	if a.m != a.n {
		return error('CSR LU factorization requires a square matrix, got ${a.m}x${a.n}')
	}
	if a.m < 0 || a.nnz < 0 || a.p.len != a.m + 1 || a.j.len != a.nnz || a.x.len != a.nnz {
		return error('CSR LU factorization received malformed CSR storage')
	}
	if a.p[0] != 0 || a.p[a.m] != a.nnz {
		return error('CSR LU factorization received malformed row pointers')
	}

	mut rows := []map[int]f64{len: a.m}
	mut permutation := []int{len: a.m}
	for row in 0 .. a.m {
		rows[row] = map[int]f64{}
		permutation[row] = row
		if a.p[row] < 0 || a.p[row] > a.p[row + 1] || a.p[row + 1] > a.nnz {
			return error('CSR LU factorization received malformed row pointers')
		}
		for position in a.p[row] .. a.p[row + 1] {
			column := a.j[position]
			value := a.x[position]
			if column < 0 || column >= a.n {
				return error('CSR LU factorization received an out-of-range column index')
			}
			if !math.is_finite(value) {
				return error('CSR LU factorization requires finite matrix values')
			}
			rows[row][column] += value
			if !math.is_finite(rows[row][column]) {
				return error('CSR LU factorization produced a non-finite assembled value')
			}
		}
	}

	for pivot_column in 0 .. a.n {
		mut pivot_row := pivot_column
		mut pivot_magnitude := 0.0
		for row in pivot_column .. a.n {
			magnitude := math.abs(rows[row][pivot_column])
			if magnitude > pivot_magnitude {
				pivot_magnitude = magnitude
				pivot_row = row
			}
		}
		if pivot_magnitude == 0.0 {
			return error('CSR LU factorization found a singular pivot at column ${pivot_column}')
		}
		if pivot_row != pivot_column {
			row_swap := rows[pivot_column]
			rows[pivot_column] = rows[pivot_row]
			rows[pivot_row] = row_swap
			permutation_swap := permutation[pivot_column]
			permutation[pivot_column] = permutation[pivot_row]
			permutation[pivot_row] = permutation_swap
		}

		pivot := rows[pivot_column][pivot_column]
		for row in pivot_column + 1 .. a.n {
			entry := rows[row][pivot_column]
			if entry == 0.0 {
				continue
			}
			multiplier := entry / pivot
			if !math.is_finite(multiplier) {
				return error('CSR LU factorization produced a non-finite multiplier')
			}
			rows[row][pivot_column] = multiplier
			for column, pivot_value in rows[pivot_column] {
				if column <= pivot_column {
					continue
				}
				updated := rows[row][column] - multiplier * pivot_value
				if !math.is_finite(updated) {
					return error('CSR LU factorization produced a non-finite value during elimination')
				}
				if updated == 0.0 {
					rows[row].delete(column)
				} else {
					rows[row][column] = updated
				}
			}
		}
	}

	return &SparseLU{
		size:        a.n
		rows:        rows
		permutation: permutation
	}
}

// solve applies a previously computed sparse LU factorization to one right-hand
// side. The factorization can be reused for subsequent right-hand sides.
pub fn (factor &SparseLU) solve(b []f64) ![]f64 {
	if b.len != factor.size {
		return error('sparse LU right-hand side length ${b.len} ' +
			'does not match matrix size ${factor.size}')
	}
	for value in b {
		if !math.is_finite(value) {
			return error('sparse LU right-hand side must contain only finite values')
		}
	}

	mut solution := []f64{len: factor.size}
	for row in 0 .. factor.size {
		solution[row] = b[factor.permutation[row]]
	}
	for row in 0 .. factor.size {
		mut value := solution[row]
		for column, coefficient in factor.rows[row] {
			if column < row {
				value -= coefficient * solution[column]
			}
		}
		if !math.is_finite(value) {
			return error('sparse LU forward substitution produced a non-finite value')
		}
		solution[row] = value
	}
	for step in 0 .. factor.size {
		row := factor.size - step - 1
		mut value := solution[row]
		for column, coefficient in factor.rows[row] {
			if column > row {
				value -= coefficient * solution[column]
			}
		}
		diagonal := factor.rows[row][row]
		if diagonal == 0.0 {
			return error('sparse LU factorization has a zero diagonal at row ${row}')
		}
		solution[row] = value / diagonal
		if !math.is_finite(solution[row]) {
			return error('sparse LU back substitution produced a non-finite value')
		}
	}
	return solution
}
