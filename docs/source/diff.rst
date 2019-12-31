.. index::
   single: differentiation of functions, numeric
   single: functions, numerical differentiation
   single: derivatives, calculating numerically
   single: numerical derivatives
   single: slope, see numerical derivative

*************************
Numerical Differentiation
*************************

The functions described in this chapter compute numerical derivatives by
finite differencing. An adaptive algorithm is used to find the best
choice of finite difference and to estimate the error in the derivative.

Again, the development of this module is inspired by the same present in GSL 
looking to adapt it completely to the practices and tools present in VSL.

The functions described in this chapter are declared in the module :file:`vsl.deriv`.

Functions
=========

.. function:: fn central (f vsl.Function, x, h f64) (f64, f64)

   This function computes the numerical derivative of the function :data:`f`
   at the point :data:`x` using an adaptive central difference algorithm with
   a step-size of :data:`h`.   The derivative is returned in :data:`result` and an
   estimate of its absolute error is returned in :data:`abserr`.

   The initial value of :data:`h` is used to estimate an optimal step-size,
   based on the scaling of the truncation error and round-off error in the
   derivative calculation.  The derivative is computed using a 5-point rule
   for equally spaced abscissae at :math:`x - h`, :math:`x - h/2`, :math:`x`,
   :math:`x + h/2`, :math:`x+h`, with an error estimate taken from the difference
   between the 5-point rule and the corresponding 3-point rule :math:`x-h`,
   :math:`x`, :math:`x+h`.  Note that the value of the function at :math:`x`
   does not contribute to the derivative calculation, so only 4-points are
   actually used.

.. function:: fn forward (f vsl.Function, x, h f64) (f64, f64)

   This function computes the numerical derivative of the function :data:`f`
   at the point :data:`x` using an adaptive forward difference algorithm with
   a step-size of :data:`h`. The function is evaluated only at points greater
   than :data:`x`, and never at :data:`x` itself.  The derivative is returned in
   :data:`result` and an estimate of its absolute error is returned in
   :data:`abserr`.  This function should be used if :math:`f(x)` has a
   discontinuity at :data:`x`, or is undefined for values less than :data:`x`.

   The initial value of :data:`h` is used to estimate an optimal step-size,
   based on the scaling of the truncation error and round-off error in the
   derivative calculation.  The derivative at :math:`x` is computed using an
   "open" 4-point rule for equally spaced abscissae at :math:`x+h/4`,
   :math:`x + h/2`, :math:`x + 3h/4`, :math:`x+h`, with an error estimate taken
   from the difference between the 4-point rule and the corresponding
   2-point rule :math:`x+h/2`, :math:`x+h`.

.. function:: fn backward (f vsl.Function, x, h f64) (f64, f64)

   This function computes the numerical derivative of the function :data:`f`
   at the point :data:`x` using an adaptive backward difference algorithm
   with a step-size of :data:`h`. The function is evaluated only at points
   less than :data:`x`, and never at :data:`x` itself.  The derivative is
   returned in :data:`result` and an estimate of its absolute error is
   returned in :data:`abserr`.  This function should be used if :math:`f(x)`
   has a discontinuity at :data:`x`, or is undefined for values greater than
   :data:`x`.

   This function is equivalent to calling :func:`deriv.forward` with a
   negative step-size.

Examples
========

The following code estimates the derivative of the function
:math:`f(x) = x^{3/2}`
at :math:`x = 2` and at :math:`x = 0`.  The function :math:`f(x)` is
undefined for :math:`x < 0` so the derivative at :math:`x=0` is computed
using :func:`deriv.forward`.

.. include:: examples/diff.v
   :code:

Here is the output of the program,

.. include:: examples/diff.txt
   :code:

References and Further Reading
==============================

This work is a spiritual descendent of the Differentiation module in GSL.
