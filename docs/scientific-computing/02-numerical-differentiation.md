# Numerical Differentiation

Learn numerical differentiation methods.

## What You'll Learn

- Finite differences
- Derivative calculation
- Accuracy considerations

## Differentiation

The scalar APIs `central`, `forward`, and `backward` return a derivative and
an estimated absolute error. `partial` estimates one component of the gradient
of a scalar-valued function.

```v
import vsl.deriv
import vsl.func

fn objective(x f64, _ []f64) f64 {
	return x * x
}

f := func.Fn.new(f: objective)
result, error_estimate := deriv.central(f, 2.0, 1e-4)
println('derivative=${result}, estimated error=${error_estimate}')
```

For vector-valued functions, `jacobian` returns a matrix shaped
`[output_length, input_length]` and a matching matrix of error estimates. The
step is scaled by each input coordinate, then refined with Richardson
extrapolation.

```v
import vsl.deriv

fn model(x []f64) []f64 {
	return [x[0] * x[0] + 3.0 * x[1], x[0] - x[1]]
}

result := deriv.jacobian(model, [2.0, 1.0], 1e-3)!
println('Jacobian=${result.values}; errors=${result.error_estimate}')
```

## Next Steps

- [Scalar derivative example](../../examples/deriv_example/)
- [Multivariable Jacobian example](../../examples/deriv_jacobian/)
