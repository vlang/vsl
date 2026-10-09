# Validate Vulkan Conv2D against a CPU reference

Compare the VSL Vulkan Conv2D result with a small CPU implementation and assert that every output is within tolerance.

## Run

From `~/.vmodules`:

```sh
VSL_TEST_VULKAN=1 v -d vulkan run ./vsl/examples/vulkan_conv2d_check/main.v
```

## Notes

Run from `~/.vmodules` on a machine with Vulkan headers, loader, and a usable device. Without the environment variable the program exits with a skip message.
