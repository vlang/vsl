# Numerical Integration

VSL provides adaptive finite-interval quadrature through
[`vsl.integrate`](../../integrate/README.md). Its embedded 7/15-point
Gauss-Kronrod rule estimates the integral and its error, then subdivides the
interval with the largest estimated error until the requested tolerance is met
or an execution limit is reached.

## Integrate a finite interval

```v
import math
import vsl.func
import vsl.integrate

fn objective(x f64, _ []f64) f64 {
	return math.sin(20.0 * x)
}

f := func.Fn.new(f: objective)
result := integrate.adaptive_gauss_kronrod(f, integrate.GaussKronrodParams{
	a:             0.0
	b:             1.0
	abs_tol:       1e-10
	rel_tol:       1e-10
	max_intervals: 1000
	max_evals:     30000
})!
println('status=${result.status} value=${result.value}')
println('estimated error=${result.error_estimate} evaluations=${result.n_calls}')
```

`abs_tol` and `rel_tol` bound the requested estimated error by
`abs_tol + rel_tol * abs(value)`. The result status reports convergence,
non-finite callback or estimate, precision limits, and interval/evaluation
caps. Error estimates are not certified bounds. This initial implementation
does not support improper integrals, explicit breakpoints, or ODEs.

Run the [adaptive integration example](../../examples/integrate_gauss_kronrod/README.md)
from `~/.vmodules`.

