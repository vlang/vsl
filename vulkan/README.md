# VSL Vulkan compute

GPU compute via Vulkan shaders for VSL and downstream VTL f32 training.

Vulkan is opt-in (`-d vulkan`) and most integration tests are gated with
`VSL_TEST_VULKAN=1` to avoid surprising users without a Vulkan runtime.

## Status

| Area | Supported |
|------|-----------|
| Linear algebra | GEMM/GEMV f32 kernels behind f64 host APIs |
| Elementwise | `vector_add`, `vector_mul`, `vector_sqrt`, ReLU, Sigmoid, GELU |
| Convolution | `im2col` + GEMM Conv2D forward; backward `d_weight` GEMM |
| Pooling | AvgPool2D, GlobalAvgPool2D, MaxPool2D |
| Optimizers | Fused f32 `adam_step` shader |
| Descriptor layout | Up to **8** storage-buffer bindings (`vulkan.h`) |

Shader sources live in [`shaders/`](./shaders/); generated SPIR-V arrays are
embedded in `spv.v` and `spv_adam.v`.

## Running tests safely

Integration tests live in `vulkan_manual_test.v` (not `*_test.v`) so default
`v test vsl` does not hit a `v_stable_sort` crash in the V test runner.

```bash
# From repo root
./bin/test --use-vulkan

# Or scoped (use -prod on machines where debug Vulkan instance creation crashes)
VSL_TEST_VULKAN=1 VJOBS=1 v -prod -d vulkan test vulkan/compute/adam_step_vulkan_test.v
VSL_TEST_VULKAN=1 VJOBS=1 v -prod -d vulkan test vulkan/compute
```

On macOS, `bin/test` always skips Vulkan tests (no libvulkan runtime).

## Conv2D

`VulkanBackend.conv2d` uses **im2col + GEMM**. VTL uses the same-padding path
for f32 Conv2D training. Backward currently accelerates `d_weight` with GEMM and
keeps host-managed buffers for compatibility with VTL's CPU-backed tensors.

## Adam

`adam_step` is a fused f32 shader:

```text
m = beta1 * m + (1 - beta1) * grad
v = beta2 * v + (1 - beta2) * grad * grad
theta -= lr_t * m / (sqrt(v) + epsilon)
```

VTL calls this through `vsl.vulkan.compute.adam_step_vulkan_f32` when
`VTL_USE_VULKAN=1`.

## VTL

Opt-in Vulkan f32 training: `v -prod -d vulkan` and
`examples/nn_cifar10_vulkan` in [vlang/vtl](https://github.com/vlang/vtl).
