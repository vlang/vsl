# K-Means Clustering Example 🤖

This example demonstrates unsupervised machine learning using VSL's K-means clustering algorithm.
Learn how to group data points into meaningful clusters automatically.

## 🎯 What You'll Learn

- K-means clustering fundamentals
- Data preparation for machine learning
- Working with VSL's ML observer pattern
- Reproducible K-means++ centroid initialization
- Model training and validation

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Basic understanding of machine learning concepts

## 🚀 Running the Example

```sh
v run vsl/examples/ml_kmeans/main.v
```

## 📊 Expected Output

The example will output cluster assignments for each data point:

```text
class 0: 0
class 1: 0
class 2: 0
class 3: 0
class 4: 1
class 5: 1
class 6: 1
class 7: 1
```

## 🔍 Algorithm Walkthrough

### 1. Data Preparation

The example uses 8 2D data points representing two distinct clusters:

- **Cluster 1**: Points around (0.2, 0.8)
- **Cluster 2**: Points around (0.8, 0.2)

### 2. Model Configuration

- **Number of clusters**: 2
- **Initial centroids**: K-means++ with seed `42`
- **Training**: Up to 100 iterations, stopping at centroid movement `1e-8`

### 3. Training Process

1. **Initialize**: Select data points using seeded K-means++
2. **Assign**: Choose the closest center for each point
3. **Update**: Recalculate each center and stop when movement is below tolerance

## 🎨 Experiment Ideas

Try modifying the example:

- **Add more data points** to see clustering behavior
- **Change the number of clusters** (k parameter)
- **Change the seed** and compare the reproducible initialization
- **Add a third feature** to use K-means beyond 2D data
- **Visualize the clustering process** (see `ml_kmeans_plot` example)

## 📚 Related Examples

- `ml_kmeans_plot` - K-means with visualization
- `ml_knn_plot` - K-Nearest Neighbors algorithm
- `data_analysis_example` - Comprehensive data analysis

## 🔬 Technical Details

The example uses VSL's **observer pattern**: the model resets sample assignments when the data
changes. K-means++ uses its own seeded generator and leaves the process-global RNG untouched.

**Key VSL Components:**

- `ml.Data.from_raw_x()` - Data container creation
- `ml.Kmeans.new_checked()` - Validated model initialization
- `model.initialize_kmeans_plus_plus(seed)` - Reproducible center selection
- `model.train()` - Training execution
- `model.inertia()` - Within-cluster sum of squared errors

## 🐛 Troubleshooting

**Assertion errors**: Check that your V compiler supports the latest VSL syntax

**ML module not found**: Ensure VSL is properly installed with `v list`

**Convergence issues**: Try different initial centroids or more training epochs

---

Ready to explore machine learning with VSL! 🚀 Check out more ML examples in the
[examples directory](../).
