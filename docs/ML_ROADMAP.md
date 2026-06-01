# VSL — ML Roadmap & Launch Tracking

Maintainer planning: **https://github.com/orgs/vlang/projects/8** (Vlang ML Roadmap — VSL + VTL; may require project access)

Repo roadmap: [ROADMAP.md](../ROADMAP.md) · CUDA: [cuda/README.md](../cuda/README.md)

## Done (2026-06-01)

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

**VTL (downstream):** CUDA Phases 1–4, f32 autograd/training, Vulkan Linear,
Conv2D, ReLU/Sigmoid, and Adam are wired into the `nn_cifar10_vulkan` smoke.

## Critical path (open)

| Priority | Issue | Topic |
|----------|-------|--------|
| P1 | [#225](https://github.com/vlang/vsl/issues/225) | Windows build |
| P1 | Phase H | Multi-GPU (`device_id`, data parallelism) |
| P1 | Phase I | GPU memory pool / zero-copy |
| P2 | [#226](https://github.com/vlang/vsl/issues/226) | VCL examples |
| P2 | [#91](https://github.com/vlang/vsl/issues/91) | BLAS on macOS |
| P2 | — | CUDA variants of `benchmarks/vs_numpy/` in CI |
| P2 | — | Extended Vulkan↔CUDA numerical cross-check |
| P2 | — | Vulkan persistent memory / reduced host sync for VTL training |

## Local development

```bash
v up
cd ~/.vmodules
v test vsl/blas vsl/la vsl/compute
# CUDA smoke
v -d cuda test vsl/cuda/examples/cuda_ops_test.v
# Vulkan (opt-in; avoid full `v test vsl/vulkan` on low-RAM hosts)
cd vsl && ./bin/test --use-vulkan
VSL_TEST_VULKAN=1 VJOBS=1 v -prod -d vulkan test vulkan/compute/adam_step_vulkan_test.v
```

## Project board sync

```bash
./.github/scripts/sync-ml-project-8.sh
```
