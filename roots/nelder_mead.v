module roots

import math
import vsl.errors
import vsl.func

// NelderMeadStatus reports why the optimizer stopped.
pub enum NelderMeadStatus {
	converged
	max_iterations
	max_evaluations
	non_finite_function_value
	precision_limit
}

// NelderMeadParams configures derivative-free multivariate minimization.
@[params]
pub struct NelderMeadParams {
pub:
	x0           []f64
	initial_step f64 = 1.0
	x_tol        f64 = 1e-8
	f_tol        f64 = 1e-8
	n_max        int = 200
	max_evals    int = 1000
}

// NelderMeadResult contains the best point and simplex convergence diagnostics.
pub struct NelderMeadResult {
pub:
	x        []f64
	fx       f64
	x_spread f64
	f_spread f64
	n_calls  int
	n_iter   int
	status   NelderMeadStatus
}

// NelderMead minimizes a scalar objective over an n-dimensional input.
pub struct NelderMead {
pub:
	f func.FnND @[required]
pub mut:
	x0           []f64
	initial_step f64
	x_tol        f64
	f_tol        f64
	n_max        int
	max_evals    int
	n_calls      int
	n_iter       int
}

// NelderMead.new creates an optimizer with default tolerances and limits.
// Set x0 before calling solve, or use new_with_params.
pub fn NelderMead.new(f func.FnND) &NelderMead {
	return NelderMead.new_with_params(f, NelderMeadParams{})
}

// NelderMead.new_with_params creates a configured optimizer.
pub fn NelderMead.new_with_params(f func.FnND, params NelderMeadParams) &NelderMead {
	return &NelderMead{
		f:            f
		x0:           params.x0.clone()
		initial_step: params.initial_step
		x_tol:        params.x_tol
		f_tol:        params.f_tol
		n_max:        params.n_max
		max_evals:    params.max_evals
	}
}

fn nelder_mead_finite_vector(x []f64) bool {
	for value in x {
		if !finite_value(value) {
			return false
		}
	}
	return true
}

fn nelder_mead_lerp(a []f64, b []f64, weight f64) []f64 {
	mut result := []f64{len: a.len, init: 0.0}
	for i in 0 .. a.len {
		result[i] = a[i] + weight * (b[i] - a[i])
	}
	return result
}

fn sort_nelder_mead_simplex(mut simplex [][]f64, mut values []f64) {
	for i in 1 .. values.len {
		mut j := i
		for j > 0 && values[j] < values[j - 1] {
			value := values[j]
			values[j] = values[j - 1]
			values[j - 1] = value
			vertex := simplex[j].clone()
			simplex[j] = simplex[j - 1].clone()
			simplex[j - 1] = vertex
			j--
		}
	}
}

fn (solver NelderMead) result(simplex [][]f64, values []f64, status NelderMeadStatus) NelderMeadResult {
	mut best_index := 0
	mut best_fx := math.nan()
	if values.len > 0 {
		best_fx = values[0]
		for i in 1 .. values.len {
			if values[i] < best_fx {
				best_index = i
				best_fx = values[i]
			}
		}
	}
	mut best_x := solver.x0.clone()
	if values.len > 0 && best_index < simplex.len {
		best_x = simplex[best_index].clone()
	}
	mut x_spread := math.inf(1)
	mut f_spread := math.inf(1)
	if values.len == simplex.len && values.len > 0 {
		x_spread = 0.0
		f_spread = 0.0
		for i, value in values {
			if i == best_index {
				continue
			}
			f_spread = math.max(f_spread, math.abs(value - best_fx))
			for j, coordinate in simplex[i] {
				x_spread = math.max(x_spread, math.abs(coordinate - best_x[j]))
			}
		}
	}
	return NelderMeadResult{
		x:        best_x
		fx:       best_fx
		x_spread: x_spread
		f_spread: f_spread
		n_calls:  solver.n_calls
		n_iter:   solver.n_iter
		status:   status
	}
}

fn (mut solver NelderMead) evaluate(x []f64) !f64 {
	value := solver.f.safe_eval(x) or {
		solver.n_calls++
		return err
	}
	solver.n_calls++
	return value
}

// solve minimizes a multivariate objective using the Nelder-Mead simplex
// method. Invalid parameters return errors; other termination reasons appear
// in the result. The initial simplex applies the same positive step along each
// coordinate axis, and convergence requires both coordinate and objective
// spreads to meet their absolute tolerances.
pub fn (mut solver NelderMead) solve() !NelderMeadResult {
	solver.n_calls = 0
	solver.n_iter = 0
	dimensions := solver.x0.len
	if dimensions == 0 || !finite_value(solver.initial_step) || solver.initial_step <= 0.0
		|| !finite_value(solver.x_tol) || solver.x_tol <= 0.0 || !finite_value(solver.f_tol)
		|| solver.f_tol <= 0.0 || solver.n_max <= 0 || solver.max_evals < dimensions + 1 {
		return errors.error('invalid Nelder-Mead parameters', .einval)
	}
	for value in solver.x0 {
		if !finite_value(value) {
			return errors.error('Nelder-Mead initial point must be finite', .einval)
		}
	}
	mut simplex := [][]f64{cap: dimensions + 1}
	simplex << solver.x0.clone()
	for i in 0 .. dimensions {
		mut vertex := solver.x0.clone()
		vertex[i] += solver.initial_step
		if !finite_value(vertex[i]) || vertex[i] == solver.x0[i] {
			return solver.result(simplex, []f64{}, .precision_limit)
		}
		simplex << vertex
	}
	mut values := []f64{cap: dimensions + 1}
	for vertex in simplex {
		value := solver.evaluate(vertex) or {
			return solver.result(simplex, values, .non_finite_function_value)
		}
		values << value
	}
	sort_nelder_mead_simplex(mut simplex, mut values)
	for solver.n_iter < solver.n_max {
		current := solver.result(simplex, values, .converged)
		if current.x_spread <= solver.x_tol && current.f_spread <= solver.f_tol {
			return current
		}
		if solver.n_calls >= solver.max_evals {
			return solver.result(simplex, values, .max_evaluations)
		}
		mut centroid := []f64{len: dimensions, init: 0.0}
		for i in 0 .. dimensions {
			for j in 0 .. dimensions {
				centroid[j] += simplex[i][j] / f64(dimensions)
			}
		}
		reflected := nelder_mead_lerp(centroid, simplex[dimensions], -1.0)
		if !nelder_mead_finite_vector(reflected) {
			return solver.result(simplex, values, .precision_limit)
		}
		reflected_value := solver.evaluate(reflected) or {
			return solver.result(simplex, values, .non_finite_function_value)
		}
		if reflected_value < values[0] {
			if solver.n_calls >= solver.max_evals {
				simplex[dimensions] = reflected
				values[dimensions] = reflected_value
				solver.n_iter++
				sort_nelder_mead_simplex(mut simplex, mut values)
				return solver.result(simplex, values, .max_evaluations)
			}
			expanded := nelder_mead_lerp(centroid, reflected, 2.0)
			if !nelder_mead_finite_vector(expanded) {
				simplex[dimensions] = reflected
				values[dimensions] = reflected_value
			} else {
				expanded_value := solver.evaluate(expanded) or {
					simplex[dimensions] = reflected
					values[dimensions] = reflected_value
					solver.n_iter++
					sort_nelder_mead_simplex(mut simplex, mut values)
					return solver.result(simplex, values, .non_finite_function_value)
				}
				if expanded_value < reflected_value {
					simplex[dimensions] = expanded
					values[dimensions] = expanded_value
				} else {
					simplex[dimensions] = reflected
					values[dimensions] = reflected_value
				}
			}
		} else if reflected_value < values[dimensions - 1] {
			simplex[dimensions] = reflected
			values[dimensions] = reflected_value
		} else {
			outside_contraction := reflected_value < values[dimensions]
			contracted := if outside_contraction {
				nelder_mead_lerp(centroid, reflected, 0.5)
			} else {
				nelder_mead_lerp(centroid, simplex[dimensions], 0.5)
			}
			mut contraction_accepted := false
			if solver.n_calls >= solver.max_evals {
				solver.n_iter++
				return solver.result(simplex, values, .max_evaluations)
			}
			if nelder_mead_finite_vector(contracted) {
				contracted_value := solver.evaluate(contracted) or {
					solver.n_iter++
					return solver.result(simplex, values, .non_finite_function_value)
				}
				if outside_contraction && contracted_value <= reflected_value {
					simplex[dimensions] = contracted
					values[dimensions] = contracted_value
					contraction_accepted = true
				} else if !outside_contraction && contracted_value < values[dimensions] {
					simplex[dimensions] = contracted
					values[dimensions] = contracted_value
					contraction_accepted = true
				}
			}
			if !contraction_accepted {
				if solver.max_evals - solver.n_calls < dimensions {
					solver.n_iter++
					return solver.result(simplex, values, .max_evaluations)
				}
				for i in 1 .. dimensions + 1 {
					shrunk := nelder_mead_lerp(simplex[0], simplex[i], 0.5)
					if !nelder_mead_finite_vector(shrunk) {
						solver.n_iter++
						return solver.result(simplex, values, .precision_limit)
					}
					shrunk_value := solver.evaluate(shrunk) or {
						solver.n_iter++
						return solver.result(simplex, values, .non_finite_function_value)
					}
					simplex[i] = shrunk
					values[i] = shrunk_value
				}
			}
		}
		solver.n_iter++
		sort_nelder_mead_simplex(mut simplex, mut values)
	}
	current := solver.result(simplex, values, .converged)
	status := if current.x_spread <= solver.x_tol && current.f_spread <= solver.f_tol {
		NelderMeadStatus.converged
	} else {
		.max_iterations
	}
	return solver.result(simplex, values, status)
}
