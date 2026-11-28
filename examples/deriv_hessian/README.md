# Hessian (second derivatives)

Estimate the symmetric Hessian matrix of second partial derivatives of a
scalar-valued function at a two-coordinate input. Each entry includes an
estimated absolute error from Richardson extrapolation.

Run it from the V modules directory:

```sh
cd ~/.vmodules
v run ./vsl/examples/deriv_hessian/main.v
```

See the [`vsl.deriv` API](../../deriv/README.md) for step-size and error
estimate details.
