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
stiff method. See the [`vsl.ode` API
guide](../../ode/README.md) and [harmonic oscillator
example](../../examples/ode_rk23/README.md).

## Detecting a terminal event

Set `event_function` to stop at the first event value that is zero on an
accepted-step boundary or changes sign across an accepted step. The solver
localizes sign changes by bisection over the accepted step's cubic Hermite
interpolant and returns the event time/state with `.event_detected`.

```v ignore
fn crossed_zero(_ f64, state []f64, _ []f64) f64 {
	return state[0]
}

fn unit_rate_system(_ f64, _ []f64, _ []f64) []f64 {
	return [1.0]
}

result := ode.solve_rk23(unit_rate_system, ode.RK23Params{
	t_start:        0.0
	t_end:          1.0
	initial_state:  [-0.5]
	event_function: crossed_zero
})!
assert result.status == .event_detected
assert math.abs(result.t - 0.5) < 1e-12
```

An event that is already zero at `t_start` stops before any derivative
evaluation. Tangential roots that do not change sign are not detected. Event
callback results must be finite; multiple crossings inside one accepted step
may be missed. Event callback evaluations count against `max_evals` and are
reported separately in `n_event_calls`. Samples after the event are omitted.
See the [`vsl.ode` API guide](../../ode/README.md) for callback and status
details.
