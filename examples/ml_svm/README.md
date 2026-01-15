# Support Vector Machine (SVM) Example 🤖

This example demonstrates binary classification using VSL's Support Vector Machine algorithm.
Learn how to find optimal decision boundaries and handle non-linearly
separable data using kernel functions.

## 🎯 What You'll Learn

- SVM fundamentals and maximum margin classification
- Kernel functions (linear, polynomial, RBF)
- Support vectors and their importance
- Handling non-linearly separable data
- Hyperparameter tuning (C, gamma)

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Basic understanding of machine learning concepts

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/ml_svm

# Run the example
v run main.v
```

## 📊 Expected Output

The example will output:

- Training progress and model configuration
- Number of support vectors found
- Predictions for test cases with probabilities
- Comparison between RBF and linear kernels
- A plot showing data points, support vectors, and decision boundary

```text
Training SVM with RBF kernel...
C (regularization): 10.0
Gamma (RBF parameter): 1.0

Training completed!
Number of support vectors: 8

=== Predictions ===
Center point:
  Features: [0.0, 0.0]
  Predicted class: INSIDE
  Probability: 0.9234
```

## 🔍 Code Walkthrough

### 1. Data Preparation

The example uses a circle classification dataset where:
- **Features**: `[x, y]` coordinates
- **Target**: `0.0` (outside circle) or `1.0` (inside circle)

```v ignore
mut data := ml.Data.from_raw_xy_sep([
	[2.0, 2.0], // Outside points
	[0.0, 0.0], // Inside points
	// ...
], [
	0.0, // outside
	1.0, // inside
	// ...
])!
```

### 2. Model Initialization

Create an SVM model and configure the kernel:

```v ignore
mut model := ml.SVM.new(mut data, 'circle_classifier')
model.set_kernel(.rbf, 1.0, 3) // RBF kernel with gamma=1.0
model.set_C(10.0) // Regularization parameter
```

**Kernel Types:**
- `.linear` - Linear kernel: K(xi, xj) = xi·xj
- `.polynomial` - Polynomial kernel: K(xi, xj) = (1 + xi·xj)^d
- `.rbf` - Radial Basis Function: K(xi, xj) = exp(-γ||xi - xj||²)

### 3. Training

Train the model using SMO (Sequential Minimal Optimization):

```v ignore
model.train(max_iter: 200, tolerance: 1e-3)
```

The algorithm finds support vectors and optimal decision boundary.

### 4. Prediction

Make predictions and get probabilities:

```v ignore
predicted_class := model.predict([0.5, 0.5])
probability := model.predict_proba([0.5, 0.5])
```

## 📐 Mathematical Background

### Maximum Margin

SVM finds the decision boundary that maximizes the margin (distance) between classes:

```
maximize: margin = 2 / ||w||
subject to: yi(w·xi + b) ≥ 1
```

### Kernel Trick

For non-linearly separable data, SVM uses kernel functions to map data to higher dimensions:

- **Linear**: No transformation
- **Polynomial**: Maps to polynomial feature space
- **RBF**: Maps to infinite-dimensional space

### Support Vectors

Support vectors are data points closest to the decision boundary.
They determine the boundary and margin.

## 🎨 Experiment Ideas

Try modifying the example to:

- **Change kernel type**: Compare linear, polynomial, and RBF kernels
- **Adjust C parameter**: See how regularization affects the decision boundary
- **Modify gamma**: Change RBF kernel parameter for different smoothness
- **Different datasets**: Try XOR problem, spiral data, or real-world data
- **Visualize decision boundary**: Add contour plot showing decision regions
- **Compare with other algorithms**: Compare SVM with logistic regression or KNN

## 📚 Related Examples

- `ml_logreg` - Logistic regression for comparison
- `ml_knn_plot` - K-Nearest Neighbors classification
- `ml_decision_tree` - Decision tree classification

## 📖 Related Tutorials

- [Classification](../../docs/machine-learning/04-classification.md) - Classification overview
- [SVM](../../docs/machine-learning/06-svm.md) - Detailed SVM guide

## 🔬 Technical Details

**Key VSL Components:**

- `ml.SVM` - Support Vector Machine model
- `ml.KernelType` - Kernel function types
- `ml.Data` - Data container with observer pattern

**Hyperparameters:**

- **C**: Regularization parameter (higher = less regularization, may overfit)
- **Gamma**: RBF kernel parameter (higher = more complex boundaries)
- **Degree**: Polynomial kernel degree

**Performance Notes:**

- SMO algorithm complexity: O(n²) to O(n³) depending on data
- RBF kernel is most versatile but computationally expensive
- Linear kernel is fastest but limited to linearly separable data

## 🐛 Troubleshooting

**Model doesn't converge**: Increase max_iter or adjust tolerance

**Too many support vectors**: Increase C parameter or try different kernel

**Poor classification**: Try RBF kernel with different gamma, or increase C

**Plot doesn't open**: Ensure web browser is installed and set as default

**Module errors**: Verify VSL installation with `v list` command

---

Happy coding! Explore more ML examples in the [examples directory](../).
