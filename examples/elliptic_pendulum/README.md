# Elliptic pendulum

A large-angle pendulum has period `T = 4 K(m) / sqrt(g/L)` with
`m = sin(theta0/2)^2`, and its angle is given by the Jacobi `sn` function with a
quarter-period phase shift. This example uses `vsl.fun.ellipk` and `ellipj` and
compares the exact period with the small-angle approximation.

Run it from the V modules directory:

```sh
cd ~/.vmodules
v run ./vsl/examples/elliptic_pendulum/main.v
```

See the [`vsl.fun` API](../../fun/README.md) for conventions, domains, and
numerical limitations.
