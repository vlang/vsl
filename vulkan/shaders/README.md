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
| `adam_step.glsl` | fused Adam (grad, theta, m, v, params) |

Regenerate `../spv_adam.v` after editing GLSL.
