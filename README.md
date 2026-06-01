<div align="center">
  <p>
    <img
        style="width: 200px"
        width="200"
        src="https://raw.githubusercontent.com/vlang/vsl/main/static/vsl-logo.png?sanitize=true"
    >
  </p>
  <h1>The V Scientific Library</h1>

[vlang.io](https://vlang.io) |
[Docs](https://vlang.github.io/vsl) |
[ML Roadmap](./docs/ML_ROADMAP.md) |
[Examples](./examples/) |
[Releases](https://github.com/vlang/vsl/releases) |
[Contributing](CONTRIBUTING.md)

[![Mentioned in Awesome V][awesomevbadge]][awesomevurl]
[![VSL Continuous Integration][workflowbadge]][workflowurl]
[![Deploy Documentation][deploydocsbadge]][deploydocsurl]
[![Performance Benchmarks][benchmarksbadge]][benchmarksurl]
[![MegaLinter][megalinterbadge]][megalinterurl]
[![License: MIT][licensebadge]][licenseurl]
[![Modules][ModulesBadge]][ModulesUrl]

</div>

```v ignore
import vsl.la as la

mut a := la.Matrix.new[f64](2, 2)
a.set(0, 0, 1.0)
a.set(1, 1, 2.0)
println(a.get(1, 1))
// 2.0
```

VSL is a V library for AI and high-performance scientific computing.

<div align="center">

### Building machine learning in V?

**Use [VTL](https://github.com/vlang/vtl) on top of VSL** for tensors, autograd,
neural networks, datasets, optimizers, and GPU-backed training.

VSL provides the scientific and GPU compute foundation. VTL turns it into a
developer-friendly ML toolkit for V.

[Get started with VTL](https://github.com/vlang/vtl) ·
[VTL tutorials](https://github.com/vlang/vtl/tree/main/docs) ·
[ML roadmap](./docs/ML_ROADMAP.md)

</div>

> [!IMPORTANT]
> The pure-V QR path (`geqrf/orgqr`) is still being aligned; the related test is
> temporarily skipped. Other BLAS/LAPACK routines pass, and C backends
> (`-d vsl_blas_cblas -d vsl_lapack_lapacke`) are recommended when you need QR
> correctness today.

|                                      |                                |                |                       |
| :----------------------------------: | :----------------------------: | :------------: | :-------------------: |
|       ![][sierpinski_triangle]       | ![][mandelbrot_blue_red_black] |   ![][julia]   | ![][mandelbrot_basic] |
| ![][mandelbrot_pseudo_random_colors] |   ![][sierpinski_triangle2]    | ![][julia_set] |   ![][julia_basic]    |

## 📖 Documentation

Visit [VSL Documentation](https://vlang.github.io/vsl) to explore all supported features and APIs.

### Start Here

| Need | Go to |
|------|-------|
| Scientific computing overview | [Docs index](docs/README.md) |
| Working examples | [Examples catalog](examples/README.md) |
| ML/GPU release status | [ML roadmap](docs/ML_ROADMAP.md) |
| CUDA backend | [cuda/README.md](cuda/README.md) |
| Vulkan backend | [vulkan/README.md](vulkan/README.md) |
| Benchmarks | [benchmarks/README.md](benchmarks/README.md) |
| Tensor/autograd/NN layer | [VTL](https://github.com/vlang/vtl) |

VSL is a comprehensive Scientific Computing Library offering a rich ecosystem of
mathematical and computational modules. The library provides both pure-V
implementations and optional high-performance backends through established C and
Fortran libraries.

### 🔬 Core Capabilities

- **Linear Algebra**: Complete matrix and vector operations, eigenvalue
  decomposition, linear solvers
- **Machine Learning**: Clustering algorithms (K-means), classification (KNN),
  regression, and NLP tools
- **Numerical Methods**: Differentiation, integration, root finding, polynomial operations
- **Data Visualization**: Advanced plotting with Plotly-style API supporting 2D/3D charts
- **Scientific Computing**: FFT, statistical analysis, probability distributions
- **Parallel Computing**: MPI support and OpenCL acceleration
- **Data I/O**: HDF5 integration for scientific data formats

### ⚡ Performance Architecture

VSL provides flexible performance options:

- **Pure V Implementation**: High-performance, dependency-free BLAS/LAPACK implementations
- **Optimized Backends**: Optional integration with OpenBLAS, LAPACK, MPI,
  OpenCL (VCL), Vulkan Compute, and CUDA (cuBLAS/cuDNN) for maximum performance
- **GPU Acceleration**: OpenCL/VCL, Vulkan Compute, and CUDA support for
  computationally intensive operations

**Pure V BLAS/LAPACK** implementations deliver competitive performance while
eliminating external dependencies. Benchmark results demonstrate excellent
performance characteristics across a wide range of problem sizes.

Each module clearly documents compilation flags and backend requirements,
allowing
users to choose the optimal configuration for their specific use case.

### Compute Standardization

VSL compute backends are organized with a unified structure:

- `vsl/compute` — backend-agnostic dispatch API
- `vsl/vcl/compute` — OpenCL/VCL backend implementation
- `vsl/vulkan/compute` — Vulkan backend implementation
- `vsl/cuda/compute` — CUDA/cuBLAS/cuDNN backend (`-d cuda`; see [cuda/README](cuda/README.md))

The recommended integration point for downstream libraries is `vsl.compute`.

### Backend Status

| Backend | Build flag | Highlights | Downstream use |
|---------|------------|------------|----------------|
| Pure V | none | Portable BLAS/LAPACK-style routines and scientific modules | Default path |
| C BLAS/LAPACK | `-d vsl_blas_cblas`, `-d vsl_lapack_lapacke` | Optimized CPU kernels | Heavy linear algebra |
| OpenCL/VCL | module-specific | Cross-vendor GPU kernels and examples | Experimental GPU path |
| CUDA | `-d cuda` | cuBLAS/cuDNN GEMM, activations, softmax, Conv2D, LayerNorm | VTL CUDA training |
| Vulkan | `-d vulkan` | GEMM, Conv2D im2col, elementwise ops, fused Adam shader | VTL f32 Vulkan training |

For neural networks, use [VTL](https://github.com/vlang/vtl): VSL owns the
compute primitives, and VTL owns tensors, autograd, layers, losses, optimizers,
datasets, and training loops.

## 🚀 Installation & Quick Start

VSL supports multiple installation methods and deployment options to fit
different development workflows.

### 📦 Package Manager Installation

**Via V's built-in package manager:**

```sh
v install vsl
```

**Via vpkg:**

```sh
vpkg get https://github.com/vlang/vsl
```

### 🐳 Docker Development Environment

For a pre-configured development environment with optional scientific
dependencies:

1. **Install Docker** on your system
2. **Clone the starter template:**

   ```sh
   git clone https://github.com/ulises-jeremias/hello-vsl
   cd hello-vsl
   ```

3. **Follow the setup instructions** in the template's README

This approach provides:

- Pre-configured environment with V, VSL, and all optional dependencies
- Cross-platform compatibility (Windows, Linux, macOS)
- Isolated development environment
- Access to optimized BLAS/LAPACK libraries

### 🔧 System Dependencies (Optional)

For enhanced performance, you can install optional system libraries:

- **OpenBLAS/LAPACK**: Linear algebra acceleration
- **OpenMPI**: Parallel computing support
- **OpenCL**: GPU acceleration
- **HDF5**: Scientific data format support

Refer to individual module documentation for specific compilation flags.

## 🧪 Testing

Use scoped tests during development to avoid compiling the whole scientific
stack at once:

```sh
v test vsl/blas vsl/la vsl/compute
VSL_TEST_VULKAN=1 VJOBS=1 v -prod -d vulkan test vsl/vulkan/compute/adam_step_vulkan_test.v
```

For the repository test harness and optional GPU paths, see
[docs/ML_ROADMAP.md](docs/ML_ROADMAP.md) and [vulkan/README.md](vulkan/README.md).

## 📊 Performance Benchmarks

VSL includes comprehensive performance benchmarks using V's built-in `benchmark` module:

```sh
# Run all BLAS benchmarks
v run benchmarks/blas_bench.v

# Run all LAPACK benchmarks
v run benchmarks/lapack_bench.v

# Compare pure V vs C backends
v -d vsl_blas_cblas run benchmarks/compare_backends.v
```

Benchmark results show performance characteristics for:
- **BLAS Level 1**: Vector operations (dot product, norms, scaling)
- **BLAS Level 2**: Matrix-vector operations (GEMV, GER)
- **BLAS Level 3**: Matrix-matrix operations (GEMM, SYRK)
- **LAPACK**: Linear system solvers, factorizations, eigenvalue problems

See [benchmarks/README.md](./benchmarks/README.md) for detailed benchmark documentation.

## 👥 Contributors

<a href="https://github.com/vlang/vsl/contributors">
  <img src="https://contrib.rocks/image?repo=vlang/vsl"/>
</a>

Made with [contributors-img](https://contrib.rocks).

[awesomevbadge]: https://awesome.re/mentioned-badge.svg
[workflowbadge]: https://github.com/vlang/vsl/actions/workflows/ci.yml/badge.svg
[deploydocsbadge]: https://github.com/vlang/vsl/actions/workflows/deploy-docs.yml/badge.svg
[benchmarksbadge]: https://github.com/vlang/vsl/actions/workflows/benchmarks.yml/badge.svg
[megalinterbadge]: https://github.com/vlang/vsl/actions/workflows/mega-linter.yml/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[ModulesBadge]: https://img.shields.io/badge/modules-reference-027d9c?logo=v
[awesomevurl]: https://github.com/vlang/awesome-v/blob/master/README.md#scientific-computing
[workflowurl]: https://github.com/vlang/vsl/actions/workflows/ci.yml
[deploydocsurl]: https://github.com/vlang/vsl/actions/workflows/deploy-docs.yml
[benchmarksurl]: https://github.com/vlang/vsl/actions/workflows/benchmarks.yml
[megalinterurl]: https://github.com/vlang/vsl/actions/workflows/mega-linter.yml
[licenseurl]: https://github.com/vlang/vsl/blob/main/LICENSE
[ModulesUrl]: https://vlang.github.io/vsl/

<!-- Images -->

[sierpinski_triangle]: vcl/static/sierpinski_triangle.png
[mandelbrot_blue_red_black]: vcl/static/mandelbrot_blue_red_black.png
[julia]: vcl/static/julia.png
[mandelbrot_basic]: vcl/static/mandelbrot_basic.png
[mandelbrot_pseudo_random_colors]: vcl/static/mandelbrot_pseudo_random_colors.png
[sierpinski_triangle2]: vcl/static/sierpinski_triangle2.png
[julia_set]: vcl/static/julia_set.png
[julia_basic]: vcl/static/julia_basic.png
