# ML Quaternion Features

This example demonstrates using quaternions as features for machine learning,
combining the quaternion and ML modules.

## What You'll Learn

- Extracting features from quaternions for ML
- Using quaternion components as input features
- Training clustering models on quaternion data
- Visualizing quaternion features

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/ml_quaternion_features

# Run the example
v run main.v
```

## Expected Output

The example generates:

- **Console output**: Data generation, training progress, and accuracy results
- **2D Plot**: Visualization of quaternion features (x vs y components)
- **Clustering results**: Accuracy of K-means clustering on quaternion features

## Code Walkthrough

### 1. Generating Quaternion Data

```v ignore
import vsl.quaternion
import math

n_samples := 50
angle := math.pi / 4.0
mut quaternion_data := []quaternion.Quaternion{}

// Create two groups of orientations
for i in 0..n_samples {
    if i < n_samples / 2 {
        // Group 1: x-axis rotations
        q := quaternion.from_axis_anglef3(angle, 1.0, 0.0, 0.0)
        quaternion_data << q
    } else {
        // Group 2: y-axis rotations
        q := quaternion.from_axis_anglef3(angle, 0.0, 1.0, 0.0)
        quaternion_data << q
    }
}
```

We generate synthetic orientation data with two distinct groups.

### 2. Feature Extraction

```v ignore
import vsl.quaternion

mut feature_matrix := [][]f64{}
quaternion_data := []quaternion.Quaternion{}  // Assume populated

// Extract quaternion components as features
for q in quaternion_data {
    feature_matrix << [q.x, q.y]  // 2D for Kmeans compatibility
}
```

Quaternion components (w, x, y, z) become 4-dimensional feature vectors.

### 3. Machine Learning

```v ignore
import vsl.ml

feature_matrix := [][]f64{}  // Assume populated
mut data := ml.Data.from_raw_x(feature_matrix)!
mut train_data, _ := data.split(0.8)!
nb_classes := 2
mut model := ml.Kmeans.new(mut train_data, nb_classes, 'quaternion_kmeans')
model.train(epochs: 10)
```

We train a K-means clustering model to identify the two groups.

## Use Cases

- **Robotics**: Classify robot orientations
- **Motion Analysis**: Identify movement patterns
- **Sensor Data**: Process IMU/orientation sensor data
- **Animation**: Classify animation poses

## Experiment Ideas

Try modifying the example to:

- **More features**: Add derived features (magnitude, angle, etc.)
- **Different algorithms**: Try regression or classification
- **Real data**: Use actual sensor data
- **More groups**: Add a third orientation group
- **Feature engineering**: Create additional features from quaternions

## Related Examples

- `ml_kmeans` - Basic K-means clustering
- `quaternion_orientation_tracking` - Orientation tracking
- `quaternion_rotation_3d` - Quaternion rotations

## Related Tutorials

- [Machine Learning Data Preparation](../../docs/machine-learning/01-data-preparation.md)
- [Clustering](../../docs/machine-learning/02-clustering.md)
- [Quaternion Introduction](../../docs/quaternions/01-introduction.md)

## Troubleshooting

**Low accuracy**: Try different initial centroids or more training epochs

**Plot doesn't open**: Ensure web browser is installed

**Module errors**: Verify VSL installation

---

Explore more ML and quaternion examples in the [examples directory](../).

