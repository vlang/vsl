# Geometry ML Clustering

This example demonstrates combining the geometry module with machine learning
for 3D spatial clustering and visualization.

## What You'll Learn

- Using geometry module for 3D points
- Applying ML clustering to geometric data
- Visualizing 3D clusters
- Combining multiple VSL modules

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/geometry_ml_clustering

# Run the example
v run main.v
```

## Expected Output

The example generates:

- **Console output**: Data generation, training progress, and accuracy
- **3D Plot**: Visualization of clusters with centroids marked

## Code Walkthrough

### 1. Generating Geometric Data

```v
import vsl.gm
import rand

rand.seed([u32(12345), u32(67890)])
mut points := []gm.Point{}

// Create 3D points using geometry module
x, y, z := 1.0, 2.0, 3.0
points << gm.Point.new(x, y, z)
```

We use the geometry module to create 3D points representing two clusters.

### 2. Converting to ML Format

```v
import vsl.gm

mut feature_matrix := [][]f64{}
points := []gm.Point{} // Assume populated

// Convert to feature matrix (2D projection for Kmeans)
for p in points {
	feature_matrix << [p.x, p.y]
}
```

Geometry points are converted to feature vectors for ML algorithms.

### 3. Clustering and Visualization

We apply K-means clustering and visualize results in 3D space.

## Use Cases

- **Spatial Analysis**: Cluster geographic or spatial data
- **Point Cloud Processing**: Analyze 3D point clouds
- **Robotics**: Cluster sensor readings in 3D space
- **Computer Vision**: Segment 3D objects

## Experiment Ideas

Try modifying the example to:

- **More clusters**: Add a third or fourth cluster
- **Different geometries**: Use different point distributions
- **Distance metrics**: Use geometry module's distance functions
- **Real data**: Import actual 3D point cloud data
- **Visualization**: Add cluster boundaries or surfaces

## Related Examples

- `gm_basic_geometry` - Basic geometry operations
- `ml_kmeans` - K-means clustering
- `plot_scatter3d_1` - 3D plotting

## Related Tutorials

- [Geometry Module](../../docs/advanced/04-library-integration.md)
- [Clustering](../../docs/machine-learning/02-clustering.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Low accuracy**: Try different initial centroids

**Plot doesn't open**: Ensure web browser is installed

**Module errors**: Verify VSL installation

---

Explore more geometry and ML examples in the [examples directory](../).
