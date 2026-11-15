module la

import math

// BiCGSTABResult contains the approximate solution and convergence diagnostics.
pub struct BiCGSTABResult {
pub:
	x             []f64
	iterations    int
	residual_norm f64
	converged     bool
	breakdown     bool
}

// bicgstab solves a square CSR system with the BiCGSTAB iterative method.
// The initial guess is zero; a non-converged result reports the true residual.
pub fn (a &CSRMatrix[f64]) bicgstab(b []f64, tolerance f64, max_iterations int) !BiCGSTABResult {
	if a.m != a.n {
		return error('bicgstab requires a square matrix, got ${a.m}x${a.n}')
	}
	if b.len != a.n {
		return error('bicgstab right-hand side length ${b.len} does not match matrix size ${a.n}')
	}
	if !math.is_finite(tolerance) || tolerance <= 0.0 {
		return error('bicgstab tolerance must be finite and positive')
	}
	if max_iterations <= 0 {
		return error('bicgstab maximum iterations must be positive')
	}
	for value in b {
		if !math.is_finite(value) {
			return error('bicgstab right-hand side must contain only finite values')
		}
	}
	for value in a.x {
		if !math.is_finite(value) {
			return error('bicgstab matrix values must be finite')
		}
	}

	mut x := []f64{len: a.n}
	mut r := b.clone()
	mut r_hat := r.clone()
	mut p := []f64{len: a.n}
	mut v := []f64{len: a.n}
	norm_b := stable_vector_norm(b)!
	target := tolerance * norm_b
	if !math.is_finite(target) {
		return error('bicgstab residual tolerance overflowed')
	}
	if norm_b <= target {
		return bicgstab_result(x, 0, norm_b, target, false)
	}

	mut previous_rho := 1.0
	mut alpha := 1.0
	mut omega := 1.0
	for iteration in 0 .. max_iterations {
		rho := vector_dot(r_hat, r)
		if !math.is_finite(rho) {
			return error('bicgstab shadow residual product became non-finite')
		}
		if rho == 0.0 {
			return bicgstab_finish(a, b, x, iteration, target, true)
		}
		beta := (rho / previous_rho) * (alpha / omega)
		if !math.is_finite(beta) {
			return error('bicgstab step coefficient became non-finite')
		}
		for i in 0 .. a.n {
			p[i] = r[i] + beta * (p[i] - omega * v[i])
		}
		if !finite_f64_vector(p) {
			return error('bicgstab search direction became non-finite')
		}
		v = a.matvec(p)!.clone()
		if !finite_f64_vector(v) {
			return error('bicgstab matrix product became non-finite')
		}
		denominator := vector_dot(r_hat, v)
		if !math.is_finite(denominator) {
			return error('bicgstab alpha denominator became non-finite')
		}
		if denominator == 0.0 {
			return bicgstab_finish(a, b, x, iteration, target, true)
		}
		alpha = rho / denominator
		if !math.is_finite(alpha) {
			return error('bicgstab alpha became non-finite')
		}
		mut s := []f64{len: a.n}
		for i in 0 .. a.n {
			s[i] = r[i] - alpha * v[i]
		}
		if !finite_f64_vector(s) {
			return error('bicgstab intermediate residual became non-finite')
		}
		s_norm := stable_vector_norm(s)!
		if s_norm <= target {
			for i in 0 .. a.n {
				x[i] += alpha * p[i]
			}
			true_residual, true_residual_norm := bicgstab_true_residual(a, b, x)!
			if true_residual_norm <= target {
				return bicgstab_result(x, iteration + 1, true_residual_norm, target, false)
			}
			r = true_residual.clone()
			r_hat = r.clone()
			p = []f64{len: a.n}
			v = []f64{len: a.n}
			previous_rho = 1.0
			alpha = 1.0
			omega = 1.0
			continue
		}

		t := a.matvec(s)!
		if !finite_f64_vector(t) {
			return error('bicgstab second matrix product became non-finite')
		}
		t_squared := vector_dot(t, t)
		if !math.is_finite(t_squared) {
			return error('bicgstab second matrix product norm became non-finite')
		}
		if t_squared == 0.0 {
			for i in 0 .. a.n {
				x[i] += alpha * p[i]
			}
			return bicgstab_finish(a, b, x, iteration + 1, target, true)
		}
		omega = vector_dot(t, s) / t_squared
		if !math.is_finite(omega) {
			return error('bicgstab omega became non-finite')
		}
		if omega == 0.0 {
			for i in 0 .. a.n {
				x[i] += alpha * p[i]
			}
			return bicgstab_finish(a, b, x, iteration + 1, target, true)
		}
		mut next_r := []f64{len: a.n}
		for i in 0 .. a.n {
			x[i] += alpha * p[i] + omega * s[i]
			next_r[i] = s[i] - omega * t[i]
		}
		if !finite_f64_vector(x) || !finite_f64_vector(next_r) {
			return error('bicgstab solution or residual became non-finite')
		}
		r = next_r.clone()
		residual_norm := stable_vector_norm(r)!
		if residual_norm <= target {
			true_residual, true_residual_norm := bicgstab_true_residual(a, b, x)!
			if true_residual_norm <= target {
				return bicgstab_result(x, iteration + 1, true_residual_norm, target, false)
			}
			r = true_residual.clone()
			r_hat = r.clone()
			p = []f64{len: a.n}
			v = []f64{len: a.n}
			previous_rho = 1.0
			alpha = 1.0
			omega = 1.0
			continue
		}
		previous_rho = rho
	}
	return bicgstab_finish(a, b, x, max_iterations, target, false)
}

fn bicgstab_true_residual(a &CSRMatrix[f64], b []f64, x []f64) !([]f64, f64) {
	ax := a.matvec(x)!
	mut residual := []f64{len: b.len}
	for i in 0 .. b.len {
		residual[i] = b[i] - ax[i]
	}
	return residual, stable_vector_norm(residual)!
}

fn bicgstab_result(x []f64, iterations int, residual_norm f64, target f64, breakdown bool) BiCGSTABResult {
	converged := residual_norm <= target
	return BiCGSTABResult{
		x:             x.clone()
		iterations:    iterations
		residual_norm: residual_norm
		converged:     converged
		breakdown:     breakdown && !converged
	}
}

fn bicgstab_finish(a &CSRMatrix[f64], b []f64, x []f64, iterations int, target f64, breakdown bool) !BiCGSTABResult {
	_, residual_norm := bicgstab_true_residual(a, b, x)!
	return bicgstab_result(x, iterations, residual_norm, target, breakdown)
}

fn finite_f64_vector(values []f64) bool {
	for value in values {
		if !math.is_finite(value) {
			return false
		}
	}
	return true
}
