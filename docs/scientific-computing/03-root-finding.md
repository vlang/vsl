# Root Finding

Learn numerical methods for finding roots.

## What You'll Learn

- Bisection method
- Root finding algorithms
- Convergence

## Bisection Method

```v ignore
import vsl.roots

fn f(x f64) f64 {
    return x * x - 2.0
}

a := 0.0
b := 2.0
// Note: Check vsl.roots module API for actual root finding functions
// root := roots.bisection(f, a, b, tol: 1e-6)
```

## Next Steps

- [Examples](../../examples/roots_bisection_solver/) - Working examples

