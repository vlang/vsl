# Polynomials

This chapter describes functions for evaluating and solving polynomials.
There are routines for finding real and complex roots of quadratic and
cubic equations using analytic methods. An iterative polynomial solver
is also available for finding the roots of general polynomials with real
coefficients (of any order). The functions are declared in the module `vsl.poly`.

## Polynomial Evaluation

The functions described here evaluate the polynomial

```console
P(x) = c[0] + c[1] x + c[2] x^2 + . . . + c[len-1] x^(len-1)
```

using Horner's method for stability.

```v ignore
fn eval(c []f64, x f64) f64
```

This function evaluates a polynomial and its derivatives storing the
results in the array `res` of size `lenres`. The output array
contains the values of `d^k P(x)/d x^k` for the specified value of
`x` starting with `k = 0`.

```v ignore
fn eval_derivs(c []f64, x f64, lenres u64) []f64
```

This function evaluates a polynomial and its derivatives, storing the results in the array `res` of size `lenres`. The output array contains the values of `d^k P(x)/d x^k` for the specified value of `x`, starting with `k = 0`.

## Quadratic Equations

```v ignore
fn solve_quadratic(a f64, b f64, c f64) []f64
```

This function finds the real roots of the quadratic equation,

```console
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

## Cubic Equations

```v ignore
fn solve_cubic(a f64, b f64, c f64) []f64
```

This function finds the real roots of the cubic equation,

```console
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

## Companion Matrix

```v ignore
fn companion_matrix(a []f64) [][]f64
```

Creates a companion matrix for the polynomial

```console
P(x) = a_n * x^n + a_{n-1} * x^{n-1} + ... + a_1 * x + a_0
```

The companion matrix `C` is defined as:

```
[0 0 0 ... 0 -a_0/a_n]
[1 0 0 ... 0 -a_1/a_n]
[0 1 0 ... 0 -a_2/a_n]
[. . . ... . ........]
[0 0 0 ... 1 -a_{n-1}/a_n]
```

## Balanced Companion Matrix

```v ignore
fn balance_companion_matrix(cm [][]f64) [][]f64
```

Balances a companion matrix `C` to improve numerical stability. Uses an iterative scaling process to make the row and column norms as close to each other as possible. The output is a balanced matrix `B` such that `D^(-1)CD = B`, where `D` is a diagonal matrix.

## Polynomial Operations

```v ignore
fn add(a []f64, b []f64) []f64
```

Adds two polynomials: 

```console
(a_n * x^n + ... + a_0) + (b_m * x^m + ... + b_0)
```

Returns the result as `[a_0 + b_0, a_1 + b_1, ..., max(a_k, b_k), ...]`.

```v ignore
fn subtract(a []f64, b []f64) []f64
```

Subtracts two polynomials:

```console
(a_n * x^n + ... + a_0) - (b_m * x^m + ... + b_0)
```

Returns the result as `[a_0 - b_0, a_1 - b_1, ..., a_k - b_k, ...]`.

```v ignore
fn multiply(a []f64, b []f64) []f64
```

Multiplies two polynomials:

```console
(a_n * x^n + ... + a_0) * (b_m * x^m + ... + b_0)
```

Returns the result as `[c_0, c_1, ..., c_{n+m}]` where `c_k = ∑_{i+j=k} a_i * b_j`.

```v ignore
fn divide(a []f64, b []f64) ([]f64, []f64)
```

Divides two polynomials:

```console
(a_n * x^n + ... + a_0) / (b_m * x^m + ... + b_0)
```

Uses polynomial long division algorithm. Returns `(q, r)` where `q` is the quotient and `r` is the remainder such that `a(x) = b(x) * q(x) + r(x)` and `degree(r) < degree(b)`.
