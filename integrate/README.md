# `vsl.integrate`

`adaptive_gauss_kronrod` estimates finite-interval integrals with an embedded
7/15-point Gauss-Kronrod rule. It repeatedly subdivides the interval with the
largest estimated error until the requested absolute/relative tolerance is
met, or a configured interval, evaluation, or floating-point precision limit
is reached.

```v
import math
import vsl.func
import vsl.integrate

fn objective(x f64, _ []f64) f64 {
	return math.sin(20.0 * x)
}

f := func.Fn.new(f: objective)
result := integrate.adaptive_gauss_kronrod(f, integrate.GaussKronrodParams{
	a:       0.0
	b:       1.0
	abs_tol: 1e-10
	rel_tol: 1e-10
})!
println('${result.value} ± ${result.error_estimate} (${result.status})')
```

The reported `error_estimate` is an estimate, not a certified mathematical
bound. Non-finite callback values and non-finite integral estimates have
distinct statuses.

## Improper intervals

`adaptive_gauss_kronrod_improper` accepts finite bounds and either sign of
infinity through `math.inf(1)` and `math.inf(-1)`. It maps one-sided tails onto
`[0, 1)` with the corresponding Jacobian. A whole-line integral is split at
zero and the absolute tolerance and execution budgets are divided between the
two tails; therefore whole-line calls require a positive absolute tolerance.
Reversed bounds negate the result. The transform and adaptive error estimate do
not guarantee convergence for conditionally convergent or highly oscillatory
tails.

Breakpoints and stiff ODE solvers are not included.
