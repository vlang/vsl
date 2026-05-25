# trend_quality

Representative `vsl.fit.linear_sigma` use case for **trend estimation with uncertainty**.

## Scenario

Given noisy daily KPI observations, we estimate:

`kpi(day) = a + b * day`

and inspect both model parameters and quality indicators.

## Run

```sh
v run fit/examples/trend_quality/main.v
```

## What to look at

- `b`: estimated daily trend (growth/decay rate)
- `sigma_b`: uncertainty of the trend estimate
- `chi^2`: residual sum of squares indicator
- `rmse`: average prediction error scale in original KPI units
