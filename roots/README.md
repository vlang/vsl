# `vsl.roots`

Root-finding routines in `vsl.roots` accept callbacks from [`vsl.func`](../func/func.v).
The currently usable solvers are:

| API | Method | Notes |
| --- | --- | --- |
| `newton(f, x0, x_eps, fx_eps, n_max)` | Newton iteration | Uses a function and derivative callback (`FnFdf`). |
| `newton_bisection(f, x_min, x_max, tol, max_iter)` | Newton with bisection safeguard | Requires a bracket and derivative callback. |
| `Bisection.new(f, params).solve()` | Bisection | Requires a sign-changing interval; returns the last iteration or the limit result. |
| `Brent.new_with_params(f, params).solve()` | Brent's method | Returns root, final bracket, residual, counts, and a termination status. |
| `GoldenSection.new_with_params(f, params).solve()` | Golden-section minimization | Minimizes a unimodal scalar function on a bounded interval without derivatives. |

`BisectionParams` configures bounds, relative and absolute tolerances, and the
iteration limit. `Bisection.next()` exposes individual steps. `BrentParams`
configures the bracket, tolerance, iteration limit, and function-evaluation
limit. A valid bracket is required. The solver reports `.converged`,
`.invalid_bracket`, `.max_iterations`, `.max_evaluations`, or
`.non_finite_function_value`, or `.precision_limit` in its result; invalid
parameter values return an error. `error_bound` is the maximum distance from
the reported estimate to either end of the final bracket, so it bounds the
estimate's distance to any root still enclosed by that bracket. A precision
limit means floating-point spacing prevents the requested tolerance from
being reached.

`GoldenSectionParams` configures the minimizer's bounds, absolute tolerance,
iteration limit, and callback evaluation limit. It assumes the objective is
unimodal over the full interval; it does not search for multiple local minima.
The result reports the best finite point observed, the final interval, its
maximum distance from that point, iteration and evaluation counts, and a
termination status. The function is evaluated only at interior points. A
precision-limit status also reports when adjacent objective values are
indistinguishable at floating-point precision, so the solver cannot safely
narrow the interval. It can have a NaN `fx` and zero evaluations when no
representable interior point exists.

```v
import math
import vsl.func
import vsl.roots

fn objective(x f64, _ []f64) f64 {
	return math.cos(x)
}

f := func.Fn.new(f: objective)
mut solver := roots.Bisection.new(f, roots.BisectionParams{
	xmin: 0.0
	xmax: 3.0
})
result := solver.solve() or { panic('root was not found') }
println(result.x)
```

Brent returns convergence diagnostics without requiring a derivative:

```v
import math
import vsl.func
import vsl.roots

fn objective(x f64, _ []f64) f64 {
	return math.cos(x)
}

f := func.Fn.new(f: objective)
mut solver := roots.Brent.new_with_params(f, roots.BrentParams{
	x1:  0.0
	x2:  3.0
	tol: 1e-10
})
result := solver.solve()!
println('status=${result.status} root=${result.x} residual=${result.fx}')
println('bracket=[${result.lower}, ${result.upper}] evaluations=${result.n_calls}')
```

Golden-section minimization reports the same bounded execution diagnostics:

```v
import vsl.func
import vsl.roots

fn objective(x f64, _ []f64) f64 {
	return (x - 1.25) * (x - 1.25)
}

f := func.Fn.new(f: objective)
mut minimizer := roots.GoldenSection.new_with_params(f, roots.GoldenSectionParams{
	xmin:      -5.0
	xmax:      5.0
	tol:       1e-8
	n_max:     100
	max_evals: 104
})
result := minimizer.solve()!
println('status=${result.status} x=${result.x} f(x)=${result.fx}')
println('interval=[${result.lower}, ${result.upper}] evaluations=${result.n_calls}')
```

See the [bisection example](../examples/roots_bisection_solver/README.md),
the [Brent example](../examples/roots_brent_solver/README.md),
the [Golden-section example](../examples/roots_golden_section/README.md),
[`bisection.v`](bisection.v), and [`newton.v`](newton.v).
