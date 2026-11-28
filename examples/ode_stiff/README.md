# Stiff ODE solve

Integrate a classic stiff test problem with `vsl.ode.solve_implicit_euler` at
three tolerances. The exact solution is `cos(t)`, so the example reports the
actual error alongside accepted steps and callback counts.

Run it from the V modules directory:

```sh
cd ~/.vmodules
v run ./vsl/examples/ode_stiff/main.v
```

See the [`vsl.ode` API](../../ode/README.md) for status values, step controls,
and the distinction between this A-stable first-order method and the non-stiff
RK23 solver.
