# VSL — ML Roadmap & Launch Tracking

Central planning: **https://github.com/orgs/vlang/projects/8**

Repo roadmap: [ROADMAP.md](../ROADMAP.md) · CUDA status: [cuda/README.md](../cuda/README.md)

## Critical path (open issues)

| Priority | Issue | Topic |
|----------|-------|--------|
| P0 | [#280](https://github.com/vlang/vsl/issues/280) | Finish CUDA stubs (LayerNorm, mul_vec) + docs |
| P0 | [#281](https://github.com/vlang/vsl/issues/281) | GPU vs CPU numerical validation |
| P0 | [#283](https://github.com/vlang/vsl/issues/283) | Fix `vulkan_test.v` crash |
| P1 | [#282](https://github.com/vlang/vsl/issues/282) | vs NumPy benchmark suite |
| P1 | [#225](https://github.com/vlang/vsl/issues/225) | Windows build |
| P1 | [#91](https://github.com/vlang/vsl/issues/91) | BLAS on macOS |
| P1 | [#194](https://github.com/vlang/vsl/issues/194) | Optional MPI in `vsl.la` |

VTL integration (downstream): [vlang/vtl#89](https://github.com/vlang/vtl/issues/89),
[#90](https://github.com/vlang/vtl/issues/90), [#91](https://github.com/vlang/vtl/issues/91).

## Local development

```bash
v up
cd ~/.vmodules
# Smoke — do not require full v test vsl locally (Vulkan test can fail/OOM)
v test vsl/blas vsl/la vsl/ml
# CUDA smoke (GPU machine)
v -d cuda test vsl/cuda/examples/cuda_ops_test.v
```

## Closed epics (2026-05-30)

#236 and #238 closed — infrastructure merged; follow-ups are #280–282 and VTL #89–91.
