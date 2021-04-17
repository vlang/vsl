# Polynomials

This chapter describes functions for evaluating and solving polynomials.
There are routines for finding real and complex roots of quadratic and
cubic equations using analytic methods. An iterative polynomial solver
is also available for finding the roots of general polynomials with real
coefficients (of any order). The functions are declared in the module `vsl.poly`.

# Polynomial Evaluation

The functions described here evaluate the polynomial

```
P(x) = c[0] + c[1] x + c[2] x^2 + . . . + c[len-1] x^(len-1)
```

using Horner's method for stability.

```v ignore
fn eval(c []f64, x f64) f64
```

This function evaluates a polynomial with real coefficients for the real variable `x`.

```v ignore
fn eval_derivs(c []f64, x f64, lenres u64) []f64
```

This function evaluates a polynomial and its derivatives storing the
results in the array `res` of size `lenres`. The output array
contains the values of `d^k P(x)/d x^k` for the specified value of
`x` starting with `k = 0`.

# Quadratic Equations

```v ignore
fn solve_quadratic(a f64, b f64, c f64) []f64
```

This function finds the real roots of the quadratic equation,

```
a x^2 + b x + c = 0
```

The number of real roots (either zero, one or two) is returned, and
their locations are are returned as `[ x0, x1 ]`. If no real roots
are found then `[]` is returned. If one real root
is found (i.e. if `a=0`) then it is are returned as `[ x0 ]`. When two
real roots are found they are are returned as `[ x0, x1 ]` in
ascending order. The case of coincident roots is not considered
special. For example `(x-1)^2=0` will have two roots, which happen
to have exactly equal values.

The number of roots found depends on the sign of the discriminant
`b^2 - 4 a c`. This will be subject to rounding and cancellation
errors when computed in double precision, and will also be subject to
errors if the coefficients of the polynomial are inexact. These errors
may cause a discrete change in the number of roots. However, for
polynomials with small integer coefficients the discriminant can always
be computed exactly.

# Cubic Equations

```v ignore
fn solve_cubic(a f64, b f64, c f64) []f64
```

This function finds the real roots of the cubic equation,

```
x^3 + a x^2 + b x + c = 0
```

with a leading coefficient of unity. The number of real roots (either
one or three) is returned, and their locations are returned as `[ x0, x1, x2 ]`.
If one real root is found then only `[ x0 ]`
is returned. When three real roots are found they are returned as
`[ x0, x1, x2 ]` in ascending order. The case of
coincident roots is not considered special. For example, the equation
`(x-1)^3=0` will have three roots with exactly equal values. As
in the quadratic case, finite precision may cause equal or
closely-spaced real roots to move off the real axis into the complex
plane, leading to a discrete change in the number of real roots.
