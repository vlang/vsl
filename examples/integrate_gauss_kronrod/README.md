# Adaptive Gauss-Kronrod integration

This example integrates `sin(20x)` over `[0, 1]` and reports the estimated
error, interval count, and callback evaluations.

Run it from the V modules directory so V can resolve the local VSL clone:

```sh
cd ~/.vmodules
v run ./vsl/examples/integrate_gauss_kronrod/main.v
```

See the [integration tutorial](../../docs/scientific-computing/04-integration.md)
and [`vsl.integrate`](../../integrate/README.md) for API details.
