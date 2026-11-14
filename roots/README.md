# `vsl.roots`

Root-finding and minimization routines in `vsl.roots` accept callbacks from
[`vsl.func`](../func/func.v). Current public APIs include:

| API | Method | Notes |
| --- | --- | --- |
| `newton(f, x0, x_eps, fx_eps, n_max)` | Newton iteration | Uses a function and derivative callback (`FnFdf`). |
| `newton_bisection(f, x_min, x_max, tol, max_iter)` | Newton with bisection safeguard | Requires a bracket and derivative callback. |
| `Bisection.new(f, params).solve()` | Bisection | Requires a sign-changing interval; returns the last iteration or the limit result. |
| `Brent.new_with_params(f, params).solve()` | Brent's method | Returns root, final bracket, residual, counts, and a termination status. |
| `NelderMead.new_with_params(f, params).solve()` | Nelder-Mead minimization | Derivative-free local minimization for multivariate scalar objectives. |
| `GoldenSection.new_with_params(f, params).solve()` | Golden-section minimization | Bounded unimodal scalar minimizer. |
| `BrentMinimizer.new_with_params(f, params).solve()` | Brent minimization | Safeguarded scalar minimizer. |

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

`NelderMeadParams` configures the initial point, a positive step applied to
each simplex axis in turn, absolute coordinate and objective tolerances, and
iteration/evaluation limits. The evaluation limit must allow the initial
`n+1` simplex vertices. The result reports the best point, objective value,
maximum coordinate spread, objective spread, counts, and termination status.
Nelder-Mead is derivative-free and has no bounds or global-optimum guarantee;
it is most appropriate for low-dimensional local optimization.

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

`BrentMinimizerParams` exposes the same bounds, absolute tolerance, iteration,
and evaluation limits. Brent minimization uses parabolic interpolation when
the proposed step is safe and falls back to golden-section steps otherwise.
Like Golden-section minimization, it assumes a unimodal objective and reports
the best observed point, final interval, maximum distance to either endpoint,
counts, and termination status.

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

Nelder-Mead minimizes multivariate objectives without derivative callbacks:

```v
import vsl.func
import vsl.roots

fn objective(x []f64, _ []f64) f64 {
	a := 1.0 - x[0]
	b := x[1] - x[0] * x[0]
	return a * a + 100.0 * b * b
}

f := func.FnND.new(objective)
mut optimizer := roots.NelderMead.new_with_params(f, roots.NelderMeadParams{
	x0:           [-1.2, 1.0]
	initial_step: 0.5
	x_tol:        1e-6
	f_tol:        1e-12
	n_max:        2000
	max_evals:    5000
})
result := optimizer.solve()!
println('status=${result.status}, x=${result.x}, f(x)=${result.fx}')
println('spreads=(${result.x_spread}, ${result.f_spread}), evaluations=${result.n_calls}')
```

See the [Nelder-Mead example](../examples/roots_nelder_mead/README.md) and
the [multivariate minimization guide](../docs/scientific-computing/06-multivariate-minimization.md).

Golden-section minimization reports bounded execution diagnostics:

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

Brent minimization uses the same objective and reports its termination diagnostics:

```v
import vsl.func
import vsl.roots

fn objective(x f64, _ []f64) f64 {
	return (x - 1.25) * (x - 1.25)
}

f := func.Fn.new(f: objective)
mut minimizer := roots.BrentMinimizer.new_with_params(f, roots.BrentMinimizerParams{
	xmin:      -5.0
	xmax:      5.0
	tol:       1e-8
	n_max:     100
	max_evals: 102
})
result := minimizer.solve()!
println('status=${result.status} x=${result.x} f(x)=${result.fx}')
println('interval=[${result.lower}, ${result.upper}] evaluations=${result.n_calls}')
```

See the [bisection example](../examples/roots_bisection_solver/README.md),
the [Brent example](../examples/roots_brent_solver/README.md),
the [Nelder-Mead example](../examples/roots_nelder_mead/README.md),
the [Golden-section example](../examples/roots_golden_section/README.md),
the [Brent minimization example](../examples/roots_brent_minimizer/README.md),
[`bisection.v`](bisection.v), and [`newton.v`](newton.v).
