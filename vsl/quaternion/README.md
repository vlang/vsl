# Quaternions

The functions described in this chapter provide support for quaternions.
The algorithms take care to avoid unnecessary intermediate underflows
and overflows, allowing the functions to be evaluated over as much of
the quaternion plane as possible.

The quaternion types, functions and arithmetic operations are defined in
the dir `vsl.quaternion`.

# Representation of quaternions

Quaternions are represented using the type `Quaternion`. The functions and macros described
below allow quaternions to be manipulated in a portable way.
