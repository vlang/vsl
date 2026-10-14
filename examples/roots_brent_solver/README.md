# Brent root solver

This example finds a root of `cos(x)` in the bracket `[0, 3]` and prints the
solver status, root residual, final bracket, iteration count, and callback
evaluation count.

Run it from the V modules directory so V can resolve both local clones:

```sh
cd ~/.vmodules
v run ./vsl/examples/roots_brent_solver/main.v
```

The example uses the public API documented in [`vsl.roots`](../../roots/README.md).
