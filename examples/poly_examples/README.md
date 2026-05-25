# poly_examples

Demonstrates core `vsl.poly` features:

- polynomial evaluation (`eval`)
- arithmetic operations (`add`, `subtract`, `multiply`)
- root solvers (`solve_quadratic`, `solve_cubic`)
- metadata helpers (`degree`, odd/even coefficient sums)

## Run

```sh
v run examples/poly_examples/main.v
```

## Notes

- Coefficients are represented in ascending order:
  - `[a0, a1, a2, ...]` means `a0 + a1*x + a2*x^2 + ...`
