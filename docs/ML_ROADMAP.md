# VSL — ML Roadmap & Launch Tracking

Maintainer planning: **https://github.com/orgs/vlang/projects/8** (Vlang ML Roadmap — VSL + VTL; may require project access)

Repo roadmap: [ROADMAP.md](../ROADMAP.md) · CUDA: [cuda/README.md](../cuda/README.md)

## Done

| Issue | Topic |
|-------|--------|
| [#236](https://github.com/vlang/vsl/issues/236) | Multi-backend GPU architecture |
| [#237](https://github.com/vlang/vsl/issues/237)–[#239](https://github.com/vlang/vsl/issues/239) | Vulkan / CUDA / OpenCL foundations |
| [#280](https://github.com/vlang/vsl/issues/280) | cuBLAS/cuDNN kernels |
| [#281](https://github.com/vlang/vsl/issues/281) | GPU numerical validation tests |
| [#282](https://github.com/vlang/vsl/issues/282) | vs NumPy benchmarks + PR comments |
| [#283](https://github.com/vlang/vsl/issues/283)–[#285](https://github.com/vlang/vsl/issues/285) | Vulkan gating, conv2d, `ComputeContext` tests |
| [#304](https://github.com/vlang/vsl/pull/304) | Vulkan Conv2D backward `d_weight` GEMM layout fix |
| [#305](https://github.com/vlang/vsl/pull/305) | Vulkan `vector_mul`, `vector_sqrt`, fused f32 `adam_step` shader |
| [#328](https://github.com/vlang/vsl/issues/328) | Expanded Windows test coverage and portable test-runner cleanup (#394) |

**VTL (downstream):** CUDA Phases 1–4, f32 autograd/training, Vulkan Linear,
Conv2D, ReLU/Sigmoid, and Adam are wired into the `nn_cifar10_vulkan` smoke.

## Beta gate (platform validation)

The OpenBLAS and macOS issues [#91](https://github.com/vlang/vsl/issues/91) and
[#330](https://github.com/vlang/vsl/issues/330) are closed after the build and
test-runner fixes landed. At the 2026-10-14 check, the macOS jobs on
[PR #507](https://github.com/vlang/vsl/pull/507) were still queued. They do not
yet establish that the new exhaustive-test ranges pass on macOS.

## Post-beta tracking

| Tracking item | Remaining work |
|---------------|----------------|
| [#160](https://github.com/vlang/vsl/issues/160) (closed) | Automatic GPU selection/partial offload; multi-GPU execution remains TODO. |
| Phase I | GPU memory pool / zero-copy |
| — | CUDA variants of `benchmarks/vs_numpy/` in CI |
| — | Extended Vulkan↔CUDA numerical cross-check |
| — | Vulkan persistent memory / reduced host sync for VTL training |

Issues #21 and #34 were closed on GitHub on 2026-10-13. Issue #21's
closure records the adoption of wide-vector/SIMD patterns across hot kernels;
it does not establish NumPy performance parity, so per-kernel comparisons
remain part of the benchmark suite. Issue #34's closure records operator
support for the arithmetic struct types present at that time.

**Current open issue inventory (checked 2026-10-14):**
[#65](https://github.com/vlang/vsl/issues/65). The repository issue list is
the source for this inventory; check GitHub before relying on it as live
status.
The ML beta uses VSL as a scientific and compute foundation. The stable beta
contract is the portable CPU/scientific surface plus `vsl.compute`; CUDA,
Vulkan, and VCL are opt-in experimental accelerators.

## Local development

```bash
v up
cd ~/.vmodules
v test ./vsl/blas ./vsl/la ./vsl/compute
# CUDA smoke
v -d cuda test ./vsl/cuda/examples/cuda_ops_test.v
# Vulkan (opt-in; avoid full `v test ./vsl/vulkan` on low-RAM hosts)
./vsl/bin/test --use-vulkan
VSL_TEST_VULKAN=1 VJOBS=1 v -prod -d vulkan test ./vsl/vulkan/compute/adam_step_vulkan_test.v
```

## Project board sync

```bash
./.github/scripts/sync-ml-project-8.sh
```
