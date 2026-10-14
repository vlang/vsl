# VSL — ML Roadmap & Launch Tracking

Maintainer planning: **https://github.com/orgs/vlang/projects/8** (Vlang ML Roadmap — VSL + VTL; may require project access)

Repo roadmap: [ROADMAP.md](../ROADMAP.md) · CUDA: [cuda/README.md](../cuda/README.md)

## Done

| Issue | Topic |
|-------|--------|
| [#236](https://github.com/vlang/vsl/issues/236) | Multi-backend GPU architecture |
| [#237](https://github.com/vlang/vsl/issues/237)–[#239](https://github.com/vlang/vsl/issues/239) | Vulkan / CUDA / OpenCL foundations |
| [#280](https://github.com/vlang/vsl/issues/280) | Core CUDA kernels; LayerNorm follow-up: [#550](https://github.com/vlang/vsl/issues/550) |
| [#281](https://github.com/vlang/vsl/issues/281) | GPU numerical validation tests |
| [#282](https://github.com/vlang/vsl/issues/282) | vs NumPy benchmarks + PR comments |
| [#283](https://github.com/vlang/vsl/issues/283)–[#285](https://github.com/vlang/vsl/issues/285) | Vulkan gating, conv2d, `ComputeContext` tests |
| [#304](https://github.com/vlang/vsl/pull/304) | Vulkan Conv2D backward `d_weight` GEMM layout fix |
| [#305](https://github.com/vlang/vsl/pull/305) | Vulkan `vector_mul`, `vector_sqrt`, fused f32 `adam_step` shader |
| [#328](https://github.com/vlang/vsl/issues/328) | Expanded Windows test coverage and portable test-runner cleanup (#394) |
| [#534](https://github.com/vlang/vsl/issues/534) | Incremental and sample-weighted GaussianNB fitting (#536) |

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
[#65](https://github.com/vlang/vsl/issues/65) and the following scoped
follow-ups. The repository issue list is the source for live status.

- [#514](https://github.com/vlang/vsl/issues/514) preprocessing transformers and pipelines
- [#515](https://github.com/vlang/vsl/issues/515) cross-validation and model selection
- [#516](https://github.com/vlang/vsl/issues/516) probabilistic and ensemble estimators
- [#517](https://github.com/vlang/vsl/issues/517) regression estimator coverage
- [#518](https://github.com/vlang/vsl/issues/518) clustering and decomposition
- [#519](https://github.com/vlang/vsl/issues/519) nearest-neighbor APIs
- [#520](https://github.com/vlang/vsl/issues/520) root finding and minimization
- [#521](https://github.com/vlang/vsl/issues/521) quadrature and ODE solvers
- [#522](https://github.com/vlang/vsl/issues/522) interpolation and splines
- [#523](https://github.com/vlang/vsl/issues/523) probability distributions and RNG
- [#524](https://github.com/vlang/vsl/issues/524) sparse formats and iterative solvers
- [#525](https://github.com/vlang/vsl/issues/525) multi-GPU dispatch
- [#526](https://github.com/vlang/vsl/issues/526) GPU memory pools and zero-copy storage
- [#527](https://github.com/vlang/vsl/issues/527) cross-backend numerical stress validation
- [#528](https://github.com/vlang/vsl/issues/528) CUDA benchmark variants
- [#529](https://github.com/vlang/vsl/issues/529) scikit-learn and GSL comparisons
- [#530](https://github.com/vlang/vsl/issues/530) migration guides
- [#538](https://github.com/vlang/vsl/issues/538) complete supported Windows CPU test coverage
- [#540](https://github.com/vlang/vsl/issues/540) inverse error functions
- [#541](https://github.com/vlang/vsl/issues/541) fractional-order and spherical Bessel families
- [#543](https://github.com/vlang/vsl/issues/543) Bessel numerical error estimates
- [#545](https://github.com/vlang/vsl/issues/545) generic plotting adapters for VSL models
- [#546](https://github.com/vlang/vsl/issues/546) SciPy/GSL capability parity tracker
- [#547](https://github.com/vlang/vsl/issues/547) scaled complementary error function
- [#550](https://github.com/vlang/vsl/issues/550) CUDA LayerNorm GPU path and capability reporting

Issue #516 is partially implemented: GaussianNB provides fitted class
statistics, configurable priors, variance smoothing, posterior probabilities,
and incremental/sample-weighted fitting (#534, completed by #536). Other Naive
Bayes variants and ensemble estimators remain open.
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
