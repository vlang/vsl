# SciPy and GSL capability tracker

This page compares relevant scientific-computing capabilities in VSL with the
public APIs documented by SciPy and the GNU Scientific Library (GSL). It is a
scope and coverage map, not a claim of API, numerical, or performance parity.

## Reference versions and scope

- **SciPy 1.18.0**: [reference manual](https://docs.scipy.org/doc/scipy-1.18.0/reference/)
  and [release notes](https://docs.scipy.org/doc/scipy/release/1.18.0-notes.html).
- **GSL 2.8**: [reference manual](https://www.gnu.org/software/gsl/doc/html/).

The status describes the breadth of each domain relative to these libraries:

- **Implemented** means the named core capability is present in VSL; it does
  not imply complete API or edge-case parity.
- **Partial** means VSL has useful APIs in the domain but has material gaps in
  algorithm families, data types, semantics, or backend coverage.
- **Missing** means no comparable public VSL API was found in the source tree.

SciPy and GSL are broad libraries with different language and API designs. The
links below are domain references, not a promise that VSL will reproduce every
API. Recheck upstream documentation when updating this tracker.

## Capability matrix

| Domain | Status | VSL modules | Follow-up |
| --- | --- | --- | --- |
| Dense linear algebra and BLAS/LAPACK | Partial | [blas][vsl-blas], [la][vsl-la], [lapack][vsl-lapack] | #65, #529 |
| Sparse formats and solvers | Partial | [sparse APIs][vsl-sparse] | #524 |
| Special functions | Partial | [fun][vsl-fun] | #540–#543, #556–#558 |
| Statistics and probability | Partial | [statistics][vsl-statistics], [dist][vsl-dist] | #523, #559 |
| Interpolation and splines | Partial | [fun][vsl-fun], [poly][vsl-poly] | #522 |
| Root finding and minimization | Partial | [roots][vsl-roots] | #520, #562 |
| Quadrature and ODE solvers | Missing | — | #521 |
| Fourier transforms | Partial | [fft][vsl-fft] | #527, #528 |
| Signal processing and wavelets | Missing | [fft][vsl-fft] only | #560 |
| ML | Partial | [ml][vsl-ml], [prep][vsl-preprocessing], [selection][vsl-model-selection], [metrics][vsl-metrics] | #514–#519, #529, #530 |
| Plotting and visualization | Partial | [plot][vsl-plot] | #545 |
| Device selection and accelerator backends | Partial | [compute][vsl-compute], [CUDA][vsl-cuda], [VCL][vsl-vcl], [Vulkan][vsl-vulkan] | #525–#528 |
| Numerical differentiation | Implemented, limited scope | [deriv][vsl-deriv] | #564 |

The rows are intentionally coarse. Details and authoritative API references
for each domain follow:

### Dense and sparse linear algebra

VSL provides portable BLAS/LAPACK routines and optional C backends, but its
routine and dtype coverage is narrower. Sparse formats and iterative solvers
are also limited. See SciPy [`linalg`][scipy-linalg] and [`sparse`][scipy-sparse],
and GSL [`BLAS`][gsl-blas], [`linear algebra`][gsl-linalg],
[`sparse matrices`][gsl-spmatrix], and [`sparse solvers`][gsl-splinalg].

### Special functions

VSL includes gamma/log-gamma, digamma, error functions, integer-order
cylindrical and spherical Bessel functions, and selected other functions.
Inverse error functions shipped in [#540](https://github.com/vlang/vsl/issues/540).
Fractional Bessel functions, Bessel error estimates, Airy functions, elliptic
families, and other special functions remain tracked in [#541](https://github.com/vlang/vsl/issues/541),
[#543](https://github.com/vlang/vsl/issues/543), [#556](https://github.com/vlang/vsl/issues/556),
[#557](https://github.com/vlang/vsl/issues/557), and [#558](https://github.com/vlang/vsl/issues/558).
Compare SciPy [`special`][scipy-special] and GSL [`special functions`][gsl-special].

### Statistics and probability

VSL has covariance/correlation and histogram binning, but not a general
descriptive statistics or probability-distribution API. See SciPy [`stats`][scipy-stats]
and GSL [`statistics`][gsl-statistics], [`random generation`][gsl-rng], and
[`distributions`][gsl-randist]. Follow-ups: [#523](https://github.com/vlang/vsl/issues/523)
and [#559](https://github.com/vlang/vsl/issues/559).

### Interpolation, roots, optimization, quadrature, and ODEs

VSL has selected interpolation helpers, B-spline curves, Newton, bisection, and
a public Brent root solver with bounded convergence diagnostics. Minimization,
quadrature, and ODE solver families are missing. See SciPy [`interpolate`][scipy-interpolate],
[`optimize`][scipy-optimize], and [`integrate`][scipy-integrate], plus GSL
[`interpolation`][gsl-interp], [`roots`][gsl-roots], [`minimization`][gsl-min],
[`integration`][gsl-integration], and [`ODE solvers`][gsl-ode]. Track these in
[#520](https://github.com/vlang/vsl/issues/520), [#521](https://github.com/vlang/vsl/issues/521),
[#522](https://github.com/vlang/vsl/issues/522), and [#562](https://github.com/vlang/vsl/issues/562).
The existing VSL integration guide is not evidence of an implementation.

### FFT and signal processing

VSL wraps PocketFFT for common real and complex f32/f64 transforms. No
comparable public filtering, windowing, resampling, or wavelet API was found.
See SciPy [`fft`][scipy-fft] and [`signal`][scipy-signal], and GSL [`FFT`][gsl-fft]
and [`wavelets`][gsl-wavelet]. Follow-ups: [#527](https://github.com/vlang/vsl/issues/527),
[#528](https://github.com/vlang/vsl/issues/528), and [#560](https://github.com/vlang/vsl/issues/560).

### Machine learning, plotting, and backends

VSL has selected ML estimators and workflows; its coverage is much smaller than
scikit-learn. SciPy and GSL are not direct plotting-framework comparators;
VSL's model plotting adapters are tracked in [#545](https://github.com/vlang/vsl/issues/545).
VSL's optional CUDA, VCL/OpenCL, and Vulkan paths add backend capabilities, but
their supported operations depend on build flags, libraries, and hardware.
See the [scikit-learn API](https://scikit-learn.org/stable/api/index.html) and
follow-ups [#514](https://github.com/vlang/vsl/issues/514)–[#519](https://github.com/vlang/vsl/issues/519),
[#525](https://github.com/vlang/vsl/issues/525), [#526](https://github.com/vlang/vsl/issues/526),
[#529](https://github.com/vlang/vsl/issues/529), and [#530](https://github.com/vlang/vsl/issues/530).

### Numerical differentiation

VSL provides numerical differentiation; this status does not claim parity for
all methods, error estimates, or edge cases. Compare SciPy [`differentiate`][scipy-differentiate]
and GSL [`numerical differentiation`][gsl-diff]. The broader coverage review,
including multivariable Jacobians and second derivatives, is tracked in
[#564](https://github.com/vlang/vsl/issues/564).

[scipy-linalg]: https://docs.scipy.org/doc/scipy-1.18.0/reference/linalg.html
[scipy-sparse]: https://docs.scipy.org/doc/scipy-1.18.0/reference/sparse.html
[scipy-special]: https://docs.scipy.org/doc/scipy-1.18.0/reference/special.html
[scipy-stats]: https://docs.scipy.org/doc/scipy-1.18.0/reference/stats.html
[scipy-interpolate]: https://docs.scipy.org/doc/scipy-1.18.0/reference/interpolate.html
[scipy-optimize]: https://docs.scipy.org/doc/scipy-1.18.0/reference/optimize.html
[scipy-integrate]: https://docs.scipy.org/doc/scipy-1.18.0/reference/integrate.html
[scipy-fft]: https://docs.scipy.org/doc/scipy-1.18.0/reference/fft.html
[scipy-signal]: https://docs.scipy.org/doc/scipy-1.18.0/reference/signal.html
[scipy-differentiate]: https://docs.scipy.org/doc/scipy-1.18.0/reference/differentiate.html
[gsl-blas]: https://www.gnu.org/software/gsl/doc/html/blas.html
[gsl-linalg]: https://www.gnu.org/software/gsl/doc/html/linalg.html
[gsl-spmatrix]: https://www.gnu.org/software/gsl/doc/html/spmatrix.html
[gsl-splinalg]: https://www.gnu.org/software/gsl/doc/html/splinalg.html
[gsl-special]: https://www.gnu.org/software/gsl/doc/html/specfunc.html
[gsl-statistics]: https://www.gnu.org/software/gsl/doc/html/statistics.html
[gsl-rng]: https://www.gnu.org/software/gsl/doc/html/rng.html
[gsl-randist]: https://www.gnu.org/software/gsl/doc/html/randist.html
[gsl-interp]: https://www.gnu.org/software/gsl/doc/html/interp.html
[gsl-roots]: https://www.gnu.org/software/gsl/doc/html/roots.html
[gsl-min]: https://www.gnu.org/software/gsl/doc/html/min.html
[gsl-integration]: https://www.gnu.org/software/gsl/doc/html/integration.html
[gsl-ode]: https://www.gnu.org/software/gsl/doc/html/ode-initval.html
[gsl-fft]: https://www.gnu.org/software/gsl/doc/html/fft.html
[gsl-wavelet]: https://www.gnu.org/software/gsl/doc/html/wavelet.html
[gsl-diff]: https://www.gnu.org/software/gsl/doc/html/diff.html
[vsl-blas]: ../blas/README.md
[vsl-la]: ../la/README.md
[vsl-lapack]: ../lapack/README.md
[vsl-sparse]: ../la/sparse_matrix.v
[vsl-fun]: ../fun/README.md
[vsl-statistics]: ../la/statistics.v
[vsl-dist]: ../dist/README.md
[vsl-poly]: ../poly/README.md
[vsl-roots]: ../roots/README.md
[vsl-fft]: ../fft/README.md
[vsl-ml]: ../ml/README.md
[vsl-preprocessing]: ../preprocessing/README.md
[vsl-model-selection]: ../model_selection/README.md
[vsl-metrics]: ../metrics/README.md
[vsl-plot]: ../plot/README.md
[vsl-compute]: ../compute/README.md
[vsl-cuda]: ../cuda/README.md
[vsl-vcl]: ../vcl/README.md
[vsl-vulkan]: ../vulkan/README.md
[vsl-deriv]: ../deriv/README.md

## Benchmark evidence

Feature coverage and speed are separate questions. The [benchmark index](../benchmarks/README.md)
contains workload-specific comparisons; those measurements do not establish
overall superiority over SciPy, GSL, or scikit-learn. Compare equivalent
algorithms, inputs, precision, threading, and backend configuration, and keep
the environment and raw measurements with each result. VSL tracks matched ML
comparisons in [#529](https://github.com/vlang/vsl/issues/529) and accelerator
comparisons in [#528](https://github.com/vlang/vsl/issues/528).

## Updating this tracker

When adding or changing a row, verify the public VSL API in source and its
module documentation, then check the linked upstream reference. Keep status
claims bounded to what is implemented and tested. Split new gaps into focused
issues using the [feature request template](../.github/ISSUE_TEMPLATE/feature-request.yml)
and link them here.
