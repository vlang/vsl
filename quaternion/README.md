# Quaternions

The functions provided by this module add support for quaternions.
The algorithms take care to avoid unnecessary intermediate underflows
and overflows, allowing the functions to be evaluated over as much of
the quaternion plane as possible.

## Features

- **Quaternion arithmetic**: Addition, subtraction, multiplication, division
- **Rotations**: Create rotations from axis-angle, Euler angles, spherical coordinates
- **Interpolation**: SLERP, NLERP, LERP for smooth rotation animations
- **Mathematical operations**: Conjugate, inverse, normalization, exponentiation
- **Distance metrics**: Measure distances between rotations

## Quick Start

```v
import vsl.quaternion
import math

// Create rotation: 90 degrees around x-axis
q := quaternion.from_axis_anglef3(math.pi / 2.0, 1.0, 0.0, 0.0)

// Rotate a point
p := quaternion.quaternion(0.0, 1.0, 0.0, 0.0) // Point (1, 0, 0)
q_conj := q.conjugate()
rotated := q.multiply(p).multiply(q_conj)
println('Rotated: (${rotated.x}, ${rotated.y}, ${rotated.z})')
```

## Visualization Examples

Check out these examples that combine quaternions with plotting:

- **[quaternion_rotation_3d](../examples/quaternion_rotation_3d/)** - Visualize 3D
  rotations
- **[quaternion_interpolation_animation](../examples/quaternion_interpolation_animation/)** -
  Animated interpolation
- **[quaternion_julia_fractal](../examples/quaternion_julia_fractal/)** - Quaternion
  Julia sets
- **[quaternion_orientation_tracking](../examples/quaternion_orientation_tracking/)** -
  Track orientations over time
- **[quaternion_rotation_composition](../examples/quaternion_rotation_composition/)** -
  Compose multiple rotations

## Tutorials

Comprehensive tutorials are available in the [docs directory](../docs/quaternions/):

- [Introduction](../docs/quaternions/01-introduction.md) - Quaternion basics
- [Rotations](../docs/quaternions/02-rotations.md) - Rotating 3D points
- [Interpolation](../docs/quaternions/03-interpolation.md) - Smooth rotation animations
- [Visualization](../docs/quaternions/04-visualization.md) - Visualizing quaternions

## Integration Examples

Examples combining quaternions with other VSL modules:

- **[ml_quaternion_features](../examples/ml_quaternion_features/)** - Quaternions as ML features
- **[fft_quaternion_signal](../examples/fft_quaternion_signal/)** - Quaternion signal processing
- **[noise_quaternion_fractal](../examples/noise_quaternion_fractal/)** - Fractals with noise

## API Reference

See the [VSL API Documentation](https://vlang.github.io/vsl/quaternion/) for complete API reference.