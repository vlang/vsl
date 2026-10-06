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
