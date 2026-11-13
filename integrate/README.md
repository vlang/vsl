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
distinct statuses. The first implementation supports finite bounds only;
improper integrals, breakpoints, and ODE solvers are not included.
