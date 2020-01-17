.. index::
   single: elementary functions
   single: mathematical functions, elementary

**********************
Mathematical Functions
**********************

For the development of this module, the functions present in many of the system 
libraries are taken as reference with the idea of offering them in VSL as an 
option for when they are not present.

This chapter describes basic mathematical functions.

The functions and macros described in this chapter are defined in the
module :file:`vsl.math`.

.. index::
   single: mathematical constants, defined as macros
   single: numerical constants, defined as macros
   single: constants, mathematical (defined as macros)
   single: macros for mathematical constants

Mathematical Constants
======================

.. index::
   single: e, defined as a constant
   single: pi, defined as a constant
   single: Euler's constant, defined as a constant

===================== ===================================
:macro:`e`          the base of exponentials, :math:`e`
:macro:`log2e`      the base-2 logarithm of :math:`e`, :math:`\log_2 (e)`
:macro:`log10e`     the base-10 logarithm of :math:`e`, :math:`\log_{10} (e)`
:macro:`sqrt2`      the square root of two, :math:`\sqrt 2`
:macro:`sqrt1_2`    the square root of one-half, :math:`\sqrt{1/2}`
:macro:`sqrt3`      the square root of three, :math:`\sqrt 3`
:macro:`pi`         the constant pi, :math:`\pi`
:macro:`pi_2`       pi divided by two, :math:`\pi/2`
:macro:`pi_4`       pi divided by four, :math:`\pi/4`
:macro:`sqrtpi`     the square root of pi, :math:`\sqrt\pi`
:macro:`2_sqrtpi`   two divided by the square root of pi, :math:`2/\sqrt\pi`
:macro:`1_pi`       the reciprocal of pi, :math:`1/\pi`
:macro:`2_pi`       twice the reciprocal of pi, :math:`2/\pi`
:macro:`ln10`       the natural logarithm of ten, :math:`\ln(10)`
:macro:`ln2`        the natural logarithm of two, :math:`\ln(2)`
:macro:`lnpi`       the natural logarithm of pi, :math:`\ln(\pi)`
:macro:`euler`      euler's constant, :math:`\gamma`
===================== ===================================

.. index::
   single: infinity, defined as a function
   single: IEEE infinity, defined as a function

Infinities and Not-a-number
===========================

.. function:: fn inf (s int) f64

   This function returns the IEEE representation infinity.

.. index::
   single: NaN, defined as a function
   single: Not-a-number, defined as a function
   single: IEEE NaN, defined as a function

.. function:: fn nan() f64

   This function returns the IEEE representation of the Not-a-Number symbol,
   :code:`NaN`.

.. function:: fn is_nan (x f64) bool

   This function returns 1 if :data:`x` is not-a-number.

.. function:: fn is_inf (x f64, s int) bool

.. function:: fn is_finite (x f64) bool

   This function returns 1 if :data:`x` is a real number, and 0 if it is
   infinite or not-a-number.

Elementary Functions
====================

The following routines provide portable implementations of functions
in pure V.

.. index::
   single: log1p
   single: logarithm, computed accurately near 1

.. function:: fn log1p (x f64) f64

   This function computes the value of :math:`\log(1+x)` in a way that is
   accurate for small :data:`x`. It provides an alternative to the math
   function :code:`log1p(x)`.

.. index::
   single: expm1
   single: exponential, difference from 1 computed accurately

.. function:: fn expm1 (x f64) f64

   This function computes the value of :math:`\exp(x)-1` in a way that is
   accurate for small :data:`x`. It provides an alternative to the math
   function :code:`expm1(x)`.

.. index::
   single: hypot
   single: euclidean distance function, hypot
   single: length, computed accurately using hypot

.. function:: fn hypot (x, y f64) f64

   This function computes the value of
   :math:`\sqrt{x^2 + y^2}` in a way that avoids overflow. It provides an
   alternative to the BSD math function :code:`hypot(x,y)`.

.. index::
   single: euclidean distance function, hypot3
   single: length, computed accurately using hypot3

.. function:: fn hypot3 (x, y, z f64) f64

   This function computes the value of
   :math:`\sqrt{x^2 + y^2 + z^2}` in a way that avoids overflow.

.. index::
   single: acosh
   single: hyperbolic cosine, inverse
   single: inverse hyperbolic cosine

.. function:: fn acosh (x f64) f64

   This function computes the value of :math:`\arccosh{(x)}`. It provides an
   alternative to the standard math function :code:`acosh(x)`.

.. index::
   single: asinh
   single: hyperbolic sine, inverse
   single: inverse hyperbolic sine

.. function:: fn asinh (x f64) f64

   This function computes the value of :math:`\arcsinh{(x)}`. It provides an
   alternative to the standard math function :code:`asinh(x)`.

.. index::
   single: atanh
   single: hyperbolic tangent, inverse
   single: inverse hyperbolic tangent

.. function:: fn atanh (x f64) f64

   This function computes the value of :math:`\arctanh{(x)}`. It provides an
   alternative to the standard math function :code:`atanh(x)`.

.. index:: ldexp

.. function:: fn ldexp (x f64, e int) f64

   This function computes the value of :math:`x * 2^e`. It provides an
   alternative to the standard math function :code:`ldexp(x,e)`.

.. index:: frexp

.. function:: fn frexp (x f64) (f64, int)

   This function splits the number :data:`x` into its normalized fraction
   :math:`f` and exponent :math:`e`, such that :math:`x = f * 2^e` and
   :math:`0.5 <= f < 1`. The function returns :math:`f` and stores the
   exponent in :math:`e`. If :math:`x` is zero, both :math:`f` and :math:`e`
   are set to zero. This function provides an alternative to the standard
   math function :code:`frexp(x, e)`.

.. index:: sqrt

.. function:: fn sqrt (x f64) f64

  This function returns the square root of the number :data:`x`,
  :math:`\sqrt z`. The branch cut is the negative real axis. The result
  always lies in the right half of the plane.

.. index::
  single: pow
  single: exp

.. function:: fn pow (x, a f64) f64

  The function returns the number :data:`x` raised to the double-precision
  power :data:`a`, :math:`x^a`. This is computed as :math:`\exp(\log(x)*a)`
  using logarithms and exponentials.

.. function:: fn exp (x f64) f64

  This function returns the exponential of the number
  :data:`x`, :math:`\exp(x)`.

.. index:: log

.. function:: fn log (x f64) f64

  This function returns the natural logarithm (base :math:`e`) of
  the number :data:`x`, :math:`\log(x)`.  The branch cut is the
  negative real axis.

.. function:: fn log10 (x f64) f64

  This function returns the base-10 logarithm of
  the number :data:`x`, :math:`\log_{10} (x)`.

.. function:: fn log_n (x, b f64) f64

  This function returns the base-:data:`b` logarithm of the double-precision
  number :data:`x`, :math:`\log_b(x)`. This quantity is computed as the ratio
  :math:`\log(x)/\log(b)`.

.. index:: trigonometric functions

Trigonometric Functions
=======================

.. index::
  single: sine

.. function:: fn sin (x f64) f64

  This function returns the sine of the number :data:`x`, :math:`\sin(x)`.

.. index:: cosine

.. function:: fn cos (x f64) f64

  This function returns the cosine of the number :data:`x`, :math:`\cos(x)`.

.. index:: tangent

.. function:: fn doublean (x f64) f64

  This function returns the tangent of the number :data:`x`, :math:`\tan(x)`.

.. function:: fn sec (x f64) f64

  This function returns the secant of the number :data:`x`,
  :math:`\sec(x) = 1/\cos(x)`.

.. function:: fn csc (x f64) f64

  This function returns the cosecant of the number :data:`x`,
  :math:`\csc(x) = 1/\sin(x)`.

.. function:: fn cot (x f64) f64

  This function returns the cotangent of the number :data:`x`,
  :math:`\cot(x) = 1/\tan(x)`.

.. index:: inverse trigonometric functions

Inverse Trigonometric Functions
=======================================

.. function:: fn asin (x f64) f64

  This function returns the arcsine of the number :data:`x`, :math:`\arcsin(x)`.

.. function:: fn acos (x f64) f64

  This function returns the arccosine of the number :data:`x`,
  :math:`\arccos(x)`.

.. function:: fn atan (x f64) f64

  This function returns the arctangent of the number
  :data:`x`, :math:`\arctan(x)`.

.. function:: fn asec (x f64) f64

  This function returns the arcsecant of the number :data:`x`,
  :math:`\arcsec(x) = \arccos(1/x)`.

.. function:: fn acsc (x f64) f64

  This function returns the arccosecant of the number :data:`x`,
  :math:`\arccsc(x) = \arcsin(1/x)`.

.. function:: fn acot (x f64) f64

  This function returns the arccotangent of the number :data:`x`,
  :math:`\arccot(x) = \arctan(1/x)`.

.. index::
  single: hyperbolic functions

Hyperbolic Functions
====================

.. function:: fn sinh (x f64) f64

  This function returns the hyperbolic sine of the number
  :data:`x`, :math:`\sinh(x) = (\exp(x) - \exp(-x))/2`.

.. function:: fn cosh (x f64) f64

  This function returns the hyperbolic cosine of the number
  :data:`x`, :math:`\cosh(x) = (\exp(x) + \exp(-x))/2`.

.. function:: fn doubleanh (x f64) f64

  This function returns the hyperbolic tangent of the number
  :data:`x`, :math:`\tanh(x) = \sinh(x)/\cosh(x)`.

.. function:: fn sech (x f64) f64

  This function returns the hyperbolic secant of the double-precision
  number :data:`x`, :math:`\sech(x) = 1/\cosh(x)`.

.. function:: fn csch (x f64) f64

  This function returns the hyperbolic cosecant of the double-precision
  number :data:`x`, :math:`\csch(x) = 1/\sinh(x)`.

.. function:: fn coth (x f64) f64

  This function returns the hyperbolic cotangent of the double-precision
  number :data:`x`, :math:`\coth(x) = 1/\tanh(x)`.

.. index::
  single: inverse hyperbolic functions

Inverse Hyperbolic Functions
============================

.. function:: fn asinh (x f64) f64

  This function returns the hyperbolic arcsine of the
  number :data:`x`, :math:`\arcsinh(x)`.

.. function:: fn acosh (x f64) f64

  This function returns the hyperbolic arccosine of the double-precision
  number :data:`x`, :math:`\arccosh(x)`.

.. function:: fn atanh (x f64) f64

  This function returns the hyperbolic arctangent of the double-precision
  number :data:`x`, :math:`\arctanh(x)`.

.. function:: fn asech (x f64) f64

  This function returns the hyperbolic arcsecant of the double-precision
  number :data:`x`, :math:`\arcsech(x) = \arccosh(1/x)`.

.. function:: fn acsch (x f64) f64

  This function returns the hyperbolic arccosecant of the double-precision
  number :data:`x`, :math:`\arccsch(x) = \arcsinh(1/x)`.

.. function:: fn acoth (x f64) f64

  This function returns the hyperbolic arccotangent of the double-precision
  number :data:`x`, :math:`\arccoth(x) = \arctanh(1/x)`.

Maximum and Minimum functions
=============================

.. index:: maximum of two numbers

.. function:: fn max(a, b f64) f64

   This function returns the maximum of :data:`a` and :data:`b`.

.. index:: minimum of two numbers

.. function:: fn min(a, b f64) f64

   This function returns the minimum of :data:`a` and :data:`b`.

