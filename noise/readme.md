# noise

This module aims to to implement noise algorithms.

It uses the `rand` module in vlib to generate random numbers, so you may seed the generator as you see fit.

Example:
```v
import vsl.noise
import rand

fn main() {
    rand.seed([u32(1), 0])
    println(noise.perlin(0.0, 0.0)?)
}
```
Output: `-0.6457864`