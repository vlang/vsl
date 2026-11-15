# Initial-value ODEs

VSL includes an adaptive explicit Runge-Kutta method for non-stiff initial-value
systems. `ode.solve_rk23` uses the embedded Bogacki-Shampine 3(2) pair to
control local error while integrating forward or backward in time.

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
	output_times:  [0.25, 0.75]
	abs_tol:       1e-9
	rel_tol:       1e-7
})!
println('y(1)=${result.state[0]} (expected ${math.e})')
println('accepted=${result.n_accepted}, rejected=${result.n_rejected}')
assert result.sampled_times == [0.25, 0.75]
assert math.abs(result.sampled_states[0][0] - math.exp(0.25)) < 1e-4
```

Requested times are evaluated with cubic Hermite interpolation over accepted
steps. They must be ordered in the integration direction and lie inside the
integration interval; duplicate times are allowed. The solver returns sampled
states in request order and only includes samples reached before any execution
limit. Sampling is opt-in and does not retain every accepted step. VSL has no
stiff method or event support yet. See the [`vsl.ode` API
guide](../../ode/README.md) and [harmonic oscillator
example](../../examples/ode_rk23/README.md).
