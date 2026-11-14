# Golden-section minimization

This example minimizes a quadratic objective on `[-5, 5]` and prints the
termination status, best observed point, final interval, error bound, and
evaluation counts.

Run it from the V modules directory so V can resolve the local VSL clone:

```sh
cd ~/.vmodules
v run ./vsl/examples/roots_golden_section/main.v
```

The example uses the public API documented in [`vsl.roots`](../../roots/README.md).
