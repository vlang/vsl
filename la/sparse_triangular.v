module la

import math

// solve_lower_triangular solves A*x=b for a nonsingular lower-triangular CSR
// matrix without materializing a dense matrix.
pub fn (a &CSRMatrix[f64]) solve_lower_triangular(b []f64) ![]f64 {
	return solve_csr_triangular(a, b, true)
}

// solve_upper_triangular solves A*x=b for a nonsingular upper-triangular CSR
// matrix without materializing a dense matrix.
pub fn (a &CSRMatrix[f64]) solve_upper_triangular(b []f64) ![]f64 {
	return solve_csr_triangular(a, b, false)
}

fn solve_csr_triangular(a &CSRMatrix[f64], b []f64, lower bool) ![]f64 {
	method := if lower { 'solve_lower_triangular' } else { 'solve_upper_triangular' }
	if a.m != a.n {
		return error('${method} requires a square matrix, got ${a.m}x${a.n}')
	}
	if b.len != a.n {
		return error('${method} right-hand side length ${b.len} does not match matrix size ${a.n}')
	}
	for value in b {
		if !math.is_finite(value) {
			return error('${method} right-hand side must contain only finite values')
		}
	}

	mut solution := []f64{len: a.n}
	for step in 0 .. a.n {
		row := if lower { step } else { a.n - step - 1 }
		mut residual := b[row]
		mut diagonal := 0.0
		mut found_diagonal := false
		for position in a.p[row] .. a.p[row + 1] {
			column := a.j[position]
			value := a.x[position]
			if !math.is_finite(value) {
				return error('${method} matrix values must contain only finite values')
			}
			if column == row {
				diagonal = value
				found_diagonal = true
				continue
			}
			if lower && column > row {
				return error('${method} requires a lower-triangular matrix')
			}
			if !lower && column < row {
				return error('${method} requires an upper-triangular matrix')
			}
			residual -= value * solution[column]
			if !math.is_finite(residual) {
				return error('${method} intermediate value became non-finite')
			}
		}
		if !found_diagonal || diagonal == 0.0 {
			return error('${method} requires a nonzero diagonal entry in every row')
		}
		solution[row] = residual / diagonal
		if !math.is_finite(solution[row]) {
			return error('${method} solution contains a non-finite value')
		}
	}
	return solution
}
