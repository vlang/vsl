.. index:: complex numbers

***************
Complex Numbers
***************

.. FIXME: this still needs to be
.. done for the csc, sec, cot, csch, sech, coth functions

The complex types, functions and arithmetic operations are defined in
the module :file:`vsl.math.complex`.

.. index::
   single: representations of complex numbers
   single: polar form of complex numbers
   single: Complex

Representation of complex numbers
=================================

Complex numbers are represented using the type :code:`Complex`. The
internal representation of this type may vary across platforms and
should not be accessed directly. The functions and macros described
below allow complex numbers to be manipulated in a portable way.

For reference, the default form of the :code:`Complex` type is
given by the following struct::

   pub struct Complex {
      pub:
         re f64
         im f64
   }

.. function:: fn complex (double x, double y) Complex

   This function uses the rectangular Cartesian components
   :math:`(x,y)` to return the complex number :math:`z = x + y i`.
   An inline version of this function is used when :macro:`HAVE_INLINE`
   is defined.

.. function:: fn complex_polar (double r, double theta) Complex

   This function returns the complex number :math:`z = r \exp(i \theta) = r
   (\cos(\theta) + i \sin(\theta))` from the polar representation
   (:data:`r`, :data:`theta`).

.. macro::
   creal (z)
   cimag (z)

   These macros return the real and imaginary parts of the complex number
   :data:`z`.

Properties of complex numbers
=============================

.. index:: argument of complex number

.. function:: fn (c Complex) arg () f64

   This function returns the argument of the complex number :data:`z`,
   :math:`\arg(z)`, where :math:`-\pi < \arg(z) <= \pi`.

.. index:: magnitude of complex number

.. function:: fn (c Complex) abs () f64

   This function returns the magnitude of the complex number :data:`z`, :math:`|z|`.

.. index:: complex arithmetic

Complex arithmetic operators
============================

.. function:: fn (c1 Complex) add (c2 Complex) Complex

   This function returns the sum of the complex numbers :data:`a` and
   :data:`b`, :math:`z=a+b`.

.. function:: fn (c1 Complex) sub (c2 Complex) Complex

   This function returns the difference of the complex numbers :data:`a` and
   :data:`b`, :math:`z=a-b`.

.. function:: fn (c1 Complex) mul (c2 Complex) Complex

   This function returns the product of the complex numbers :data:`a` and
   :data:`b`, :math:`z=ab`.

.. function:: fn (c1 Complex) div (c2 Complex) Complex

   This function returns the quotient of the complex numbers :data:`a` and
   :data:`b`, :math:`z=a/b`.

.. index:: conjugate of complex number

.. function:: fn (c Complex) conjugate () Complex

   This function returns the complex conjugate of the complex number
   :data:`z`, :math:`z^* = x - y i`.

Elementary Complex Functions
============================

.. index:: square root of complex number

.. function:: fn (c Complex) sqrt () Complex

   This function returns the square root of the complex number :data:`z`,
   :math:`\sqrt z`. The branch cut is the negative real axis. The result
   always lies in the right half of the complex plane.

.. function:: fn sqrt_real (x f64) Complex

   This function returns the complex square root of the real number
   :data:`x`, where :data:`x` may be negative.

.. index::
   single: power of complex number
   single: exponentiation of complex number

.. function:: fn (c Complex) cpow (p Complex) Complex

   The function returns the complex number :data:`z` raised to the complex
   power :data:`a`, :math:`z^a`. This is computed as :math:`\exp(\log(z)*a)`
   using complex logarithms and complex exponentials.

.. function:: fn (c Complex) pow (n f64) Complex

   This function returns the complex number :data:`z` raised to the real
   power :data:`x`, :math:`z^x`.

.. function:: fn (c Complex) exp () Complex

   This function returns the complex exponential of the complex number
   :data:`z`, :math:`\exp(z)`.

.. index:: logarithm of complex number

.. function:: fn (c Complex) ln () Complex

   This function returns the complex natural logarithm (base :math:`e`) of
   the complex number :data:`z`, :math:`\log(z)`.  The branch cut is the
   negative real axis.

.. function:: fn (c Complex) log (base Complex) Complex

.. index:: trigonometric functions of complex numbers

Complex Trigonometric Functions
===============================

.. index::
   single: sin, of complex number

.. function:: fn (c Complex) sin () Complex

   This function returns the complex sine of the complex number :data:`z`,
   :math:`\sin(z) = (\exp(iz) - \exp(-iz))/(2i)`.

.. index:: cosine of complex number

.. function:: fn (c Complex) cos () Complex

   This function returns the complex cosine of the complex number :data:`z`,
   :math:`\cos(z) = (\exp(iz) + \exp(-iz))/2`.

.. index:: tangent of complex number

.. function:: fn (c Complex) tan () Complex

   This function returns the complex tangent of the complex number :data:`z`,
   :math:`\tan(z) = \sin(z)/\cos(z)`.

.. function:: fn (c Complex) sec () Complex

   This function returns the complex secant of the complex number :data:`z`,
   :math:`\sec(z) = 1/\cos(z)`.

.. function:: fn (c Complex) csc () Complex

   This function returns the complex cosecant of the complex number :data:`z`,
   :math:`\csc(z) = 1/\sin(z)`.

.. function:: fn (c Complex) cot () Complex

   This function returns the complex cotangent of the complex number :data:`z`,
   :math:`\cot(z) = 1/\tan(z)`.

.. index:: inverse complex trigonometric functions

Inverse Complex Trigonometric Functions
=======================================

.. function:: fn (c Complex) asin () Complex

   This function returns the complex arcsine of the complex number :data:`z`,
   :math:`\arcsin(z)`. The branch cuts are on the real axis, less than :math:`-1`
   and greater than :math:`1`.

.. function:: fn asin_real (double z) Complex

   This function returns the complex arcsine of the real number :data:`z`,
   :math:`\arcsin(z)`. For :math:`z` between :math:`-1` and :math:`1`, the
   function returns a real value in the range :math:`[-\pi/2,\pi/2]`. For
   :math:`z` less than :math:`-1` the result has a real part of :math:`-\pi/2`
   and a positive imaginary part.  For :math:`z` greater than :math:`1` the
   result has a real part of :math:`\pi/2` and a negative imaginary part.

.. function:: fn (c Complex) acos () Complex

   This function returns the complex arccosine of the complex number :data:`z`,
   :math:`\arccos(z)`. The branch cuts are on the real axis, less than :math:`-1`
   and greater than :math:`1`.

.. function:: fn acos_real (double z) Complex

   This function returns the complex arccosine of the real number :data:`z`,
   :math:`\arccos(z)`. For :math:`z` between :math:`-1` and :math:`1`, the
   function returns a real value in the range :math:`[0,\pi]`. For :math:`z`
   less than :math:`-1` the result has a real part of :math:`\pi` and a
   negative imaginary part.  For :math:`z` greater than :math:`1` the result
   is purely imaginary and positive.

.. function:: fn (c Complex) atan () Complex

   This function returns the complex arctangent of the complex number
   :data:`z`, :math:`\arctan(z)`. The branch cuts are on the imaginary axis,
   below :math:`-i` and above :math:`i`.

.. function:: fn (c Complex) asec () Complex

   This function returns the complex arcsecant of the complex number :data:`z`,
   :math:`\arcsec(z) = \arccos(1/z)`.

.. function:: fn asec_real (double z) Complex

   This function returns the complex arcsecant of the real number :data:`z`,
   :math:`\arcsec(z) = \arccos(1/z)`.

.. function:: fn (c Complex) acsc () Complex

   This function returns the complex arccosecant of the complex number :data:`z`,
   :math:`\arccsc(z) = \arcsin(1/z)`.

.. function:: fn acsc_real (double z) Complex

   This function returns the complex arccosecant of the real number :data:`z`,
   :math:`\arccsc(z) = \arcsin(1/z)`.

.. function:: fn (c Complex) acot () Complex

   This function returns the complex arccotangent of the complex number :data:`z`,
   :math:`\arccot(z) = \arctan(1/z)`.

.. index::
   single: hyperbolic functions, complex numbers

Complex Hyperbolic Functions
============================

.. function:: fn (c Complex) sinh () Complex

   This function returns the complex hyperbolic sine of the complex number
   :data:`z`, :math:`\sinh(z) = (\exp(z) - \exp(-z))/2`.

.. function:: fn (c Complex) cosh () Complex

   This function returns the complex hyperbolic cosine of the complex number
   :data:`z`, :math:`\cosh(z) = (\exp(z) + \exp(-z))/2`.

.. function:: fn (c Complex) tanh () Complex

   This function returns the complex hyperbolic tangent of the complex number
   :data:`z`, :math:`\tanh(z) = \sinh(z)/\cosh(z)`.

.. function:: fn (c Complex) sech () Complex

   This function returns the complex hyperbolic secant of the complex
   number :data:`z`, :math:`\sech(z) = 1/\cosh(z)`.

.. function:: fn (c Complex) csch () Complex

   This function returns the complex hyperbolic cosecant of the complex
   number :data:`z`, :math:`\csch(z) = 1/\sinh(z)`.

.. function:: fn (c Complex) coth () Complex

   This function returns the complex hyperbolic cotangent of the complex
   number :data:`z`, :math:`\coth(z) = 1/\tanh(z)`.

.. index::
   single: inverse hyperbolic functions, complex numbers

Inverse Complex Hyperbolic Functions
====================================

.. function:: fn (c Complex) asinh () Complex

   This function returns the complex hyperbolic arcsine of the
   complex number :data:`z`, :math:`\arcsinh(z)`.  The branch cuts are on the
   imaginary axis, below :math:`-i` and above :math:`i`.

.. function:: fn (c Complex) acosh () Complex

   This function returns the complex hyperbolic arccosine of the complex
   number :data:`z`, :math:`\arccosh(z)`.  The branch cut is on the real
   axis, less than :math:`1`.  Note that in this case we use the negative
   square root in formula 4.6.21 of Abramowitz & Stegun giving
   :math:`\arccosh(z)=\log(z-\sqrt{z^2-1})`.

.. function:: fn acosh_real (double z) Complex

   This function returns the complex hyperbolic arccosine of
   the real number :data:`z`, :math:`\arccosh(z)`.

.. function:: fn (c Complex) atanh () Complex

   This function returns the complex hyperbolic arctangent of the complex
   number :data:`z`, :math:`\arctanh(z)`.  The branch cuts are on the real
   axis, less than :math:`-1` and greater than :math:`1`.

.. function:: fn atanh_real (double z) Complex

   This function returns the complex hyperbolic arctangent of the real
   number :data:`z`, :math:`\arctanh(z)`.

.. function:: fn (c Complex) asech () Complex

   This function returns the complex hyperbolic arcsecant of the complex
   number :data:`z`, :math:`\arcsech(z) = \arccosh(1/z)`.

.. function:: fn (c Complex) acsch () Complex

   This function returns the complex hyperbolic arccosecant of the complex
   number :data:`z`, :math:`\arccsch(z) = \arcsinh(1/z)`.

.. function:: fn (c Complex) acoth () Complex

   This function returns the complex hyperbolic arccotangent of the complex
   number :data:`z`, :math:`\arccoth(z) = \arctanh(1/z)`.
