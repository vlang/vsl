# 3D Visualization

Create interactive 3D plots and visualizations.

## What You'll Learn

- 3D scatter plots
- Surface plots
- Customizing 3D views
- Interactive controls

## Prerequisites

- [2D Plotting](01-2d-plotting.md)

## 3D Scatter Plots

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
plt.scatter3d(x: x, y: y, z: z, mode: 'markers')
```

## Surface Plots

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
z_matrix := [[1.0, 2.0], [3.0, 4.0]]
plt.surface(z: z_matrix)
```

## Interactive Features

- Rotate, zoom, pan
- Hover information
- Multiple traces

## Next Steps

- [Examples](../../examples/plot_scatter3d_1/) - Working examples

