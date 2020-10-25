.. index::
   single: root finding
   single: zero finding
   single: finding roots
   single: finding zeros
   single: roots
   single: solving a nonlinear equation
   single: nonlinear equation, solutions of

****************************
One Dimensional Root-Finding
****************************

This chapter describes routines for finding roots of arbitrary
one-dimensional functions.  The library provides low level components
for a variety of iterative solvers and convergence tests.

The module :file:`vsl.roots` contains functions for the root
finding methods and related declarations.

.. index::
   single: root finding, overview

Overview
========

One-dimensional root finding algorithms can be divided into two classes,
*root bracketing* and *root polishing*.  Algorithms which proceed
by bracketing a root are guaranteed to converge.  Bracketing algorithms
begin with a bounded region known to contain a root.  The size of this
bounded region is reduced, iteratively, until it encloses the root to a
desired tolerance.  This provides a rigorous error estimate for the
location of the root.

The technique of *root polishing* attempts to improve an initial
guess to the root.  These algorithms converge only if started "close
enough" to a root, and sacrifice a rigorous error bound for speed.  By
approximating the behavior of a function in the vicinity of a root they
attempt to find a higher order improvement of an initial guess.  When the
behavior of the function is compatible with the algorithm and a good
initial guess is available a polishing algorithm can provide rapid
convergence.

In VSL both types of algorithm are available in similar frameworks.  The
user provides the function and specific parameters, and the library
provides the individual functions necessary for each of the steps.

Functions
=========

.. function:: fn brent (f vsl.Function, x1 f64, x2 f64, tol f64) ?(f64, f64)

  Find th root of :data:`f` between :data:`x1` and :data:`x1` with an accuracy
  of order :data:`tol`. The result will be the root and an upper bound of the error.

.. function:: fn newton_bisection (f vsl.FunctionFdf, x_min, x_max, tol f64, n_max int) ?f64

  Find th root of :data:`f` between :data:`x_min` and :data:`x_max` with an accuracy
  of order :data:`tol` and a maximum of n_max iterations. The result will be the found root.

  Note that the function must also compute the first derivate of the function. This function
  relies on combining Newton's approach with a bisection technique.

.. function:: fn newton (f vsl.FunctionFdf, x0 f64, x_eps f64, fx_eps f64, n_max int) ?f64

  Find the root of :data:`f` starting from :data:`x0` using Newton’s method with
  descent direction given by the inverse of the derivative,
  ie. :math:`d_k = \frac{f(x_k)}{f'(x_k)}`. Armijo’s line search is used to make sure
  :math:`|f|` decreases along the iterations. :math:`\alpha_k = max\{\gamma_j; j \geq 0\}`
  such that:

  .. math::

     |f(x_k + \alpha_k d_k)| \leq |f(x_k)|(1 - \omega \alpha_k)

  In this implementation, :math:`\omega = 10^{-4}` and :math:`\gamma = \frac{1}{2}`.
  The algorithm stops when one of the three following conditions is met:

    * the maximum number of iterations :data:`n_max` is reached
    * the last improvement over :data:`x` is smaller than :math:`x . x\_eps`
    * at the current position :math:`|f(x)| < fx\_eps`

.. function:: fn bisection(f vsl.Function, xmin f64, xmax f64, epsrel f64, epsabs f64, n_max int) ?f64

  Find the root of :data:`f` between :data:`x_min` and :data:`x_max` with the accuracy
  
  .. math::
    
     |x\_max - x\_min| < epsrel * x\_min + epsabs
    
  , or with the maximum number of iterations
  :data:`n_max`. On exit, the results is :math:`\frac{(x\_max + x\_min)}{2}`.
