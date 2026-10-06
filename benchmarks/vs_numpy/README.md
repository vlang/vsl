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
	-- env VJOBS=2 OPENBLAS_NUM_THREADS=2 uv run --with numpy python \
	./vsl/benchmarks/vs_numpy/numpy_baseline.py matmul
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 python3 ./vsl/benchmarks/vs_numpy/numpy_baseline.py gemv
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 \
	-- env VJOBS=2 python3 ./vsl/benchmarks/vs_numpy/numpy_baseline.py conv2d
```

Compare GFLOPS / ms from the V scripts with the Python output for the same sizes.

## Ryzen 9 5900X local sample

The VSL and NumPy scripts use the same deterministic matrices, two warmups, and
five timed calls. One local run with `VJOBS=2` measured:

| Backend | 512×512 | 1024×1024 |
|---|---:|---:|
| VSL pure V | 22.25 ms | 164.69 ms |
| VSL + OpenBLAS 0.3.34 | 1.43 ms | 8.47 ms |
| NumPy 2.5.3, 2 OpenBLAS threads | 2.11 ms | 17.38 ms |

The OpenBLAS builds differ: VSL linked to the official Arch OpenBLAS 0.3.34
package, while NumPy used its wheel-provided BLAS. These results show that the
optimized VSL backend was faster on this host and setup, not that the pure-V
backend or every VSL workload is faster than NumPy. The paired sample is about
1.5× faster at 512×512 and 2.1× at 1024×1024. Rerun both commands on the
target host before drawing a general performance conclusion. The OpenBLAS
package used for this local VSL run was signature verified and extracted
temporarily rather than installed system-wide.

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
