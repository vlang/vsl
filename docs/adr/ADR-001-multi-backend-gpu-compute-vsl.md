# ADR-001: Multi-Backend GPU Compute Architecture for VSL

**Status:** Draft

## Context

VSL (V Scientific Library) is the low-level math foundation for VTL (V Tensor Library). VSL provides linear algebra (`la`), compute dispatch, and GPU data transport. The goal of issue [#236](https://github.com/vlang/vsl/issues/236) is to provide a unified compute abstraction that enables GPU acceleration across Vulkan, CUDA, and OpenCL backends, so that VTL can consume GPU compute without caring which backend is active.

### Current State

VSL already has a partial compute infrastructure:

| Component | Status |
|-----------|--------|
| `vsl/compute/context.v` — `Backend` enum + `ComputeContext` | ✅ Done (PR #260 merged) |
| `vsl/compute/dispatch.v` — unified dispatch API | ✅ Done (PR #260 merged) |
| `vsl/vulkan/compute/` — Vulkan GEMM/GEMV/elementwise | ⚠️ Partial (gemm, gemv, relu, sigmoid only) |
| `vsl/vcl/compute/` — OpenCL kernels | ⚠️ Partial (full ops: gemm, gemv, relu, sigmoid, tanh, softmax, layernorm, conv2d…) |
| `vsl/cuda/` | ❌ Does not exist |

### Constraints

- VSL's compute API is row-major externally (C-style), but Vulkan and VCL
  are column-major internally.
- `vsl.vcl` already exists as a mature OpenCL transport wrapper; compute extends it.
- `vsl.vulkan` is backed by `antono2/vulkan` raw bindings (~1.3 MB auto-generated from Khronos XML).
- No CUDA bindings exist in the V ecosystem yet; need to evaluate
  `vlang/cuvm` or raw CUDA driver API.
- VTL (VTL issue [#57](https://github.com/vlang/vtl/issues/57)) blocks on VSL having CUDA and Vulkan compute ready.

## Options Considered

### Option A: Extend VCL Compute Only (OpenCL as the universal backend)

**What:** Skip Vulkan and CUDA entirely. Make VCL the single GPU backend
(OpenCL runs on NVIDIA, AMD, Intel, ARM, and via POCL on CPU).

**Pros:**
- Single code path for all GPUs.
- VCL already has mature transport + compute kernels.
- OpenCL is cross-vendor (NVIDIA via CUDA, AMD via ROCm, Intel, ARM).

**Cons:**
- No native CUDA optimization (CUDA-only performance tricks, cuBLAS, cuDNN).
- VCL transport overhead vs native CUDA driver API.
- OpenCL runtime must be present on all target machines.
- VCL examples failing on user machines ("OpenCL device not found" — issue #226).

**Estimated effort:** Phase C (#239) already covers this. Low additional
work if VCL is the only target.

---

### Option B: Vulkan + VCL (No CUDA)

**What:** Implement the full Vulkan compute backend (Phase A, #237)
alongside the existing VCL compute (Phase C, #239). Skip CUDA entirely.

**Pros:**
- Vulkan is the only truly open GPU API (royalty-free, cross-platform).
- Covers NVIDIA (via Vulkan), AMD, Intel, ARM, and mobile.
- PR #260 already merged with backend architecture.
- `antono2/vulkan` provides complete bindings.

**Cons:**
- CUDA users (the majority of ML/GPU users) would have no acceleration path.
- Vulkan compute queues on NVIDIA are not as optimized as CUDA for GEMM.
- CUDA is the de-facto standard for ML training/inference.

**Estimated effort:** ~2–3 months for Phase A + Phase C.

---

### Option C: Vulkan + CUDA + VCL (Full three-backend)

**What:** Implement all three backends with a unified compute abstraction.

**Pros:**
- CUDA users get native performance (cuBLAS, cuDNN).
- Vulkan covers cross-platform (Linux, Windows, Android, macOS via MoltenVK).
- VCL covers older hardware and cross-vendor fallback.
- Most complete solution for VTL's needs.

**Cons:**
- CUDA backend requires creating new bindings (no existing `vlang/cuvm` stable).
- Three backends = three × maintenance burden.
- Vulkan on macOS requires MoltenVK (extra dependency).

**Estimated effort:** ~4–6 months for Phases A + B + C.

---

### Option D: Abstraction-First — Define Compute Trait Before Backend Implementation

**What:** Do NOT implement any new backend yet. First define a
`ComputeBackend` trait/interface in VSL's `compute` module that all
backends must satisfy. Then implement backends incrementally (Phase A → B → C).

**Pros:**
- Forces clean API design before code accumulates.
- Makes Phase A, B, C implementation straightforward mechanical work.
- Easier to onboard contributors because API contract is clear.
- VTL can consume the trait immediately and mock for testing.

**Cons:**
- Adds a design step before coding.
- V's `@[interface]` or trait system may not perfectly match the need.

**Estimated effort:** ~2 weeks for design doc + trait definition, then same as Option C.

## Decision

**Adopt Option D (Abstraction-First).**

Rationale:
- The current `dispatch.v` has a hard-coded `match` on `Backend` enum.
  This is not extensible — adding CUDA requires changing every function in
  `dispatch.v`.
- A trait/interface lets the dispatch layer stay stable while backends vary.
- VTL needs a stable API contract to build against; `ComputeBackend` trait gives that.
- After the trait is defined, Phase A (Vulkan), Phase B (CUDA), and
  Phase C (VCL Extended) are independent and can run in parallel or sequentially.

The compute abstraction should be:

```v
// In vsl/compute/backend.v

pub interface ComputeBackend {
	// Backend identifier
	name() string

	// Query which operations this backend supports
	supports(op string) bool

	// Matrix multiply: C = A * B, row-major, returns row-major
	gemm(a []f64, b []f64, m int, n int, k int) ![]f64

	// Matrix-vector multiply: y = A * x, row-major A
	gemv(a []f64, x []f64, m int, n int) ![]f64

	// Element-wise ops
	relu(x []f64) ![]f64
	sigmoid(x []f64) ![]f64
	tanh(x []f64) ![]f64

	// Vector-vector ops
	add_vec(a []f64, b []f64) ![]f64
	mul_vec(a []f64, b []f64) ![]f64

	// Scalar ops
	add_scalar(x []f64, s f64) ![]f64
	mul_scalar(x []f64, s f64) ![]f64

	// Advanced ops
	softmax(x []f64) ![]f64
	layernorm(x []f64, gamma []f64, beta []f64) ![]f64

	// Layout conversion (each backend owns its internal layout)
	// Called automatically by dispatch to convert row→column-major
	to_internal_layout(data []f64, rows int, cols int) ![]f64
	from_internal_layout(data []f64, rows int, cols int) ![]f64
}

// ComputeContext holds a backend and dispatches to it.
pub struct ComputeContext {
	backend ComputeBackend
	strict  bool
}
```

**Backend implementations:**
- `VulkanBackend` — wraps `vsl.vulkan/compute/` (exists partially, needs completion)
- `CUDABackend` — wraps new `vsl/cuda/` module (does not exist yet)
- `VCLBackend` — wraps `vsl.vcl/compute/` (most complete)
- `CPUBackend` — pure V/fast BLAS fallback (exists as `gemm_cpu_f64` etc.)

## Consequences

### Immediate (Week 1–2)
- Define `ComputeBackend` trait in `vsl/compute/backend.v`
- Refactor `dispatch.v` to use the trait instead of `match Backend`
- Update `ComputeContext` to hold `ComputeBackend` interface
- Create placeholder `vsl/cuda/` module stub with error: "CUDA backend not yet implemented"

### Phase A — Vulkan Compute (Weeks 3–8)
- Complete `vsl.vulkan/compute/` for all ops in trait
  (relu, sigmoid, tanh, add_vec, mul_vec, softmax, layernorm)
- Implement `to_internal_layout` / `from_internal_layout` for Vulkan (row→column-major)
- Add tests using `vulkan_test.v` as reference
- VTL issue [#57](https://github.com/vlang/vtl/issues/57) unblocks

### Phase B — CUDA Backend (Weeks 9–16)
- Evaluate `vlang/cuvm` or CUDA driver API bindings
- Create `vsl/cuda/` module with `ComputeBackend` implementation
- Target cuBLAS for GEMM/GEMV for optimal NVIDIA performance
- VTL issue [#60](https://github.com/vlang/vtl/issues/60) unblocks

### Phase C — VCL Compute Extension (Weeks 17–20)
- Extend `vsl.vcl/compute/` to cover all trait operations
- VCL already has most ops implemented; just expose via trait
- VTL issue [#62](https://github.com/vlang/vtl/issues/62) unblocks

### Architecture Changes
- `vsl/compute/dispatch.v` becomes thin wrapper: `ctx.gemm(...)` → `ctx.backend.gemm(...)`
- Each backend owns its memory layout conversion
- `vsl.la` (Matrix/Vector) uses `ComputeContext` internally; no direct GPU calls in `la`

### Risks
- V's interface/trait system (`@[interface]`) may have performance overhead for hot paths (GEMM)
- CUDA bindings do not exist yet; Phase B is the highest risk
- Row→column-major conversion overhead for Vulkan (already present in current code)

## References

- [Issue #236: GPU Architecture — Multi-Backend GPU Acceleration (VSL)](https://github.com/vlang/vsl/issues/236)
- [Issue #237: Phase A — Vulkan Compute Backend](https://github.com/vlang/vsl/issues/237)
- [Issue #238: Phase B — CUDA Backend for VSL Matrix/Vector](https://github.com/vlang/vsl/issues/238)
- [Issue #239: Phase C — OpenCL Compute (VCL Extended)](https://github.com/vlang/vsl/issues/239)
- [VTL Issue #57: GPU Architecture: Multi-Backend GPU Acceleration](https://github.com/vlang/vtl/issues/57)
- [PR #260: feat(compute): standardize backend architecture with unified dispatch API](https://github.com/vlang/vsl/pull/260) (already merged)
- [`antono2/vulkan`](https://github.com/antono2/vulkan) — reference Vulkan bindings
- [`antono2/vulkan_memory_allocator`](https://github.com/antono2/vulkan_memory_allocator) — GPU memory allocator reference
- [Issue #226: vcl examples not working — OpenCL device not found](https://github.com/vlang/vsl/issues/226)
