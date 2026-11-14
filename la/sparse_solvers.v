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

// conjugate_gradient solves A*x=b for a symmetric positive-definite CSR matrix.
// It returns a non-converged result when the iteration limit is reached and an
// error when the iteration encounters non-positive curvature or invalid input.
pub fn (a &CSRMatrix[f64]) conjugate_gradient(b []f64, tolerance f64, max_iterations int) !CGResult {
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
	mut p := r.clone()
	mut residual_squared := vector_dot(r, r)
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

	for iteration in 0 .. max_iterations {
		ap := a.matvec(p)!
		curvature := vector_dot(p, ap)
		if !math.is_finite(curvature) {
			return error('conjugate_gradient encountered non-finite curvature')
		}
		if curvature <= 0.0 {
			return error('conjugate_gradient encountered non-positive curvature; matrix may not be positive definite')
		}
		alpha := residual_squared / curvature
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
			p = r.clone()
			residual_squared = actual_residual_squared
			continue
		}
		beta := next_residual_squared / residual_squared
		for i in 0 .. a.n {
			p[i] = r[i] + beta * p[i]
		}
		residual_squared = next_residual_squared
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
