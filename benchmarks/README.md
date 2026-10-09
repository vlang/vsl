# VSL Performance Benchmarks

This directory contains comprehensive performance benchmarks for VSL's pure V BLAS
and LAPACK implementations.

## Overview

The benchmark suite demonstrates the performance characteristics of VSL's pure V
implementations compared to C backends (OpenBLAS/LAPACKE). All benchmarks use V's
built-in `benchmark` module for accurate timing measurements.

## Running Benchmarks

Run V commands from `~/.vmodules`, outside the VSL checkout. Each example uses
`VJOBS=2` and a 768 MiB `MemoryMax`. Benchmarks are intentionally not part of
the default test suite because their timings depend on hardware and system
load.

### vs NumPy (ML ops)

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/matmul_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/gemv_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/conv2d_bench.v
```

See [vs_numpy/README.md](vs_numpy/README.md). Tracked in [#282](https://github.com/vlang/vsl/issues/282).

### FFT vs NumPy

The V and Python programs use the same real-valued f64 input, lengths,
warm-ups, and iteration counts. V reuses its PocketFFT plan and times only the
forward transform; input copying and plan creation are outside the timed region.
Install NumPy in the Python environment before running the baseline.

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/fft_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 python3 ./vsl/benchmarks/fft_numpy_baseline.py
```

The two CSV tables report mean microseconds per call. Compare them on the same
machine; the implementations have different output layouts, so these numbers
compare execution time, not storage behavior.

### Pure-V f32 Level 1 dot product

Compare the unit-stride f32 dot kernel with a scalar loop over the same fixed
input. The benchmark also reports each result's error against an f64
accumulation of the f32 inputs. Timings are hardware- and compiler-dependent.

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=2G --property=MemorySwapMax=0 \
	-- env VJOBS=2 v -prod run ./vsl/benchmarks/float32_level1_bench.v
```

### MPI communication latency

The MPI benchmark measures two-rank send/receive round trips, broadcasts, and
root reductions for one and 1024 i64 values. Build once and launch two ranks:

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 v -d vsl_mpi -cc gcc -o /tmp/vsl-mpi-bench \
	./vsl/benchmarks/mpi_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- mpirun --oversubscribe -n 2 /tmp/vsl-mpi-bench
```

### GPU smoke benchmarks

CUDA and Vulkan benchmark coverage is evolving. For release evidence, prefer
small scoped GPU smokes before running any heavy benchmark:

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 VSL_TEST_VULKAN=1 v -prod -d vulkan test \
	./vsl/vulkan/compute/adam_step_vulkan_test.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 v -d cuda test ./vsl/cuda/examples/cuda_ops_test.v
```

If you run from `~/.vmodules`, prefix benchmark paths with `vsl/`.

The resident-buffer Vulkan GEMM benchmark compares kernel execution with
buffers allocated once and reused; it excludes host-to-device input transfer
and device-to-host output transfer. Run it from `~/.vmodules`:

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 v -prod -d vulkan run ./vsl/benchmarks/vulkan_gemm_f32_bench.v
```

It reports the active K tile (16 or 32) per size. These kernel-only timings
must not be presented as end-to-end GPU performance or compared directly with
CPU timings that include allocation or different thread counts.

### Run All Benchmarks

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/blas_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/lapack_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/compare_backends.v
```

### Run a C backend benchmark

The BLAS and LAPACK benchmark sizes are configured in their source files.
Edit the benchmark's size list when you need a different set. To select a C
backend, pass its compile-time define:

```sh
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 v -d vsl_blas_cblas run \
	./vsl/benchmarks/blas_bench.v
```

## Benchmark Structure

- **`blas_bench.v`**: Comprehensive BLAS Level 1, 2, and 3 benchmarks
- **`lapack_bench.v`**: LAPACK operation benchmarks (linear systems, factorizations, etc.)
- **`compare_backends.v`**: Direct comparison between pure V and C backends
- **`fft_bench.v` and `fft_numpy_baseline.py`**: Real f64 forward FFT timing for VSL and NumPy
- **`mpi_bench.v`**: Two-rank MPI send/receive, broadcast, and reduction latency
- **`benchmark_utils.v`**: Shared utilities for benchmark setup and reporting

## Understanding Results

Benchmark results show:
- **Operation**: The BLAS/LAPACK function being benchmarked
- **Size**: Problem size (vector length, matrix dimensions)
- **Time**: Average execution time over multiple runs
- **Throughput**: Operations per second (where applicable)
- **GFLOPS**: Floating-point operations per second (for compute-intensive operations)

Example report shape:

| Operation | Size | Backend | Time | GFLOPS / ratio |
|-----------|------|---------|------|----------------|
| GEMM | 512 | pure V / C BLAS / NumPy | ms | backend-specific |
| Conv2D | `1x1x32x32`, `3x3` | VSL / NumPy reference | ms | ratio |

Do not compare numbers across machines without recording CPU/GPU model,
compiler flags, and backend flags.

## Performance Notes

- Benchmarks are run multiple times and averaged for accuracy
- Warm-up runs are performed before timing to account for cache effects
- Results may vary based on hardware, compiler optimizations, and system load
- Pure V backend performance is competitive with C backends for most operations

## Contributing

When adding new benchmarks:

1. Follow the existing benchmark structure
2. Use the `benchmark` module from V's standard library
3. Include multiple problem sizes
4. Document any special considerations
5. Ensure benchmarks are reproducible
