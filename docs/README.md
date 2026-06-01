# VSL Documentation

Welcome to VSL, the scientific computing foundation for V and the low-level
compute layer used by [VTL](https://github.com/vlang/vtl) for ML workloads.

Use this page as the stable navigation hub for tutorials, examples, GPU backend
docs, benchmarks, and release status.

## Start Here

| Goal | Read |
|------|------|
| Install VSL and run the first example | [Installation and Setup](getting-started/01-installation.md) |
| Learn the core scientific APIs | [Basic Linear Algebra](getting-started/03-basic-linear-algebra.md), [BLAS Basics](linear-algebra/01-blas-basics.md) |
| Build ML pipelines with VSL algorithms | [Data Preparation](machine-learning/01-data-preparation.md), [Clustering](machine-learning/02-clustering.md), [Regression](machine-learning/03-regression.md), [Classification](machine-learning/04-classification.md) |
| Train tensor/autograd neural networks | [VTL](https://github.com/vlang/vtl) |
| Use GPU backends | [OpenCL](advanced/02-opencl-gpu.md), [CUDA](advanced/02a-cuda-gpu.md), [Vulkan](../vulkan/README.md) |
| Compare performance | [Benchmarks](../benchmarks/README.md), [vs NumPy](../benchmarks/vs_numpy/README.md) |
| Track the ML release | [ML Roadmap](ML_ROADMAP.md) |

## Learning Paths

### Beginner Path
Start here if you're new to VSL or scientific computing:

1. [Installation and Setup](getting-started/01-installation.md)
2. [Your First Plot](getting-started/02-first-plot.md)
3. [Basic Linear Algebra](getting-started/03-basic-linear-algebra.md)
4. [Quick Reference](getting-started/04-quick-reference.md)

### Intermediate Path
Build on the basics with more advanced topics:

- [2D Plotting](visualization/01-2d-plotting.md)
- [BLAS Basics](linear-algebra/01-blas-basics.md)
- [Quaternion Introduction](quaternions/01-introduction.md)
- [Data Preparation for ML](machine-learning/01-data-preparation.md)
- [FFT Signal Processing](scientific-computing/01-fft-signal-processing.md)

### Advanced Path
Master advanced techniques and integrations:

- [MPI Parallel Computing](advanced/01-mpi-parallel.md)
- [OpenCL GPU Acceleration](advanced/02-opencl-gpu.md)
- [CUDA GPU Acceleration](advanced/02a-cuda-gpu.md)
- [Vulkan Compute Backend](../vulkan/README.md)
- [HDF5 I/O](advanced/03-hdf5-io.md)
- [Library Integration](advanced/04-library-integration.md)

## Tutorial Categories

### Getting Started
Essential tutorials for beginners:
- [Installation](getting-started/01-installation.md)
- [First Plot](getting-started/02-first-plot.md)
- [Basic Linear Algebra](getting-started/03-basic-linear-algebra.md)
- [Quick Reference](getting-started/04-quick-reference.md)

### Linear Algebra
Matrix operations, BLAS, and LAPACK:
- [BLAS Basics](linear-algebra/01-blas-basics.md)
- [LAPACK Solvers](linear-algebra/02-lapack-solvers.md)
- [Eigenvalue Problems](linear-algebra/03-eigenvalue-problems.md)
- [Sparse Matrices](linear-algebra/04-sparse-matrices.md)

### Visualization
Creating plots and charts:
- [2D Plotting](visualization/01-2d-plotting.md)
- [3D Visualization](visualization/02-3d-visualization.md)
- [Statistical Charts](visualization/03-statistical-charts.md)
- [Interactive Plots](visualization/04-interactive-plots.md)

### Quaternions
3D rotations and orientations:
- [Introduction](quaternions/01-introduction.md)
- [Rotations](quaternions/02-rotations.md)
- [Interpolation](quaternions/03-interpolation.md)
- [Visualization](quaternions/04-visualization.md)

### Machine Learning
ML algorithms and data processing:
- [Data Preparation](machine-learning/01-data-preparation.md)
- [Clustering](machine-learning/02-clustering.md)
- [Regression](machine-learning/03-regression.md)
- [Classification](machine-learning/04-classification.md)
- [Logistic Regression](machine-learning/05-logistic-regression.md)
- [Support Vector Machines](machine-learning/06-svm.md)
- [Decision Trees](machine-learning/07-decision-trees.md)
- [Random Forest](machine-learning/08-random-forest.md)

### Scientific Computing
Numerical methods and signal processing:
- [FFT Signal Processing](scientific-computing/01-fft-signal-processing.md)
- [Numerical Differentiation](scientific-computing/02-numerical-differentiation.md)
- [Root Finding](scientific-computing/03-root-finding.md)
- [Integration](scientific-computing/04-integration.md)

### Advanced Topics
High-performance and specialized topics:
- [MPI Parallel Computing](advanced/01-mpi-parallel.md)
- [OpenCL GPU Acceleration](advanced/02-opencl-gpu.md)
- [CUDA GPU Acceleration](advanced/02a-cuda-gpu.md)
- [Vulkan Compute Backend](../vulkan/README.md)
- [HDF5 I/O](advanced/03-hdf5-io.md)
- [Library Integration](advanced/04-library-integration.md)

## GPU Backend Quick Reference

| Backend | Build flag | Current role | Docs |
|---------|------------|--------------|------|
| Pure V | none | Portable scientific computing | [README](../README.md) |
| C BLAS/LAPACK | `-d vsl_blas_cblas`, `-d vsl_lapack_lapacke` | Optimized CPU linear algebra | [Linear algebra](linear-algebra/01-blas-basics.md) |
| OpenCL/VCL | module-specific | Cross-vendor GPU kernels and examples | [OpenCL GPU](advanced/02-opencl-gpu.md) |
| CUDA | `-d cuda` | cuBLAS/cuDNN kernels for NVIDIA GPUs | [CUDA README](../cuda/README.md) |
| Vulkan | `-d vulkan` | GEMM, Conv2D im2col, elementwise ops, fused Adam | [Vulkan README](../vulkan/README.md) |

VSL owns compute kernels and backend dispatch. For tensors, autograd, datasets,
layers, losses, optimizers, and training examples, use
[VTL](https://github.com/vlang/vtl).

## Quick Reference

### Common Operations

**Create a plot:**
```v
import vsl.plot

mut plt := plot.Plot.new()
plt.scatter(x: [1, 2, 3], y: [4, 5, 6])
plt.show()!
```

**Matrix multiplication:**
```v
import vsl.blas
// Use BLAS dgemm for matrix multiplication
```

**Quaternion rotation:**
```v ignore
import vsl.quaternion
import math

q := quaternion.from_axis_anglef3(math.pi / 2, 1, 0, 0)
```

## Examples

All tutorials include links to working examples in the [`examples/`](../examples/)
directory. Each example includes:
- Complete source code
- Detailed README
- Expected output descriptions
- Troubleshooting tips

For a curated catalog, see [examples/README.md](../examples/README.md).

## Contributing

Found an error or want to improve a tutorial? See our [Contributing Guide](../CONTRIBUTING.md).

## Related Resources

- [VSL API Documentation](https://vlang.github.io/vsl)
- [Examples Directory](../examples/)
- [Benchmarks](../benchmarks/README.md)
- [VTL Tensor Library](https://github.com/vlang/vtl)
- [V Language Documentation](https://vlang.io/docs)
