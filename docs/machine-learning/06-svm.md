# Support Vector Machine (SVM)

Learn Support Vector Machines for classification in VSL.

## What You'll Learn

- Maximum margin classification
- Kernel functions and the kernel trick
- Support vectors
- Non-linear classification
- Hyperparameter tuning

## Introduction

Support Vector Machine (SVM) is a powerful classification algorithm that finds
the optimal decision boundary by maximizing the margin between classes. It can
handle both linearly and non-linearly separable data using kernel functions.

### When to Use SVM

- Binary classification problems
- When you need a robust decision boundary
- Non-linearly separable data (with appropriate kernel)
- When interpretability of support vectors is useful
- Medium-sized datasets (SVM can be slow for very large datasets)

## Basic Usage

### Creating a Model

```v ignore
import vsl.ml

// Prepare data with features and binary labels (0.0 or 1.0)
mut data := ml.Data.from_raw_xy_sep([][]f64{
    [1.0, 2.0],  // Feature vector 1
    [2.0, 3.0],  // Feature vector 2
    // ...
}, []f64{
    0.0,  // Label 1
    1.0,  // Label 2
    // ...
})!

// Create SVM model
mut model := ml.SVM.new(mut data, 'my_model')
```

### Configuring Kernel

```v ignore
// Linear kernel (for linearly separable data)
model.set_kernel(.linear, 1.0, 3)

// RBF kernel (for non-linearly separable data)
model.set_kernel(.rbf, 1.0, 3)  // gamma=1.0

// Polynomial kernel
model.set_kernel(.polynomial, 1.0, 3)  // degree=3
```

### Setting Regularization

```v ignore
// Set C parameter (regularization strength)
model.set_C(10.0)  // Higher C = less regularization
```

### Training

```v ignore
// Train the model
model.train(max_iter: 200, tolerance: 1e-3)
```

### Making Predictions

```v ignore
// Predict class (-1.0 or 1.0, converted to 0.0 or 1.0)
predicted_class := model.predict([1.5, 2.5])

// Get probability estimate
probability := model.predict_proba([1.5, 2.5])
```

## Mathematical Background

### Maximum Margin

SVM finds the decision boundary that maximizes the margin between classes:

```
minimize: (1/2)||w||² + C·Σξᵢ
subject to: yi(w·xi + b) ≥ 1 - ξᵢ
```

Where:
- `w` is the weight vector
- `b` is the bias term
- `C` is the regularization parameter
- `ξᵢ` are slack variables (for soft margin)

### Kernel Functions

**Linear Kernel:**
```
K(xi, xj) = xi·xj
```

**Polynomial Kernel:**
```
K(xi, xj) = (1 + xi·xj)^d
```

**RBF (Radial Basis Function) Kernel:**
```
K(xi, xj) = exp(-γ||xi - xj||²)
```

The kernel trick allows SVM to work in high-dimensional feature spaces
without explicitly computing the transformation.

### Support Vectors

Support vectors are the data points closest to the decision boundary. They satisfy:
- `αᵢ > 0` (non-zero Lagrange multiplier)
- `yi(w·xi + b) = 1` (on the margin)

Only support vectors affect the decision boundary, making SVM memory efficient.

## Kernel Selection Guide

### Linear Kernel

**Use when:**
- Data is linearly separable
- Large number of features
- Need fast training

**Example:**
```v ignore
model.set_kernel(.linear, 1.0, 3)
```

### Polynomial Kernel

**Use when:**
- Moderate non-linearity
- Need interpretable feature interactions

**Parameters:**
- `degree`: Higher degree = more complex boundaries

**Example:**
```v ignore
model.set_kernel(.polynomial, 1.0, 3)  // degree=3
```

### RBF Kernel

**Use when:**
- Highly non-linear data
- Unknown data distribution
- Most versatile (default choice)

**Parameters:**
- `gamma`: Higher gamma = more complex boundaries, risk of overfitting

**Example:**
```v ignore
model.set_kernel(.rbf, 1.0, 3)  // gamma=1.0
```

## Hyperparameter Tuning

### C Parameter (Regularization)

- **Low C (0.1-1.0)**: More regularization, simpler model, larger margin
- **Medium C (1.0-10.0)**: Balanced (default: 1.0)
- **High C (10.0-100.0)**: Less regularization, complex model, smaller margin, risk of overfitting

**Guidelines:**
- Start with C=1.0
- Increase if model underfits
- Decrease if model overfits

### Gamma Parameter (RBF Kernel)

- **Low gamma (0.01-0.1)**: Smooth boundaries, considers distant points
- **Medium gamma (0.1-1.0)**: Balanced (default: 1.0)
- **High gamma (1.0-10.0)**: Sharp boundaries, focuses on nearby points, risk of overfitting

**Guidelines:**
- Start with gamma=1.0
- Use grid search or cross-validation
- Scale features before tuning

## Advanced Usage

### Accessing Support Vectors

```v ignore
// Get support vectors after training
support_vectors := model.support_vectors
support_vector_labels := model.support_vector_labels

println('Number of support vectors: ${support_vectors.len}')
```

### Observer Pattern

SVM implements the Observer pattern, automatically updating when data changes:

```v ignore
mut data := ml.Data.from_raw_xy_sep(x, y)!
mut model := ml.SVM.new(mut data, 'model')

// When data changes, model automatically updates
new_x := la.Matrix.deep2(new_features)
data.set(new_x, new_y)!
// Model is marked as not trained, needs retraining
```

## Example: Non-Linear Classification

```v ignore
import vsl.ml

// XOR-like dataset (non-linearly separable)
mut data := ml.Data.from_raw_xy_sep([
    [0.0, 0.0],
    [0.0, 1.0],
    [1.0, 0.0],
    [1.0, 1.0],
], [
    0.0,
    1.0,
    1.0,
    0.0,
])!

mut model := ml.SVM.new(mut data, 'xor_classifier')
model.set_kernel(.rbf, 1.0, 3)  // RBF kernel for non-linear separation
model.set_C(10.0)
model.train(max_iter: 200, tolerance: 1e-3)

// Predict
pred := model.predict([0.5, 0.5])
println('Prediction: ${pred}')
```

## Visualization

```v ignore
import vsl.plot

// Get plotter with support vectors highlighted
plt := model.get_plotter()
plt.show()!
```

The plot shows:
- Data points colored by class
- Support vectors (larger markers)
- Decision boundary (for 2D data)

## Common Issues and Solutions

**Problem**: Too many support vectors
- **Solution**: Increase C parameter, try different kernel

**Problem**: Poor classification accuracy
- **Solution**: Try RBF kernel, tune gamma, scale features

**Problem**: Slow training
- **Solution**: Use linear kernel, reduce dataset size, decrease max_iter

**Problem**: Overfitting
- **Solution**: Decrease C, decrease gamma (for RBF), add more training data

## Performance Considerations

- **Training complexity**: O(n²) to O(n³) depending on data
- **Memory**: Stores support vectors (usually small subset of data)
- **Prediction**: O(n_sv · n_features) where n_sv is number of support vectors
- **Kernel computation**: RBF is most expensive, linear is fastest

## Limitations

- Primarily for binary classification (extensions exist for multi-class)
- Can be slow for very large datasets
- Sensitive to feature scaling
- Requires careful hyperparameter tuning

## Next Steps

- [Decision Trees](07-decision-trees.md) - Tree-based classification
- [Random Forest](08-random-forest.md) - Ensemble of decision trees
- [Examples](../../examples/ml_svm/) - Working examples

