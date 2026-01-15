# Decision Trees

Learn decision trees for classification and regression in VSL.

## What You'll Learn

- Decision tree fundamentals
- Classification and regression
- Splitting criteria
- Overfitting and regularization
- Tree construction

## Introduction

Decision trees are versatile algorithms that can handle both classification and regression tasks. They make predictions by recursively splitting data based on feature values, creating a tree-like structure of decisions.

### When to Use Decision Trees

- Both classification and regression tasks
- Need interpretable models (easy to visualize and understand)
- Non-linear relationships
- Feature interactions are important
- As building blocks for ensemble methods (Random Forest)

## Basic Usage

### Creating a Model

```v ignore
import vsl.ml

// Prepare data
mut data := ml.Data.from_raw_xy_sep([][]f64{
    [1.0, 2.0],  // Feature vector 1
    [2.0, 3.0],  // Feature vector 2
    // ...
}, []f64{
    0.0,  // Label 1
    1.0,  // Label 2
    // ...
})!

// Create decision tree
mut model := ml.DecisionTree.new(mut data, 'my_model')
```

### Configuration

```v ignore
// Set splitting criterion
model.set_criterion(.gini)  // For classification
model.set_criterion(.mse)   // For regression

// Control tree complexity
model.set_max_depth(10)           // Maximum depth
model.set_min_samples_split(2)    // Minimum samples to split
model.set_min_samples_leaf(1)    // Minimum samples in leaf
```

### Training

```v ignore
// Build the tree
model.train()
```

### Making Predictions

```v ignore
// Single prediction
prediction := model.predict([1.5, 2.5])

// Batch predictions
predictions := model.predict_batch([
    [1.5, 2.5],
    [2.0, 3.0],
])
```

## Mathematical Background

### Gini Impurity

For classification, Gini impurity measures class distribution:

```
Gini = 1 - Σ(pᵢ)²
```

Where pᵢ is the proportion of class i in the node.

- **Gini = 0**: Pure node (all same class)
- **Gini = 0.5**: Maximum impurity (equal classes)

### Entropy / Information Gain

Entropy measures uncertainty:

```
Entropy = -Σ(pᵢ × log₂(pᵢ))
```

Information gain measures how much a split reduces entropy:

```
Gain = Entropy(parent) - Σ(|child|/|parent|) × Entropy(child)
```

### Mean Squared Error (MSE)

For regression, MSE measures variance:

```
MSE = (1/n) Σ(yᵢ - ȳ)²
```

Where ȳ is the mean of target values in the node.

## Splitting Criteria

### Gini Impurity (Classification)

- **Pros**: Fast computation, works well in practice
- **Cons**: May prefer splits that create larger child nodes
- **Use when**: Default choice for classification

### Entropy (Classification)

- **Pros**: More sensitive to class distribution changes
- **Cons**: Slower computation (logarithm)
- **Use when**: Want more balanced splits

### MSE (Regression)

- **Pros**: Standard for regression
- **Cons**: Sensitive to outliers
- **Use when**: Regression tasks

## Tree Construction

The algorithm recursively:

1. **Find best split**: Try all features and thresholds
2. **Split data**: Create left and right child nodes
3. **Recurse**: Build subtrees for each child
4. **Stop**: When stopping criteria met (depth, purity, samples)

### Stopping Criteria

- Maximum depth reached
- Minimum samples for split not met
- Node is pure (impurity = 0)
- No improvement from splitting

## Overfitting and Regularization

Decision trees are prone to overfitting. Control complexity with:

### Max Depth

```v ignore
model.set_max_depth(5)  // Limit tree depth
```

- **Too shallow**: Underfitting, may miss patterns
- **Too deep**: Overfitting, memorizes training data
- **Guideline**: Start with log₂(n_samples) or sqrt(n_features)

### Min Samples Split

```v ignore
model.set_min_samples_split(10)  // Require more samples to split
```

- Higher values = simpler trees, less overfitting

### Min Samples Leaf

```v ignore
model.set_min_samples_leaf(5)  // Require minimum samples in leaves
```

- Higher values = smoother predictions, less overfitting

## Advanced Usage

### Classification vs Regression

The model automatically detects task type:

```v ignore
// Classification (discrete labels)
y := [0.0, 1.0, 0.0, 1.0]

// Regression (continuous values)
y := [0.5, 1.2, 2.3, 3.7]
```

### Observer Pattern

Decision trees implement the Observer pattern:

```v ignore
mut data := ml.Data.from_raw_xy_sep(x, y)!
mut model := ml.DecisionTree.new(mut data, 'model')

// When data changes, model automatically updates
new_x := la.Matrix.deep2(new_features)
data.set(new_x, new_y)!
// Model is marked as not trained, needs retraining
```

## Example: Classification

```v ignore
import vsl.ml

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

mut model := ml.DecisionTree.new(mut data, 'classifier')
model.set_criterion(.gini)
model.set_max_depth(5)
model.train()

pred := model.predict([0.5, 0.5])
println('Prediction: ${pred}')
```

## Example: Regression

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([
    [0.0],
    [1.0],
    [2.0],
    [3.0],
], [
    0.0,
    2.0,
    4.0,
    6.0,
])!

mut model := ml.DecisionTree.new(mut data, 'regressor')
model.set_criterion(.mse)
model.set_max_depth(3)
model.train()

pred := model.predict([1.5])
println('Prediction: ${pred}')
```

## Visualization

```v ignore
import vsl.plot

// Get plotter (2D data only)
plt := model.get_plotter()
plt.show()!
```

## Common Issues and Solutions

**Problem**: Overfitting
- **Solution**: Reduce max_depth, increase min_samples_split, increase min_samples_leaf

**Problem**: Underfitting
- **Solution**: Increase max_depth, decrease min_samples_split

**Problem**: Slow training
- **Solution**: Reduce max_depth, use fewer features, reduce dataset size

**Problem**: Poor accuracy
- **Solution**: Try different criterion, check data quality, tune hyperparameters

## Performance Considerations

- **Training**: O(n × m × log(n)) where n=samples, m=features
- **Prediction**: O(depth) - very fast
- **Memory**: O(n) for tree structure
- **Scalability**: Good for medium datasets, may be slow for very large datasets

## Limitations

- Can overfit easily without regularization
- Sensitive to small data changes (unstable)
- May create biased trees if classes are imbalanced
- Greedy algorithm (may not find global optimum)

## Next Steps

- [Random Forest](08-random-forest.md) - Ensemble of decision trees
- [Examples](../../examples/ml_decision_tree/) - Working examples

