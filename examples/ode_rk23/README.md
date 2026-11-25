# Adaptive RK23 ODE event example

Integrate a harmonic oscillator until its position first crosses zero. The
example prints the localized event time/state and adaptive-step counts.

Run from the V modules directory:

```sh
cd ~/.vmodules
v run ./vsl/examples/ode_rk23/main.v
```

See the [ODE tutorial](../../docs/scientific-computing/05-odes.md) and
[`vsl.ode`](../../ode/README.md) for limitations and API details.
