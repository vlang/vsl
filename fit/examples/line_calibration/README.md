# line_calibration

Representative `vsl.fit.linear` use case for **sensor calibration**.

## Scenario

You have raw readings from a sensor with bias and scale drift, and a trusted
reference instrument. We fit:

`reference = a + b * sensor_raw`

Then use `(a, b)` to calibrate future raw measurements.

## Run

```sh
v run fit/examples/line_calibration/main.v
```

## What to look at

- `a` close to expected offset bias
- `b` close to expected gain correction
- residual table to identify systematic error
- MAE (mean absolute residual) as quick quality signal
