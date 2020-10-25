.. index:: easings functions

*****************
Easings Functions
*****************

The functions described in this chapter are declared in the module :file:`vsl.easings`.

The easing functions are an implementation of the functions presented in
http://easings.net/, useful particularly for animations.
Easing is a method of distorting time to control apparent motion in animation.
It is most commonly used for slow-in, slow-out. By easing time, animated
transitions are smoother and exhibit more plausible motion.

Easing functions take a value inside the range :code:`[0.0, 1.0]` and usually will
return a value inside that same range. However, in some of the easing
functions, the returned value extrapolate that range
http://easings.net/ to see those functions).

The following types of easing functions are supported::

  Linear
  Quadratic
  Cubic
  Quartic
  Quintic
  Sine
  Circular
  Exponential
  Elastic
  Bounce
  Back

The core easing functions are implemented as C functions that take a time
parameter and return a progress parameter, which can subsequently be used
to interpolate any quantity.

Functions
=========

.. function:: easings.animate(easing fn(p f64) f64, from f64, to f64, frames int) []f64

.. function:: easings.linear_interpolation(p f64) f64

.. function:: easings.quadratic_ease_in(p f64) f64
.. function:: easings.quadratic_ease_out(p f64) f64
.. function:: easings.quadratic_ease_in_out(p f64) f64

.. function:: easings.cubic_ease_in(p f64) f64
.. function:: easings.cubic_ease_out(p f64) f64
.. function:: easings.cubic_ease_in_out(p f64) f64

.. function:: easings.quartic_ease_in(p f64) f64
.. function:: easings.quartic_ease_out(p f64) f64
.. function:: easings.quartic_ease_in_out(p f64) f64

.. function:: easings.quintic_ease_in(p f64) f64
.. function:: easings.quintic_ease_out(p f64) f64
.. function:: easings.quintic_ease_in_out(p f64) f64

.. function:: easings.sine_ease_in(p f64) f64
.. function:: easings.sine_ease_out(p f64) f64
.. function:: easings.sine_ease_in_out(p f64) f64

.. function:: easings.circular_ease_in(p f64) f64
.. function:: easings.circular_ease_out(p f64) f64
.. function:: easings.circular_ease_in_out(p f64) f64

.. function:: easings.exponential_ease_in(p f64) f64
.. function:: easings.exponential_ease_out(p f64) f64
.. function:: easings.exponential_ease_in_out(p f64) f64

.. function:: easings.elastic_ease_in(p f64) f64
.. function:: easings.elastic_ease_out(p f64) f64
.. function:: easings.elastic_ease_in_out(p f64) f64

.. function:: easings.back_ease_in(p f64) f64
.. function:: easings.back_ease_out(p f64) f64
.. function:: easings.back_ease_in_out(p f64) f64

.. function:: easings.bounce_ease_in(p f64) f64
.. function:: easings.bounce_ease_out(p f64) f64
.. function:: easings.bounce_ease_in_out(p f64) f64

References and Further Reading
==============================

This work is a spiritual descendent (not to say derivative work) of works
done by Robert Penner. So, the main references could be found in
http://robertpenner.com/easing/

* http://robertpenner.com/easing/penner_chapter7_tweening.pdf

* http://gilmoreorless.github.io/sydjs-preso-easing/

* http://upshots.org/actionscript/jsas-understanding-easing

* http://sol.gfxile.net/interpolation/
