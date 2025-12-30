# VSL Tutorials

Welcome to the VSL (V Scientific Library) tutorials! This comprehensive guide
will help you master scientific computing with V.

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
- [HDF5 I/O](advanced/03-hdf5-io.md)
- [Library Integration](advanced/04-library-integration.md)

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

## Contributing

Found an error or want to improve a tutorial? See our [Contributing Guide](../CONTRIBUTING.md).

## Related Resources

- [VSL API Documentation](https://vlang.github.io/vsl)
- [Examples Directory](../examples/)
- [V Language Documentation](https://vlang.io/docs)
