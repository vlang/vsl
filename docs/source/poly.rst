.. index::
   single: polynomials, roots of

***********
Polynomials
***********

.. include:: include.rst

This chapter describes functions for evaluating and solving polynomials.
There are routines for finding real and complex roots of quadratic and
cubic equations using analytic methods.  An iterative polynomial solver
is also available for finding the roots of general polynomials with real
coefficients (of any order).  The functions are declared in the module :file:`vsl.poly`.

.. index::
   single: polynomial evaluation
   single: evaluation of polynomials

Polynomial Evaluation
=====================

The functions described here evaluate the polynomial 

.. only:: not texinfo

   .. math::

      P(x) = c[0] + c[1] x + c[2] x^2 + \dots + c[len-1] x^{len-1}

.. only:: texinfo

   P(x) = c[0] + c[1] x + c[2] x^2 + ... + c[len-1] x^{len-1}
   
using Horner's method for stability.

.. function:: fn eval(c []f64, x f64) f64

   This function evaluates a polynomial with real coefficients for the real variable :data:`x`.

.. function:: eval_derivs(c []f64, x f64, lenres u64) []f64

   This function evaluates a polynomial and its derivatives storing the
   results in the array :data:`res` of size :data:`lenres`.  The output array
   contains the values of :math:`d^k P(x)/d x^k` for the specified value of
   :data:`x` starting with :math:`k = 0`.

Quadratic Equations
===================

.. function:: solve_quadratic(a f64, b f64, c f64) []f64

   This function finds the real roots of the quadratic equation,

   .. math::

      a x^2 + b x + c = 0

   The number of real roots (either zero, one or two) is returned, and
   their locations are  are returned as :data:`[ x0, x1 ]`.  If no real roots
   are found then :data:`[]` is returned.  If one real root
   is found (i.e. if :math:`a=0`) then it is are returned as :data:`[ x0 ]`.  When two
   real roots are found they are  are returned as :data:`[ x0, x1 ]` in
   ascending order.  The case of coincident roots is not considered
   special.  For example :math:`(x-1)^2=0` will have two roots, which happen
   to have exactly equal values.

   The number of roots found depends on the sign of the discriminant
   :math:`b^2 - 4 a c`.  This will be subject to rounding and cancellation
   errors when computed in double precision, and will also be subject to
   errors if the coefficients of the polynomial are inexact.  These errors
   may cause a discrete change in the number of roots.  However, for
   polynomials with small integer coefficients the discriminant can always
   be computed exactly.

.. index::
   single: cubic equation, solving

Cubic Equations
===============

.. function:: solve_cubic(a f64, b f64, c f64) []f64

   This function finds the real roots of the cubic equation,

   .. math::

      x^3 + a x^2 + b x + c = 0

   with a leading coefficient of unity.  The number of real roots (either
   one or three) is returned, and their locations are returned as :data:`[ x0, x1, x2 ]`.
   If one real root is found then only :data:`[ x0 ]`
   is returned.  When three real roots are found they are returned as
   :data:`[ x0, x1, x2 ]` in ascending order.  The case of
   coincident roots is not considered special.  For example, the equation
   :math:`(x-1)^3=0` will have three roots with exactly equal values.  As
   in the quadratic case, finite precision may cause equal or
   closely-spaced real roots to move off the real axis into the complex
   plane, leading to a discrete change in the number of real roots.
