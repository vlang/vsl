# Geometry algorithms and structures

This package provides some functions to help with the solution of geometry problems.
It also includes some routines loosely related with geometry.

`Point` supports component-wise addition and subtraction. These operators
return new points and leave both inputs unchanged:

```v
import vsl.gm

a := gm.Point.new(1.0, 2.0, 3.0)
b := gm.Point.new(4.0, 6.0, 8.0)
sum := (*a) + (*b)
displacement := (*b) - (*a)
println(sum) // {5.0, 8.0, 11.0}
println(displacement) // {3.0, 4.0, 5.0}
```

## Examples

You can find comprehensive examples demonstrating the geometry module features in the main
examples directory:

- [`gm_basic_geometry`](../examples/gm_basic_geometry/) - Fundamental 3D geometry operations
- [`gm_advanced_analysis`](../examples/gm_advanced_analysis/) - Advanced geometric analysis
- [`gm_distance_analysis`](../examples/gm_distance_analysis/) - Distance calculation analysis
- [`gm_spatial_binning`](../examples/gm_spatial_binning/) - Spatial indexing and binning systems
- [`gm_geometry_playground`](../examples/gm_geometry_playground/) - Interactive geometry exploration
- [`gm_trajectory_simulation`](../examples/gm_trajectory_simulation/) - Motion analysis

Each example includes a complete `main.v` file and detailed `README.md` with mathematical
explanations.
