module la

import math

// CGResult contains the approximate solution and convergence diagnostics.
pub struct CGResult {
pub:
	x             []f64
	iterations    int
	residual_norm f64
	converged     bool
}

// GMRESResult contains the approximate solution and convergence diagnostics.
pub struct GMRESResult {
pub:
	x             []f64
	iterations    int
	residual_norm f64
	converged     bool
}

// conjugate_gradient solves A*x=b for a symmetric positive-definite CSR matrix.
// It returns a non-converged result when the iteration limit is reached and an
// error when the iteration encounters non-positive curvature or invalid input.
pub fn (a &CSRMatrix[f64]) conjugate_gradient(b []f64, tolerance f64, max_iterations int) !CGResult {
	return conjugate_gradient_impl(a, b, tolerance, max_iterations, [])
}

// preconditioned_conjugate_gradient solves A*x=b using the Jacobi
// preconditioner formed from the positive diagonal of A.
pub fn (a &CSRMatrix[f64]) preconditioned_conjugate_gradient(b []f64, tolerance f64, max_iterations int) !CGResult {
	diagonal := jacobi_preconditioner(a)!
	return conjugate_gradient_impl(a, b, tolerance, max_iterations, diagonal)
}

fn conjugate_gradient_impl(a &CSRMatrix[f64], b []f64, tolerance f64, max_iterations int, diagonal []f64) !CGResult {
	if a.m != a.n {
		return error('conjugate_gradient requires a square matrix, got ${a.m}x${a.n}')
	}
	if b.len != a.n {
		return error('conjugate_gradient right-hand side length ${b.len} does not match matrix size ${a.n}')
	}
	if !math.is_finite(tolerance) || tolerance <= 0.0 {
		return error('conjugate_gradient tolerance must be finite and positive')
	}
	if max_iterations <= 0 {
		return error('conjugate_gradient maximum iterations must be positive')
	}
	for value in b {
		if !math.is_finite(value) {
			return error('conjugate_gradient right-hand side must contain only finite values')
		}
	}
	for value in a.x {
		if !math.is_finite(value) {
			return error('conjugate_gradient matrix values must be finite')
		}
	}

	mut x := []f64{len: a.n}
	mut r := b.clone()
	mut z := apply_cg_preconditioner(r, diagonal)
	mut p := z.clone()
	residual_squared := vector_dot(r, r)
	if !math.is_finite(residual_squared) {
		return error('conjugate_gradient residual norm overflowed')
	}
	norm_b := math.sqrt(residual_squared)
	target := tolerance * norm_b
	if !math.is_finite(target) {
		return error('conjugate_gradient residual tolerance overflowed')
	}
	mut residual_norm := norm_b
	if residual_norm <= target {
		return CGResult{
			x:             x
			iterations:    0
			residual_norm: residual_norm
			converged:     true
		}
	}
	mut rho := vector_dot(r, z)
	if !math.is_finite(rho) || rho <= 0.0 {
		return error('conjugate_gradient preconditioned residual product is non-positive or non-finite')
	}

	for iteration in 0 .. max_iterations {
		ap := a.matvec(p)!
		curvature := vector_dot(p, ap)
		if !math.is_finite(curvature) {
			return error('conjugate_gradient encountered non-finite curvature')
		}
		if curvature <= 0.0 {
			return error('conjugate_gradient encountered non-positive curvature; matrix may not be positive definite')
		}
		alpha := rho / curvature
		if !math.is_finite(alpha) {
			return error('conjugate_gradient step size is non-finite')
		}
		for i in 0 .. a.n {
			x[i] += alpha * p[i]
			r[i] -= alpha * ap[i]
		}
		next_residual_squared := vector_dot(r, r)
		if !math.is_finite(next_residual_squared) || next_residual_squared < 0.0 {
			return error('conjugate_gradient residual norm became non-finite')
		}
		residual_norm = math.sqrt(next_residual_squared)
		if residual_norm <= target {
			actual_ap := a.matvec(x)!
			mut actual_residual := []f64{len: a.n}
			for i in 0 .. a.n {
				actual_residual[i] = b[i] - actual_ap[i]
			}
			actual_residual_squared := vector_dot(actual_residual, actual_residual)
			if !math.is_finite(actual_residual_squared) || actual_residual_squared < 0.0 {
				return error('conjugate_gradient true residual norm became non-finite')
			}
			residual_norm = math.sqrt(actual_residual_squared)
			if residual_norm <= target {
				return CGResult{
					x:             x
					iterations:    iteration + 1
					residual_norm: residual_norm
					converged:     true
				}
			}
			r = actual_residual.clone()
			z = apply_cg_preconditioner(r, diagonal)
			rho = vector_dot(r, z)
			if !math.is_finite(rho) || rho <= 0.0 {
				return error('conjugate_gradient preconditioned residual product is non-positive or non-finite')
			}
			p = z.clone()
			continue
		}
		z = apply_cg_preconditioner(r, diagonal)
		next_rho := vector_dot(r, z)
		if !math.is_finite(next_rho) || next_rho <= 0.0 {
			return error('conjugate_gradient preconditioned residual product is non-positive or non-finite')
		}
		beta := next_rho / rho
		for i in 0 .. a.n {
			p[i] = z[i] + beta * p[i]
		}
		rho = next_rho
	}

	actual_ap := a.matvec(x)!
	mut actual_residual := []f64{len: a.n}
	for i in 0 .. a.n {
		actual_residual[i] = b[i] - actual_ap[i]
	}
	actual_residual_squared := vector_dot(actual_residual, actual_residual)
	if !math.is_finite(actual_residual_squared) || actual_residual_squared < 0.0 {
		return error('conjugate_gradient true residual norm became non-finite')
	}
	return CGResult{
		x:             x
		iterations:    max_iterations
		residual_norm: math.sqrt(actual_residual_squared)
		converged:     false
	}
}

fn jacobi_preconditioner(a &CSRMatrix[f64]) ![]f64 {
	if a.m != a.n {
		return error('preconditioned_conjugate_gradient requires a square matrix')
	}
	mut diagonal := []f64{len: a.n}
	for row in 0 .. a.n {
		mut found := false
		for k in a.p[row] .. a.p[row + 1] {
			if a.j[k] == row {
				diagonal[row] = a.x[k]
				found = true
				break
			}
		}
		if !found || !math.is_finite(diagonal[row]) || diagonal[row] <= 0.0 {
			return error('preconditioned_conjugate_gradient requires a finite positive diagonal')
		}
	}
	return diagonal
}

fn apply_cg_preconditioner(residual []f64, diagonal []f64) []f64 {
	if diagonal.len == 0 {
		return residual.clone()
	}
	mut result := []f64{len: residual.len}
	for index, value in residual {
		result[index] = value / diagonal[index]
	}
	return result
}

// gmres solves a square CSR system with restarted, unpreconditioned GMRES.
// The initial guess is zero; a non-converged result reports the true residual.
pub fn (a &CSRMatrix[f64]) gmres(b []f64, tolerance f64, max_iterations int, restart int) !GMRESResult {
	return gmres_impl(a, b, tolerance, max_iterations, restart, [])
}

// preconditioned_gmres solves a square CSR system using right Jacobi
// preconditioning. Its diagonal entries must be finite and nonzero.
pub fn (a &CSRMatrix[f64]) preconditioned_gmres(b []f64, tolerance f64, max_iterations int, restart int) !GMRESResult {
	diagonal := right_jacobi_preconditioner(a, 'preconditioned_gmres')!
	return gmres_impl(a, b, tolerance, max_iterations, restart, diagonal)
}

fn gmres_impl(a &CSRMatrix[f64], b []f64, tolerance f64, max_iterations int, restart int, diagonal []f64) !GMRESResult {
	if a.m != a.n {
		return error('gmres requires a square matrix, got ${a.m}x${a.n}')
	}
	if b.len != a.n {
		return error('gmres right-hand side length ${b.len} does not match matrix size ${a.n}')
	}
	if !math.is_finite(tolerance) || tolerance <= 0.0 {
		return error('gmres tolerance must be finite and positive')
	}
	if max_iterations <= 0 {
		return error('gmres maximum iterations must be positive')
	}
	if restart <= 0 {
		return error('gmres restart length must be positive')
	}
	for value in b {
		if !math.is_finite(value) {
			return error('gmres right-hand side must contain only finite values')
		}
	}
	for value in a.x {
		if !math.is_finite(value) {
			return error('gmres matrix values must be finite')
		}
	}

	mut x := []f64{len: a.n}
	mut residual := b.clone()
	mut residual_norm := stable_vector_norm(residual)!
	target := tolerance * residual_norm
	if !math.is_finite(target) {
		return error('gmres residual tolerance overflowed')
	}
	if residual_norm <= target {
		return GMRESResult{
			x:             x
			iterations:    0
			residual_norm: residual_norm
			converged:     true
		}
	}

	mut iterations := 0
	for iterations < max_iterations {
		mut cycle_length := restart
		remaining_iterations := max_iterations - iterations
		if cycle_length > remaining_iterations {
			cycle_length = remaining_iterations
		}
		if cycle_length > a.n {
			cycle_length = a.n
		}
		mut basis := [][]f64{len: cycle_length + 1}
		for i in 0 .. basis.len {
			basis[i] = []f64{len: a.n}
		}
		for i, value in residual {
			basis[0][i] = value / residual_norm
		}
		mut hessenberg := [][]f64{len: cycle_length + 1}
		for i in 0 .. hessenberg.len {
			hessenberg[i] = []f64{len: cycle_length}
		}
		mut search_directions := [][]f64{len: cycle_length}
		mut cosines := []f64{len: cycle_length}
		mut sines := []f64{len: cycle_length}
		mut g := []f64{len: cycle_length + 1}
		g[0] = residual_norm
		mut active_columns := 0
		mut breakdown := false

		for column in 0 .. cycle_length {
			search_directions[column] = if diagonal.len == 0 {
				basis[column]
			} else {
				apply_right_jacobi_preconditioner(basis[column], diagonal, 'preconditioned_gmres')!
			}
			mut work := a.matvec(search_directions[column])!
			for _ in 0 .. 2 {
				for row in 0 .. column + 1 {
					correction := vector_dot(basis[row], work)
					if !math.is_finite(correction) {
						return error('gmres Arnoldi orthogonalization became non-finite')
					}
					hessenberg[row][column] += correction
					for i in 0 .. a.n {
						work[i] -= correction * basis[row][i]
					}
				}
			}
			arnoldi_norm := stable_vector_norm(work)!
			hessenberg[column + 1][column] = arnoldi_norm
			if arnoldi_norm > 0.0 {
				for i in 0 .. a.n {
					basis[column + 1][i] = work[i] / arnoldi_norm
				}
			}

			for row in 0 .. column {
				top := cosines[row] * hessenberg[row][column] +
					sines[row] * hessenberg[row + 1][column]
				bottom := -sines[row] * hessenberg[row][column] +
					cosines[row] * hessenberg[row + 1][column]
				hessenberg[row][column] = top
				hessenberg[row + 1][column] = bottom
			}
			rotation_norm := stable_hypot(hessenberg[column][column],
				hessenberg[column + 1][column])
			if !math.is_finite(rotation_norm) {
				return error('gmres Givens rotation became non-finite')
			}
			if rotation_norm == 0.0 {
				breakdown = true
				break
			}
			cosines[column] = hessenberg[column][column] / rotation_norm
			sines[column] = hessenberg[column + 1][column] / rotation_norm
			hessenberg[column][column] = rotation_norm
			hessenberg[column + 1][column] = 0.0
			g[column + 1] = -sines[column] * g[column]
			g[column] *= cosines[column]
			iterations++
			active_columns = column + 1

			if arnoldi_norm == 0.0 {
				breakdown = true
			}
			if math.abs(g[column + 1]) <= target || breakdown {
				break
			}
		}
		if active_columns == 0 {
			return GMRESResult{
				x:             x
				iterations:    iterations
				residual_norm: residual_norm
				converged:     false
			}
		}

		coefficients := gmres_back_substitute(hessenberg, g, active_columns)!
		for column in 0 .. active_columns {
			for i in 0 .. a.n {
				x[i] += coefficients[column] * search_directions[column][i]
			}
		}
		ax := a.matvec(x)!
		for i in 0 .. a.n {
			residual[i] = b[i] - ax[i]
		}
		residual_norm = stable_vector_norm(residual)!
		if residual_norm <= target {
			return GMRESResult{
				x:             x
				iterations:    iterations
				residual_norm: residual_norm
				converged:     true
			}
		}
		if breakdown {
			return GMRESResult{
				x:             x
				iterations:    iterations
				residual_norm: residual_norm
				converged:     false
			}
		}
	}
	return GMRESResult{
		x:             x
		iterations:    iterations
		residual_norm: residual_norm
		converged:     false
	}
}

fn right_jacobi_preconditioner(a &CSRMatrix[f64], method string) ![]f64 {
	if a.m != a.n {
		return error('${method} requires a square matrix')
	}
	mut diagonal := []f64{len: a.n}
	for row in 0 .. a.n {
		mut found := false
		for k in a.p[row] .. a.p[row + 1] {
			if a.j[k] == row {
				diagonal[row] = a.x[k]
				found = true
				break
			}
		}
		if !found || !math.is_finite(diagonal[row]) || diagonal[row] == 0.0 {
			return error('${method} requires a finite nonzero diagonal')
		}
	}
	return diagonal
}

fn apply_right_jacobi_preconditioner(vector []f64, diagonal []f64, method string) ![]f64 {
	mut result := []f64{len: vector.len}
	for index, value in vector {
		result[index] = value / diagonal[index]
		if !math.is_finite(result[index]) {
			return error('${method} Jacobi preconditioner produced a non-finite value')
		}
	}
	return result
}

fn gmres_back_substitute(hessenberg [][]f64, g []f64, size int) ![]f64 {
	mut solution := []f64{len: size}
	for row := size - 1; row >= 0; row-- {
		mut value := g[row]
		for column in row + 1 .. size {
			value -= hessenberg[row][column] * solution[column]
		}
		diagonal := hessenberg[row][row]
		if !math.is_finite(diagonal) || diagonal == 0.0 {
			return error('gmres encountered a singular Hessenberg system')
		}
		solution[row] = value / diagonal
		if !math.is_finite(solution[row]) {
			return error('gmres Hessenberg solution became non-finite')
		}
	}
	return solution
}

fn stable_vector_norm(vector []f64) !f64 {
	mut length := 0.0
	for value in vector {
		if !math.is_finite(value) {
			return error('gmres vector contains a non-finite value')
		}
		length = stable_hypot(length, value)
		if !math.is_finite(length) {
			return error('gmres vector norm became non-finite')
		}
	}
	return length
}

fn stable_hypot(left f64, right f64) f64 {
	abs_left := math.abs(left)
	abs_right := math.abs(right)
	if abs_left > abs_right {
		ratio := abs_right / abs_left
		return abs_left * math.sqrt(1.0 + ratio * ratio)
	}
	if abs_right > 0.0 {
		ratio := abs_left / abs_right
		return abs_right * math.sqrt(1.0 + ratio * ratio)
	}
	return 0.0
}
