# Linear Fit

`vsl.fit` provides simple linear regression utilities for the model:

`y(x) = a + b*x`

Current API:

- `linear(x, y) -> (a, b)`
- `linear_sigma(x, y) -> (a, b, sigma_a, sigma_b, chi_2)`

## When to use each function

- Use `linear` when you only need intercept and slope.
- Use `linear_sigma` when you also need uncertainty estimates and fit quality.

## Quick usage

```v
import vsl.fit

x := [1.0, 2.0, 3.0, 4.0]
y := [2.1, 4.0, 6.2, 8.1]

a, b := fit.linear(x, y)
println('intercept=${a}, slope=${b}')

a2, b2, sigma_a, sigma_b, chi2 := fit.linear_sigma(x, y)
println('a=${a2} b=${b2} sigma_a=${sigma_a} sigma_b=${sigma_b} chi2=${chi2}')
```

## Examples

Representative examples live under [`fit/examples`](./examples):

- `line_calibration`: calibrating a biased sensor against a reference.
- `trend_quality`: fitting a trend and inspecting uncertainty / chi-square.
