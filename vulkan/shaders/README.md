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
| `gemm.glsl` | Tiled row-major f32 GEMM using shared workgroup memory |
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

To rebuild GEMM SPIR-V from `~/.vmodules`:

```sh
glslc -fshader-stage=compute --target-env=vulkan1.0 -O \
	./vsl/vulkan/shaders/gemm.glsl -o /tmp/gemm.spv
spirv-val --target-env vulkan1.0 /tmp/gemm.spv
python3 ./vsl/vulkan/shaders/embed_spv.py /tmp/gemm.spv
```

Replace `gemm_spv` in `./vsl/vulkan/spv.v` with the generated array. Rebuild
the tracked shared module so imports use the updated kernel:

```sh
systemd-run --user --scope --wait \
	-p WorkingDirectory="$HOME/.vmodules" \
	-p MemoryMax=768M -p MemorySwapMax=0 --setenv=VJOBS=2 -- \
	v -shared -o ./vsl/vulkan/vulkan.so ./vsl/vulkan
```
