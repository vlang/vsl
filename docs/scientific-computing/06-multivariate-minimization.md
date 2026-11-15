# Multivariate Minimization

`roots.NelderMead` minimizes a scalar objective over a vector of parameters
without requiring derivatives. `roots.BFGS` uses an analytic gradient and an
inverse-Hessian approximation, and is often more efficient for smooth
objectives when gradient information is available. Both methods report the
best accepted point, objective value, and evaluation/iteration diagnostics.

Neither method is a global optimizer or imposes parameter bounds. Nelder-Mead
is a derivative-free local method intended for low-dimensional problems; its
initial simplex adds the same `initial_step` to one coordinate at a time.
Convergence requires both the maximum coordinate spread and the objective
spread to be within their absolute tolerances.

```v
import vsl.func
import vsl.roots

fn rosenbrock(x []f64, _ []f64) f64 {
	a := 1.0 - x[0]
	b := x[1] - x[0] * x[0]
	return a * a + 100.0 * b * b
}

objective := func.FnND.new(rosenbrock)
mut optimizer := roots.NelderMead.new_with_params(objective, roots.NelderMeadParams{
	x0:           [-1.2, 1.0]
	initial_step: 0.5
	x_tol:        1e-6
	f_tol:        1e-12
	n_max:        2000
	max_evals:    5000
})
result := optimizer.solve()!
println('status=${result.status}')
println('minimum: x=${result.x}, f(x)=${result.fx}')
println('simplex spreads: x=${result.x_spread}, f=${result.f_spread}')
println('iterations=${result.n_iter}, evaluations=${result.n_calls}')
```

The initial point must be non-empty and finite, `initial_step` and both
tolerances must be finite and positive, and `max_evals` must be at least the
number of initial simplex vertices (`dimension + 1`). Invalid parameters
return an error. Reaching an execution limit, an unrepresentable simplex step,
or a non-finite callback value is reported through the result status.

See the [Nelder-Mead example](../../examples/roots_nelder_mead/README.md) and
the [roots API reference](../../roots/README.md).

## BFGS with an analytic gradient

The gradient callback receives the same parameter slice used by `func.FnND`.
It must return one finite partial derivative per coordinate. BFGS uses an
Armijo backtracking line search, a positive initial step, and a gradient-norm
stopping tolerance. Its evaluation limit counts objective calls; gradient
calls are reported separately. An invalid gradient or an unsuccessful line
search is reported through the result status. The dense inverse-Hessian
approximation uses O(n²) storage, making this full BFGS implementation best
suited to moderate-dimensional problems.

```v
import vsl.func
import vsl.roots

fn rosenbrock(x []f64, _ []f64) f64 {
	a := 1.0 - x[0]
	b := x[1] - x[0] * x[0]
	return a * a + 100.0 * b * b
}

fn rosenbrock_gradient(x []f64, _ []f64) []f64 {
	b := x[1] - x[0] * x[0]
	return [2.0 * (x[0] - 1.0) - 400.0 * x[0] * b, 200.0 * b]
}

objective := func.FnND.new(rosenbrock)
mut optimizer := roots.BFGS.new_with_params(objective, rosenbrock_gradient,
	roots.BFGSParams{
		x0:           [-1.2, 1.0]
		gradient_tol: 1e-6
		n_max:        1000
		max_evals:    5000
	})
result := optimizer.solve()!
println('status=${result.status}, x=${result.x}, f(x)=${result.fx}')
println('gradient norm=${result.gradient_norm}, evaluations=${result.n_calls}')
```

The callback must provide the true objective gradient. The result reports
`.converged` only when its Euclidean norm meets `gradient_tol`; it may instead
report `.max_iterations`, `.max_evaluations`, `.line_search_failed`,
`.non_finite_function_value`, `.invalid_gradient`, or `.precision_limit`.
This local method has no global-minimum guarantee.

See the [BFGS example](../../examples/roots_bfgs/README.md).
