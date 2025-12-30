# Numerical Differentiation

Learn numerical differentiation methods.

## What You'll Learn

- Finite differences
- Derivative calculation
- Accuracy considerations

## Differentiation

```v ignore
import vsl.deriv

fn f(x f64) f64 {
    return x * x
}

x := 2.0
// Numerical derivative
mut result, mut abserr := deriv.central(f, x, 1e-8)
```

## Next Steps

- [Examples](../../examples/deriv_example/) - Working examples

