# Brent scalar minimization

This example minimizes a quadratic objective on `[-5, 5]` and reports the
termination status, best observed point, final interval, error bound, and
evaluation counts.

Run it from the V modules directory so V can resolve the local VSL clone:

```sh
cd ~/.vmodules
v run ./vsl/examples/roots_brent_minimizer/main.v
```

The example uses the public API documented in [`vsl.roots`](../../roots/README.md).
