# Multivariable Jacobian

Estimate the Jacobian of a two-output function at a two-coordinate input. The
result rows correspond to output values and columns to input coordinates; each
entry includes an estimated absolute error.

Run it from the V modules directory:

```sh
cd ~/.vmodules
v run ./vsl/examples/deriv_jacobian/main.v
```

See the [`vsl.deriv` API](../../deriv/README.md) for step-size and error
estimate details.
