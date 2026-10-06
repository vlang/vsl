# Integrating VSL Modules

VSL modules can be combined in one program when their inputs and outputs share
ordinary V types. A common workflow is to build features with geometry or
quaternion operations, pass those features to an ML model, and visualize the
result with `vsl.plot`.

## A runnable integration example

[`ml_quaternion_features`](../../examples/ml_quaternion_features/README.md)
combines four modules:

| Module | Role in the example |
| --- | --- |
| `vsl.quaternion` | Generates orientations and extracts quaternion components. |
| `vsl.ml` | Splits labeled features and trains a K-means model. |
| `vsl.plot` | Displays the feature projection and labels. |
| `math` | Supplies angles and constants for synthetic data. |

Install the dependencies required by the modules you use (the plot backend
may open a browser), then run from `~/.vmodules`:

```sh
cd ~/.vmodules
VJOBS=2 v run ./vsl/examples/ml_quaternion_features/main.v
```

The same pattern applies to
[`geometry_ml_clustering`](../../examples/geometry_ml_clustering/README.md):
construct points with `vsl.gm`, project them into feature rows, train with
`vsl.ml`, and render the clusters with `vsl.plot`.

## Compose modules around their data contracts

Keep conversion between modules explicit. For example, an ML model consumes
feature rows (`[][]f64`) and labels, while geometry and quaternion APIs return
typed values. Extract or transform those values at the boundary, validate the
shape and sample count, and only then create the ML dataset. This makes it
clear which representation each module owns and avoids hidden copies or
assumptions about dimensionality.

For numerical workflows, use the same approach with linear algebra and plots:
keep matrix layout explicit when crossing into LAPACK-backed routines, and
label plotted values with the units and ordering returned by the computation.
Optional native backends require their development libraries and compile flags;
consult each module's README before combining them.

## Treat example scope accurately

The examples directory contains teaching demonstrations with different levels
of numerical completeness. `fft_quaternion_signal` currently extracts and
plots quaternion magnitudes and components; it does not call `vsl.fft` despite
the example name. `lapack_plot_eigenvalues` currently plots illustrative,
hard-coded eigenvalues rather than calling a LAPACK eigensolver. Use the FFT
and LAPACK module examples for actual transforms and decompositions, and treat
those two integration examples as visualization sketches until their numerical
steps are connected.

## More combinations

- [`geometry_ml_clustering`](../../examples/geometry_ml_clustering/README.md) —
  geometry, clustering, and 3D plotting.
- [`fft_quaternion_signal`](../../examples/fft_quaternion_signal/README.md) —
  quaternion signal visualization sketch (not an FFT walkthrough yet).
- [`lapack_plot_eigenvalues`](../../examples/lapack_plot_eigenvalues/README.md) —
  eigenvalue visualization sketch (not a LAPACK integration yet).
- [All VSL examples](../../examples/README.md)

Before relying on an example as a reference implementation, inspect its source
and module documentation to confirm that it exercises the operation you need.
