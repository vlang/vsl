# VSL vs NumPy baselines

Run V commands from `~/.vmodules`, outside the VSL checkout. These examples
limit memory and keep V's parallel job count at two:

```bash
cd ~/.vmodules
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/matmul_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/gemv_bench.v
systemd-run --user --scope --quiet --property=MemoryMax=768M --property=MemorySwapMax=0 -- env VJOBS=2 v run ./vsl/benchmarks/vs_numpy/conv2d_bench.v
```

For a local build that targets the current CPU's instruction set, add
`-cflags "-march=native"` to the V command. The resulting executable is tied
to that CPU family; omit this flag for portable binaries. For example:

```bash
cd ~/.vmodules
systemd-run --user --scope --quiet -p MemoryMax=768M -p MemorySwapMax=0 -- env VJOBS=2 \
	v -prod -cflags "-march=native" run ./vsl/benchmarks/vs_numpy/matmul_bench.v
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

## Pure-V f32 SGEMM

The dedicated SGEMM pair uses identical deterministic `f32` matrices, three
warmups, seven timed calls, and preallocated output buffers. Run from
`~/.vmodules`:

```bash
systemd-run --user --scope --quiet -p MemoryMax=768M -p MemorySwapMax=0 -- env VJOBS=2 \
	v -prod run ./vsl/benchmarks/sgemm_f32_bench.v
systemd-run --user --scope --quiet -p MemoryMax=768M -p MemorySwapMax=0 -- env VJOBS=2 OPENBLAS_NUM_THREADS=2 \
	uv run --with numpy python ./vsl/benchmarks/vs_numpy/numpy_sgemm_f32_baseline.py
```

On the Ryzen 9 5900X, V 0.5.2 and NumPy 2.5.3, the pure-V path measured
4.371 ms versus NumPy at 1.071 ms for 512×512 `f32` SGEMM with the portable
compiler target, `VJOBS=2`, and `OPENBLAS_NUM_THREADS=2`. With
`-cflags "-march=native"`, V measured 3.743 ms and NumPy measured 1.248 ms;
the checksums matched in both comparisons. The native V build was about 3.0×
slower, and the portable build about 4.1× slower, on this host. These are local
measurements, not a general performance claim.

## Ryzen 9 5900X local sample

The VSL and NumPy scripts use the same deterministic matrices, two warmups, and
five timed calls. One local run with `VJOBS=2` measured:

| Backend | 512×512 | 1024×1024 |
|---|---:|---:|
| VSL pure V, portable target | 12.00 ms | 81.46 ms |
| VSL pure V, `-march=native` | 9.16 ms | 67.73 ms |
| VSL + OpenBLAS 0.3.34 | 1.43 ms | 8.47 ms |
| NumPy 2.5.3, 2 OpenBLAS threads | 2.12 ms | 17.50 ms |

The `-march=native` pure-V build was about 4.3× slower than NumPy at 512×512
and 3.9× slower at 1024×1024 in this run. The OpenBLAS builds differ: VSL
linked to the official Arch OpenBLAS 0.3.34 package, while NumPy used its
wheel-provided BLAS. The OpenBLAS package used for this local VSL run was
signature verified and extracted temporarily rather than installed
system-wide. Rerun these commands on the target host before drawing a general
performance conclusion.

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
