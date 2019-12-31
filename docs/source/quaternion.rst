.. index:: quaternions

***********
Quaternions
***********

The functions described in this chapter provide support for quaternions.
The algorithms take care to avoid unnecessary intermediate underflows
and overflows, allowing the functions to be evaluated over as much of
the quaternion plane as possible.

The quaternion types, functions and arithmetic operations are defined in
the dir :file:`vsl/quaternion`.

.. index::
   single: representations of quaternion
   single: Quaternion


Representation of quaternions
=============================

Quaternions are represented using the type :code:`Quaternion`. The
internal representation of this type may vary across platforms and
should not be accessed directly. The functions and macros described
below allow quaternions to be manipulated in a portable way.

For reference, the default form of the :code:`Quaternion` type is
given by the following struct::

  pub struct Quaternion {
  pub:
    w f64
    x f64
    y f64
    z f64
  }
