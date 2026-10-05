# `vsl.noise`

`vsl.noise.Generator` holds a permutation table for Perlin and simplex noise.
Create a generator, seed V's `rand` module first when repeatable output is
needed, then call `randomize()` to shuffle its table.

| Method | Dimensions |
| --- | --- |
| `perlin2d(x, y)`, `perlin3d(x, y, z)` | Classic gradient Perlin noise in 2D and 3D. |
| `simplex_1d(x)` through `simplex_4d(x, ...)` | Simplex noise in one through four dimensions. |

Values are scalar `f64`s. Scale coordinates to control frequency; combine
several frequencies in an application when building fractal noise.

```v
import rand
import vsl.noise

rand.seed([u32(3155200429), u32(3208395956)])
mut generator := noise.Generator.new()
generator.randomize()
sample := generator.simplex_2d(0.03, 0.06)
println(sample)
```

Examples: [2D simplex heatmap](../examples/noise_simplex_2d/README.md),
[fractal noise](../examples/noise_fractal_2d/README.md), and
[quaternion noise](../examples/noise_quaternion_fractal/README.md). See
[`noise.v`](noise.v) and [`simplex.v`](simplex.v) for the exported methods.
