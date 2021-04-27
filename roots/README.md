# One Dimensional Root-Finding

The module `vsl.roots` contains functions for the root finding methods and related declarations.

## Functions

```v ignore
fn brent (f func.Fn, x1, x2, tol f64) ?(f64, f64)
```

Find th root of `f` between `x1` and `x1` with an accuracy
of order `tol`. The result will be the root and an upper bound of the error.

```v ignore
fn newton_bisection (f func.FnFdf, x_min, x_max, tol f64, n_max int) ?f64
```

Find th root of `f` between `x_min` and `x_max` with an accuracy
of order `tol` and a maximum of n_max iterations. The result will be the found root.

Note that the function must also compute the first derivate of the function. This function
relies on combining Newton's approach with a bisection technique.

```v ignore
fn newton (f func.FnFdf, x0, x_eps, fx_eps f64, n_max int) ?f64
```

Find the root of `f` starting from `x0` using Newton’s method with
descent direction given by the inverse of the derivative.
The algorithm stops when one of the three following conditions is met:

- the maximum number of iterations `n_max` is reached
- the last improvement over `x` is smaller than `x . x_eps`
- at the current position `|f(x)| < fx_eps`

```v ignore
fn bisection(f func.Fn, xmin, xmax, epsrel, epsabs f64, n_max int) ?f64
```

Find the root of `f` between `x_min` and `x_max` with the accuracy
`|x_max - x_min| < epsrel * x_min + epsabs`,
or with the maximum number of iterations `n_max`.

On exit, the results is `(x_max + x_min) / 2`.

## Usage example

```v
module main

import vsl.func
import vsl.roots
import vsl.vmath

const (
	epsabs = 0.0001
	epsrel = 0.00001
	n_max  = 100
)

fn cos(x f64, _ []f64) f64 {
	return vmath.cos(x)
}

fn main() {
	func := func.new_func(f: cos)
	result := roots.bisection(func, 0.0, 3.0, epsrel, epsabs, n_max) ?
}
```

`result` will be `vmath.pi / 2.00`
