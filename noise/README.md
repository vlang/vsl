# noise

This module aims to to implement noise algorithms.

It uses the `rand` module in vlib to generate random numbers,
so you may seed the generator as you see fit.

## Example

```v
import rand
import vsl.noise

rand.seed([u32(3807353518), 2705198303])
println(noise.perlin(0.0, 0.0)?)
```

Output: `0.58872`
