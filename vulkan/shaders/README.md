# Vulkan compute shaders (GLSL → SPIR-V)

Compile and embed:

```bash
cd vulkan/shaders
glslangValidator -S comp -V vector_mul.glsl -o vector_mul.spv
python3 embed_spv.py vector_mul.spv   # paste into ../spv_adam.v
```

Shaders:

| File | Op |
|------|-----|
| `gemm.glsl` | Tiled row-major f32 GEMM using 16-wide K blocks |
| `gemm_k32.glsl` | GEMM variant using 32-wide K blocks, selected for medium matrices |
| `gemm_m64_k32.glsl` | 64×64 output-tile GEMM using 32-wide K blocks |
| `vector_mul.glsl` | `dst = a * b` |
| `vector_sqrt.glsl` | `dst = sqrt(src)` |
| `softplus.glsl` | Stable Softplus activation |
| `selu.glsl` | Scaled exponential linear unit activation |
| `hardswish.glsl` | HardSwish activation |
| `adam_step.glsl` | fused Adam (grad, theta, m, v, params) |

Activation SPIR-V is embedded in `../spv_activations.v`. After editing an
activation shader, regenerate and format the embedded file from `~/.vmodules`:

```sh
./vsl/vulkan/shaders/build_activations.sh
VJOBS=2 v fmt -w ./vsl/vulkan/spv_activations.v
```

The existing elementwise and optimizer SPIR-V is embedded in `../spv_adam.v`.

To rebuild both GEMM SPIR-V kernels from `~/.vmodules`:

```sh
glslc -fshader-stage=compute --target-env=vulkan1.0 -O \
	./vsl/vulkan/shaders/gemm.glsl -o /tmp/gemm.spv
spirv-val --target-env vulkan1.0 /tmp/gemm.spv
glslc -fshader-stage=compute --target-env=vulkan1.0 -O \
	./vsl/vulkan/shaders/gemm_k32.glsl -o /tmp/gemm_k32.spv
spirv-val --target-env vulkan1.0 /tmp/gemm_k32.spv
glslangValidator -V --target-env vulkan1.0 -S comp -Os \
	./vsl/vulkan/shaders/gemm_m64_k32.glsl -o /tmp/gemm_m64_k32.spv
spirv-val --target-env vulkan1.0 /tmp/gemm_m64_k32.spv
```

Embed each validated binary as `gemm_spv`, `gemm_k32_spv`, and
`gemm_m64_k32_spv` in `./vsl/vulkan/spv.v`. `gemm` selects the 32-wide K,
32×32-output kernel for dimensions from 512 through 1024, and the 64×64-output
kernel for other dimensions where `M` and `N` are at least 64 and `K` at least
32. Smaller shapes use the original 16-wide K kernel. These thresholds are
hardware-dependent and should be changed only with benchmark evidence. Build
the tracked shared module so imports use the updated kernels:

```sh
systemd-run --user --scope \
	-p WorkingDirectory="$HOME/.vmodules" \
	-p MemoryMax=768M -p MemorySwapMax=0 --setenv=VJOBS=2 -- \
	v -shared -o ./vsl/vulkan/vulkan.so ./vsl/vulkan
```
