# Random Forest

Learn Random Forest for classification and regression in VSL.

## What You'll Learn

- Ensemble learning concepts
- Bootstrap aggregation (bagging)
- Random Forest algorithm
- Feature importance
- When to use Random Forest vs Decision Tree

## Introduction

Random Forest is an ensemble learning method that combines multiple decision trees to improve prediction accuracy and reduce overfitting. It uses bootstrap aggregation and random feature selection to create diverse trees.

### When to Use Random Forest

- Both classification and regression tasks
- Need better accuracy than single decision tree
- Want to reduce overfitting
- Need feature importance scores
- Medium to large datasets
- Non-linear relationships with feature interactions

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

// Create Random Forest
mut model := ml.RandomForest.new(mut data, 'my_model')
```

### Configuration

```v ignore
// Set number of trees
model.set_n_estimators(100)  // More trees = better but slower

// Configure bootstrap sampling
model.set_bootstrap(true)  // Use bootstrap (default: true)

// Set max features per split
model.set_max_features(5)  // Or -1 for sqrt(n_features)
```

### Training

```v ignore
// Train the forest
model.train()
```

### Making Predictions

```v ignore
// Single prediction
prediction := model.predict([1.5, 2.5])

// Get probability (classification only)
probability := model.predict_proba([1.5, 2.5])
```

## Mathematical Background

### Bootstrap Aggregation (Bagging)

Random Forest uses bagging:

1. **Bootstrap Sampling**: For each tree, sample n samples with replacement from training data
2. **Feature Sampling**: At each split, consider only a random subset of features
3. **Tree Building**: Build decision tree on bootstrap sample
4. **Aggregation**: Combine predictions:
   - **Classification**: Majority vote
   - **Regression**: Average

### Prediction

**Classification:**
```
ŷ = mode(T₁(x), T₂(x), ..., Tₙ(x))
```

**Regression:**
```
ŷ = (1/n) × Σ Tᵢ(x)
```

Where Tᵢ are individual trees.

### Why It Works

- **Variance Reduction**: Averaging reduces overfitting
- **Bias Unchanged**: Each tree has similar bias
- **Robustness**: Less sensitive to noise and outliers
- **Diversity**: Different trees capture different patterns

## Hyperparameter Tuning

### Number of Trees (n_estimators)

- **Low (10-50)**: Faster training, may underfit
- **Medium (50-200)**: Good balance (default: 100)
- **High (200+)**: Better accuracy but diminishing returns, slower

**Guidelines:**
- Start with 100
- Increase if accuracy improves
- Stop when accuracy plateaus

### Bootstrap Sampling

- **True**: Each tree uses different data sample (reduces overfitting)
- **False**: All trees use same data (faster but may overfit)

### Max Features

- **sqrt(n_features)**: Default, good for classification
- **log₂(n_features)**: Alternative
- **n_features**: All features (less random, more overfitting)
- **Small number**: More random, more diverse trees

## Advanced Usage

### Feature Importance

```v ignore
// Get feature importance scores
importance := model.get_feature_importance()
```

Feature importance measures how much each feature contributes to predictions.

### Observer Pattern

Random Forest implements the Observer pattern:

```v ignore
mut data := ml.Data.from_raw_xy_sep(x, y)!
mut model := ml.RandomForest.new(mut data, 'model')

// When data changes, model automatically updates
new_x := la.Matrix.deep2(new_features)
data.set(new_x, new_y)!
// Model is marked as not trained, needs retraining
```

## Example: Classification

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([
    [5.1, 3.5, 1.4, 0.2],
    [7.0, 3.2, 4.7, 1.4],
    // ...
], [
    0.0,
    1.0,
    // ...
])!

mut model := ml.RandomForest.new(mut data, 'classifier')
model.set_n_estimators(100)
model.train()

pred := model.predict([6.2, 3.0, 4.5, 1.5])
proba := model.predict_proba([6.2, 3.0, 4.5, 1.5])
println('Prediction: ${pred}, Probability: ${proba}')
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

mut model := ml.RandomForest.new(mut data, 'regressor')
model.set_n_estimators(50)
model.train()

pred := model.predict([1.5])
println('Prediction: ${pred}')
```

## Random Forest vs Decision Tree

| Aspect | Decision Tree | Random Forest |
|--------|---------------|---------------|
| **Accuracy** | Lower | Higher |
| **Overfitting** | Prone to overfit | Less overfitting |
| **Speed** | Fast | Slower (but still fast) |
| **Interpretability** | Very interpretable | Less interpretable |
| **Stability** | Unstable | Stable |
| **Feature Importance** | Basic | Better estimates |

**Use Decision Tree when:**
- Need interpretability
- Small dataset
- Fast training required
- Simple model needed

**Use Random Forest when:**
- Need better accuracy
- Want to reduce overfitting
- Medium to large dataset
- Feature importance needed

## Common Issues and Solutions

**Problem**: Slow training
- **Solution**: Reduce n_estimators, use fewer features, reduce dataset size

**Problem**: Still overfitting
- **Solution**: Increase tree regularization (max_depth, min_samples_split), reduce n_estimators

**Problem**: Poor accuracy
- **Solution**: Increase n_estimators, tune hyperparameters, check data quality

**Problem**: Memory usage too high
- **Solution**: Reduce n_estimators, use smaller dataset, limit tree depth

## Performance Considerations

- **Training**: O(n_estimators × n_samples × log(n_samples))
- **Prediction**: O(n_estimators × depth) - still very fast
- **Memory**: O(n_estimators × n_samples) - more than single tree
- **Scalability**: Good for medium datasets, may be slow for very large datasets

## Limitations

- Less interpretable than single decision tree
- Requires more memory and computation
- May be overkill for simple problems
- Feature importance is approximate

## Next Steps

- [Decision Trees](07-decision-trees.md) - Single decision trees
- [Examples](../../examples/ml_random_forest/) - Working examples

