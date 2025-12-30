# Installation and Setup

This tutorial will guide you through installing VSL and setting up your development environment.

## What You'll Learn

- How to install VSL
- Setting up optional dependencies
- Verifying your installation
- Choosing the right backend for your needs

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- Basic familiarity with command line
- (Optional) System package manager for installing dependencies

## Installation Methods

### Method 1: V Package Manager (Recommended)

The simplest way to install VSL:

```sh
v install vsl
```

This installs VSL to your V modules directory (`~/.vmodules/vsl` by default).

### Method 2: Git Clone

For development or to use the latest version:

```sh
git clone https://github.com/vlang/vsl.git
cd vsl
```

### Method 3: Docker (Recommended for Development)

For a complete development environment with all dependencies:

```sh
git clone https://github.com/ulises-jeremias/hello-vsl
cd hello-vsl
# Follow setup instructions in README
```

## Verifying Installation

Create a simple test file `test_vsl.v`:

```v
import vsl.plot
import vsl.util

fn main() {
	x := util.arange(10).map(f64(it))
	y := x.map(it * it)

	mut plt := plot.Plot.new()
	plt.scatter(x: x, y: y, mode: 'lines+markers')
	plt.layout(title: 'VSL Test')
	plt.show()!

	println('VSL is working correctly!')
}
```

Run it:

```sh
v run test_vsl.v
```

If a plot opens in your browser, VSL is installed correctly!

## Optional Dependencies

### OpenBLAS/LAPACK (For Maximum Performance)

**Linux:**
```sh
sudo apt-get install libopenblas-dev liblapack-dev  # Debian/Ubuntu
sudo yum install openblas-devel lapack-devel        # RHEL/CentOS
```

**macOS:**
```sh
brew install openblas lapack
```

**Usage:**
```sh
v -d vsl_blas_cblas -d vsl_lapack_lapacke run your_program.v
```

### OpenMPI (For Parallel Computing)

**Linux:**
```sh
sudo apt-get install libopenmpi-dev  # Debian/Ubuntu
```

**macOS:**
```sh
brew install openmpi
```

### OpenCL (For GPU Acceleration)

Install platform-specific OpenCL drivers:
- **NVIDIA**: Install CUDA toolkit
- **AMD**: Install AMDGPU drivers
- **Intel**: Install Intel OpenCL runtime

### HDF5 (For Scientific Data I/O)

**Linux:**
```sh
sudo apt-get install libhdf5-dev  # Debian/Ubuntu
```

**macOS:**
```sh
brew install hdf5
```

## Backend Options

VSL supports multiple backends:

| Backend | Flag | Best For |
|---------|------|----------|
| Pure V (Default) | None | Zero dependencies, cross-platform |
| OpenBLAS | `-d vsl_blas_cblas` | Maximum BLAS performance |
| LAPACKE | `-d vsl_lapack_lapacke` | Maximum LAPACK performance |

**Recommendation**: Start with Pure V backend. It requires no dependencies and works everywhere.

## Troubleshooting

### Module Not Found

If you see `module 'vsl' not found`:

1. Check VSL is installed: `v list | grep vsl`
2. Verify V modules path: `v env`
3. Reinstall if needed: `v install vsl`

### Compilation Errors

- Ensure V compiler is up to date: `v up`
- Check VSL version compatibility
- Verify system dependencies if using C backends

### Plot Not Opening

- Ensure a web browser is installed
- Check file permissions
- Try running with `v -showcc run your_program.v` for debugging

## Next Steps

- [Your First Plot](02-first-plot.md) - Create your first visualization
- [Basic Linear Algebra](03-basic-linear-algebra.md) - Learn matrix operations
- [Examples Directory](../../examples/) - Explore working examples

## Related Examples

- `examples/plot_scatter` - Basic plotting example
- `examples/blas_basic_operations` - BLAS operations
- `examples/lapack_linear_systems` - LAPACK solvers
