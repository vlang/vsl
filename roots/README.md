# `vsl.roots`

Root-finding routines in `vsl.roots` accept callbacks from [`vsl.func`](../func/func.v).
The currently usable solvers are:

| API | Method | Notes |
| --- | --- | --- |
| `newton(f, x0, x_eps, fx_eps, n_max)` | Newton iteration | Uses a function and derivative callback (`FnFdf`). |
| `newton_bisection(f, x_min, x_max, tol, max_iter)` | Newton with bisection safeguard | Requires a bracket and derivative callback. |
| `Bisection.new(f, params).solve()` | Bisection | Requires a sign-changing interval; returns the last iteration or the limit result. |

`BisectionParams` configures bounds, relative and absolute tolerances, and the
iteration limit. `Bisection.next()` exposes individual steps. The `Brent`
type currently has a constructor and an internal algorithm but does not expose
a public `solve` or iteration method yet.

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

See the [bisection example](../examples/roots_bisection_solver/README.md),
[`bisection.v`](bisection.v), and [`newton.v`](newton.v).
