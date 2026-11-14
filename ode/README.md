# `vsl.ode`

`solve_rk23` integrates first-order systems with an adaptive Bogacki-Shampine
3(2) explicit Runge-Kutta method. It supports vector states, forward or
backward integration, error tolerances, a maximum step size, and execution
limits. The method is intended for non-stiff systems.

```v
import math
import vsl.ode

fn exponential_system(_ f64, state []f64, _ []f64) []f64 {
	return [state[0]]
}

result := ode.solve_rk23(exponential_system, ode.RK23Params{
	t_start:       0.0
	t_end:         1.0
	initial_state: [1.0]
	abs_tol:       1e-9
	rel_tol:       1e-7
})!
assert math.abs(result.state[0] - math.e) < 1e-5
```

The result includes the last accepted state, scaled local error norm, function
evaluation count, accepted/rejected step counts, and a termination status.
This first ODE slice does not provide stiff methods, dense output, event
handling, or a full trajectory.
