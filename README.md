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
[Examples](./examples/) |
[Changelog](#) |
[Contributing](https://github.com/vlang/vsl/blob/main/CONTRIBUTING.md)

[![Mentioned in Awesome V][awesomevbadge]][awesomevurl]
[![VSL Continuous Integration][workflowbadge]][workflowurl]
[![Deploy Documentation][deploydocsbadge]][deploydocsurl]
[![License: MIT][licensebadge]][licenseurl]
[![Modules][ModulesBadge]][ModulesUrl]

</div>

VSL is a V library to develop Artificial Intelligence and High-Performance Scientific Computations.

|                                      |                                |                |                       |
| :----------------------------------: | :----------------------------: | :------------: | :-------------------: |
|       ![][sierpinski_triangle]       | ![][mandelbrot_blue_red_black] |   ![][julia]   | ![][mandelbrot_basic] |
| ![][mandelbrot_pseudo_random_colors] |   ![][sierpinski_triangle2]    | ![][julia_set] |   ![][julia_basic]    |

## 📖 Documentation

Visit [VSL Documentation](https://vlang.github.io/vsl) to explore all supported features and APIs.

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

- **Pure V Implementation**: Cross-platform, dependency-free operation
- **Optimized Backends**: Optional integration with OpenBLAS, LAPACK, and MPI
- **GPU Acceleration**: OpenCL support for computationally intensive operations

Each module clearly documents compilation flags and backend requirements, allowing
users to choose the optimal configuration for their specific use case.

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

### 🐳 Docker Development Environment (Recommended)

For the best development experience with all optional dependencies pre-configured:

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

To test the module, just type the following command:

```sh
v test .
```

## 👥 Contributors

<a href="https://github.com/vlang/vsl/contributors">
  <img src="https://contrib.rocks/image?repo=vlang/vsl"/>
</a>

Made with [contributors-img](https://contrib.rocks).

[awesomevbadge]: https://awesome.re/mentioned-badge.svg
[workflowbadge]: https://github.com/vlang/vsl/actions/workflows/ci.yml/badge.svg
[deploydocsbadge]: https://github.com/vlang/vsl/actions/workflows/deploy-docs.yml/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[ModulesBadge]: https://img.shields.io/badge/modules-reference-027d9c?logo=v&logoColor=white&logoWidth=10
[awesomevurl]: https://github.com/vlang/awesome-v/blob/master/README.md#scientific-computing
[workflowurl]: https://github.com/vlang/vsl/actions/workflows/ci.yml
[deploydocsurl]: https://github.com/vlang/vsl/actions/workflows/deploy-docs.yml
[licenseurl]: https://github.com/vlang/vsl/blob/main/LICENSE
[ModulesUrl]: https://vlang.github.io/vsl/

<!-- Images -->

[sierpinski_triangle]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/sierpinski_triangle.png
[mandelbrot_blue_red_black]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/mandelbrot_blue_red_black.png
[julia]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/julia.png
[mandelbrot_basic]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/mandelbrot_basic.png
[mandelbrot_pseudo_random_colors]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/mandelbrot_pseudo_random_colors.png
[sierpinski_triangle2]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/sierpinski_triangle2.png
[julia_set]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/julia_set.png
[julia_basic]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/julia_basic.png
