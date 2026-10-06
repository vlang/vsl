# VSL vs NumPy baselines

Run V commands from `~/.vmodules`, outside the VSL checkout. These examples
limit memory and keep V's parallel job count at two:

```bash
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/matmul_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/gemv_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/conv2d_bench.v
```

With OpenBLAS (recommended):

```bash
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 v -d vsl_blas_cblas run \
	./vsl/benchmarks/vs_numpy/matmul_bench.v
```

On Linux systems that provide `libcblas` but not OpenBLAS, the dense f64 GEMM
benchmark can use the system CBLAS entry point while the other BLAS routines
remain pure V:

```bash
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 v -d vsl_blas_generic_cblas run \
	./vsl/benchmarks/vs_numpy/matmul_bench.v
```

## NumPy reference (`numpy_baseline.py`)

```bash
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 python3 ./vsl/benchmarks/vs_numpy/numpy_baseline.py matmul
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 python3 ./vsl/benchmarks/vs_numpy/numpy_baseline.py gemv
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 python3 ./vsl/benchmarks/vs_numpy/numpy_baseline.py conv2d
```

Compare GFLOPS / ms from the V scripts with the Python output for the same sizes.

## Ryzen 9 5900X local sample

One local run with `VJOBS=2` measured the pure-V backend at 22.31 ms for 512²
and 170.31 ms for 1024². With `-d vsl_blas_cblas`, VSL linked to OpenBLAS
0.3.34 and measured 2.12 ms and 6.81 ms respectively. NumPy 2.5.3, using its
wheel-provided BLAS with `OPENBLAS_NUM_THREADS=2`, measured 2.48 ms and 17.98
ms. The OpenBLAS builds differ, so these figures describe this host and setup;
rerun both commands on the target host before drawing a general performance
conclusion. The OpenBLAS package used for this local VSL run was signature
verified and extracted temporarily rather than installed system-wide.

## Output and reporting

Use the same host, flags, and matrix sizes for both VSL and NumPy. A useful
release note includes:

| Field | Example |
|-------|---------|
| CPU/GPU | `Ryzen 9`, `RTX 4060 Laptop` |
| V flags | `-d vsl_blas_cblas`, `-d cuda`, `-d vulkan` |
| Operation | `matmul`, `gemv`, `conv2d` |
| Size | `512`, `1024`, or Conv2D shape |
| Result | `ms`, `GFLOPS`, ratio vs baseline |

CUDA/Vulkan benchmark variants should be treated as opt-in until dedicated CI
coverage is added. Prefer scoped smoke tests for PR validation.

## Priority sizes

| Op | Shape |
|----|-------|
| GEMM | 128, 256, 512, 1024 |
| GEMV | square `m=n` same sizes |
| Conv2D | `1×1×32×32`, kernel `3×3`, stride 1 |

Tracked in [issue #282](https://github.com/vlang/vsl/issues/282).
