# VSL Vulkan compute

GPU compute via Vulkan shaders (GEMM, elementwise, im2col, pooling, fused Adam).

Elementwise: `vector_add`, `vector_mul`, `vector_sqrt`, fused `adam_step` (see `shaders/`).
Descriptor layouts support up to **8** storage-buffer bindings (`vulkan.h`).

## Running tests safely

Integration tests live in `vulkan_manual_test.v` (not `*_test.v`) so default `v test vsl` does not hit a `v_stable_sort` crash in the V test runner.

```bash
# From repo root
./bin/test --use-vulkan

# Or scoped
v -d vulkan test vsl/vulkan/vulkan_manual_test.v
VSL_TEST_VULKAN=1 v -d vulkan test vsl/vulkan/compute
```

On macOS, `bin/test` always skips Vulkan tests (no libvulkan runtime).

## Conv2d

`VulkanBackend.conv2d` uses **im2col + GEMM** (no padding). Compare with CPU in `vulkan/compute/conv2d_test.v`.

## VTL

Opt-in Vulkan linear forward: `v -d vulkan` and `examples/nn_cifar10_vulkan` in vlang/vtl.
