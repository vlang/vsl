# VSL — ML Roadmap & Launch Tracking

Central planning: **https://github.com/orgs/vlang/projects/8** (Vlang ML Roadmap — VSL + VTL)

Repo roadmap: [ROADMAP.md](../ROADMAP.md) · CUDA: [cuda/README.md](../cuda/README.md)

## Done (2026-05-31)

| Issue | Topic |
|-------|--------|
| [#236](https://github.com/vlang/vsl/issues/236) | Multi-backend GPU architecture |
| [#237](https://github.com/vlang/vsl/issues/237)–[#239](https://github.com/vlang/vsl/issues/239) | Vulkan / CUDA / OpenCL foundations |
| [#280](https://github.com/vlang/vsl/issues/280) | cuBLAS/cuDNN kernels |
| [#281](https://github.com/vlang/vsl/issues/281) | GPU numerical validation tests |
| [#282](https://github.com/vlang/vsl/issues/282) | vs NumPy benchmarks + PR comments |
| [#283](https://github.com/vlang/vsl/issues/283)–[#285](https://github.com/vlang/vsl/issues/285) | Vulkan gating, conv2d, `ComputeContext` tests |

**VTL (downstream):** [#89](https://github.com/vlang/vtl/issues/89)–[#91](https://github.com/vlang/vtl/issues/91).

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

## Local development

```bash
v up
cd ~/.vmodules
v test vsl/blas vsl/la vsl/compute
# CUDA smoke
v -d cuda test vsl/cuda/examples/cuda_ops_test.v
# Vulkan (opt-in; avoid full `v test vsl/vulkan` on low-RAM hosts)
cd vsl && ./bin/test --use-vulkan
```

## Project board sync

```bash
./.github/scripts/sync-ml-project-8.sh
```
