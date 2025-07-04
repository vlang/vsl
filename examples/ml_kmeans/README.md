# K-Means Clustering Example 🤖

This example demonstrates unsupervised machine learning using VSL's K-means clustering algorithm.
Learn how to group data points into meaningful clusters automatically.

## 🎯 What You'll Learn

- K-means clustering fundamentals
- Data preparation for machine learning
- Working with VSL's ML observer pattern
- Centroid initialization and optimization
- Model training and validation

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Basic understanding of machine learning concepts

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/ml_kmeans

# Run the example
v run main.v
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
- **Initial centroids**: Manually set to separate the clusters
- **Training epochs**: 6 iterations

### 3. Training Process

1. **Find closest centroids**: Assign each point to nearest cluster center
2. **Compute centroids**: Recalculate cluster centers based on assignments
3. **Iterate**: Repeat until convergence

## 🎨 Experiment Ideas

Try modifying the example:

- **Add more data points** to see clustering behavior
- **Change the number of clusters** (k parameter)
- **Use random centroid initialization** instead of manual
- **Visualize the clustering process** (see `ml_kmeans_plot` example)

## 📚 Related Examples

- `ml_kmeans_plot` - K-means with visualization
- `ml_knn_plot` - K-Nearest Neighbors algorithm
- `data_analysis_example` - Comprehensive data analysis

## 🔬 Technical Details

The example uses VSL's **observer pattern**: the model automatically updates when data changes,
making it suitable for dynamic datasets.

**Key VSL Components:**

- `ml.Data.from_raw_x()` - Data container creation
- `ml.Kmeans.new()` - Model initialization
- `model.train()` - Training execution

## 🐛 Troubleshooting

**Assertion errors**: Check that your V compiler supports the latest VSL syntax

**ML module not found**: Ensure VSL is properly installed with `v list`

**Convergence issues**: Try different initial centroids or more training epochs

---

Ready to explore machine learning with VSL! 🚀 Check out more ML examples in the
[examples directory](../).
