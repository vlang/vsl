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

## Beta gate (open)

| Priority | Issue | Topic |
|----------|-------|--------|
| P2 | [#91](https://github.com/vlang/vsl/issues/91), [#330](https://github.com/vlang/vsl/issues/330) | OpenBLAS/BLAS backend on macOS validation |

## Post-beta tracking

| Priority | Issue | Topic |
|----------|-------|--------|
| P1 | Phase H | Multi-GPU (`device_id`, data parallelism) |
| P1 | Phase I | GPU memory pool / zero-copy |
| P2 | [#21](https://github.com/vlang/vsl/issues/21) | Pure-V compute performance and SIMD optimization |
| P2 | [#65](https://github.com/vlang/vsl/issues/65) | Correctly rounded binary32 math research |
| Design | [#34](https://github.com/vlang/vsl/issues/34) | Operator coverage for VSL structs |
| P2 | — | CUDA variants of `benchmarks/vs_numpy/` in CI |
| P2 | — | Extended Vulkan↔CUDA numerical cross-check |
| P2 | — | Vulkan persistent memory / reduced host sync for VTL training |

**Current open issue inventory:** [#21](https://github.com/vlang/vsl/issues/21),
[#34](https://github.com/vlang/vsl/issues/34),
[#65](https://github.com/vlang/vsl/issues/65),
[#91](https://github.com/vlang/vsl/issues/91), and
[#330](https://github.com/vlang/vsl/issues/330). Issues #91 and #330 track the
same macOS OpenBLAS concern; the newer issue is the active CI follow-up. The
GitHub Project #8 lists #91 but not #330 or the other current open issues, so
the board and repository inventory need reconciliation.

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
