# `vsl.ode`

`solve_rk23` integrates first-order systems with an adaptive Bogacki-Shampine
3(2) explicit Runge-Kutta method. It supports vector states, forward or
backward integration, error tolerances, a maximum step size, and execution
limits. The method is intended for non-stiff systems.

Set `RK23Params.output_times` to request states at intermediate times. Times
must be ordered in the integration direction and lie within the integration
interval. The solver uses cubic Hermite interpolation over accepted steps;
duplicate times are allowed. `RK23Result.sampled_times` and
`RK23Result.sampled_states` contain completed samples in the same order. If a
step/evaluation limit stops the solve early, only samples through the last
accepted step are returned.

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
assert math.abs(result.state[0] - math.e) < 1e-5
assert result.sampled_times == [0.25, 0.75]
assert math.abs(result.sampled_states[0][0] - math.exp(0.25)) < 1e-4
```

The result includes the last accepted state, scaled local error norm, function
evaluation count, accepted/rejected step counts, and a termination status.
Requested-time interpolation is opt-in and does not retain a full trajectory.
The optional `RK23Params.event_function` detects the first exact zero at an
accepted-step boundary or sign change across an accepted step. The solver
stops at that event with status `.event_detected`; it localizes the root by
bisection using the step's cubic Hermite interpolation, up to exact zero or the
adjacent representable times. An event already equal to zero at `t_start`
stops immediately. Roots that only touch zero without changing sign are not
detected, and multiple crossings within one accepted step may be missed.
Rejected steps do not invoke the event callback. Event callback evaluations
share the configured evaluation budget with derivative evaluations and are
reported separately as `n_event_calls`; `n_calls` remains the derivative
callback count. Non-finite event values stop with `.non_finite_event_value`.
Requested output samples are returned only through the localized event time.

This ODE slice does not provide stiff methods, multiple/directional events, or
event handling for roots that do not change sign.
