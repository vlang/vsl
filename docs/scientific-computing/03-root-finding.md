# Root Finding

Learn numerical methods for finding roots with Newton, bisection, and Brent solvers.

## What You'll Learn

- Bracketed root solvers
- Brent's derivative-free method
- Convergence status and evaluation diagnostics

## Brent's Method

Brent's method combines bisection, secant steps, and inverse quadratic
interpolation. It needs a sign-changing bracket but no derivative.

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
println('status=${result.status}, x=${result.x}, f(x)=${result.fx}')
println('bracket=[${result.lower}, ${result.upper}], evaluations=${result.n_calls}')
```

Invalid parameters return an error. A valid configuration that cannot finish
reports `.invalid_bracket`, `.max_iterations`, `.max_evaluations`,
`.non_finite_function_value`, or `.precision_limit` in the result status.
`error_bound` bounds the estimate's distance to any root enclosed by the final
bracket. A precision limit means floating-point spacing prevents the requested
tolerance from being reached. See the
[Brent example](../../examples/roots_brent_solver/README.md) for a complete
program.

## Next Steps

- [Bisection example](../../examples/roots_bisection_solver/README.md)
- [Brent example](../../examples/roots_brent_solver/README.md)
- [Roots module API](../../roots/README.md)
