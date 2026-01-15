# Logistic Regression

Learn logistic regression for binary classification in VSL.

## What You'll Learn

- Binary classification with logistic regression
- Probability predictions
- Model training (gradient descent and Newton's method)
- Cost function and optimization
- Decision boundaries

## Introduction

Logistic regression is a classification algorithm used to predict binary
outcomes (0 or 1). Unlike linear regression which predicts continuous values,
logistic regression predicts probabilities using the sigmoid function.

### When to Use Logistic Regression

- Binary classification problems (yes/no, pass/fail, spam/not spam)
- When you need probability estimates, not just class labels
- When the relationship between features and target is approximately linear in log-odds space
- As a baseline model before trying more complex algorithms

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
    0.0,  // Label 1 (class 0)
    1.0,  // Label 2 (class 1)
    // ...
})!

// Create logistic regression model
mut model := ml.LogReg.new(mut data, 'my_model')
```

### Training

Train the model using gradient descent:

```v ignore
// Train with default settings
model.train(epochs: 1000, learning_rate: 0.01)

// Or use Newton's method for faster convergence
model.train(epochs: 10, use_newton: true)
```

### Making Predictions

```v ignore
// Predict probability of positive class
probability := model.predict([1.5, 2.5])
// Returns a value between 0.0 and 1.0

// Convert to class prediction
predicted_class := if probability >= 0.5 { 1.0 } else { 0.0 }
```

## Mathematical Background

### Sigmoid Function

The sigmoid (logistic) function maps any real number to a value between 0 and 1:

```
σ(z) = 1 / (1 + e^(-z))
```

Where `z = b + x₁θ₁ + x₂θ₂ + ... + xₙθₙ`

- `b` is the bias term
- `xᵢ` are the feature values
- `θᵢ` are the model weights

### Cost Function

The cost function for logistic regression is:

```
C = (1/m) Σ[-y·log(h(x)) - (1-y)·log(1-h(x))] + (λ/2m)Σθ²
```

Where:
- `h(x) = σ(b + xᵀθ)` is the predicted probability
- `y` is the true label (0 or 1)
- `m` is the number of samples
- `λ` is the regularization parameter (optional)

The regularization term `(λ/2m)Σθ²` helps prevent overfitting.

### Training Methods

**Gradient Descent:**
- Iteratively updates parameters: `θ := θ - α·∇C`
- `α` is the learning rate
- More stable, works well for large datasets
- Requires tuning learning rate

**Newton's Method:**
- Uses second-order derivatives (Hessian matrix)
- Faster convergence (fewer iterations)
- More computation per iteration
- Better for small to medium datasets

## Advanced Usage

### Cost and Gradients

```v ignore
// Compute current cost
cost := model.cost()

// Get gradients
dcdtheta, dcdb := model.gradients()
// dcdtheta: gradient with respect to theta
// dcdb: gradient with respect to bias
```

### Regularization

Set regularization parameter to prevent overfitting:

```v ignore
model.params.set_lambda(0.1)  // L2 regularization strength
```

Higher lambda values increase regularization (simpler model, less overfitting).

### Observer Pattern

Logistic regression implements the Observer pattern, automatically updating when data changes:

```v ignore
mut data := ml.Data.from_raw_xy_sep(x, y)!
mut model := ml.LogReg.new(mut data, 'model')

// When data changes, model automatically updates
new_x := la.Matrix.deep2(new_features)
data.set(new_x, new_y)!
// Model's internal state is automatically updated
```

## Example: Student Pass/Fail Prediction

```v ignore
import vsl.ml

// Features: [hours_studied, hours_slept]
// Target: 0.0 (fail) or 1.0 (pass)
mut data := ml.Data.from_raw_xy_sep([
    [1.0, 4.0],  // Failed
    [5.0, 7.0],  // Passed
    [6.0, 8.0],  // Passed
], [
    0.0,
    1.0,
    1.0,
])!

mut model := ml.LogReg.new(mut data, 'student_predictor')
model.train(epochs: 1000, learning_rate: 0.1)

// Predict for new student
probability := model.predict([4.0, 6.0])
println('Probability of passing: ${probability:.2f}')
```

## Visualization

```v ignore
import vsl.plot

// Get plotter with decision boundary
plt := model.get_plotter()
plt.show()!
```

The plot shows:
- Data points colored by class
- Decision boundary (sigmoid curve)
- Probability distribution

## Hyperparameter Tuning

### Learning Rate

- Too high: May overshoot optimal solution, cost may increase
- Too low: Slow convergence, may get stuck in local minima
- Typical range: 0.001 to 0.1

### Number of Epochs

- Too few: Model may not converge
- Too many: Wasted computation, risk of overfitting
- Monitor cost to determine convergence

### Regularization (Lambda)

- 0.0: No regularization (may overfit)
- 0.01-0.1: Light regularization
- 1.0+: Strong regularization (may underfit)

## Common Issues and Solutions

**Problem**: Model always predicts the same class
- **Solution**: Check feature scaling, try different initial parameters, increase learning rate

**Problem**: Cost increases during training
- **Solution**: Reduce learning rate, check for bugs in gradient computation

**Problem**: Model doesn't converge
- **Solution**: Increase epochs, adjust learning rate, try Newton's method

**Problem**: Overfitting
- **Solution**: Add regularization (increase lambda), use more training data

## Performance Considerations

- **Gradient Descent**: O(m·n) per iteration, where m=samples, n=features
- **Newton's Method**: O(m·n² + n³) per iteration (more expensive but fewer iterations)
- For large datasets (m > 10,000), gradient descent is usually preferred
- Feature scaling can improve convergence speed

## Next Steps

- [SVM](06-svm.md) - Support Vector Machines for non-linear classification
- [Decision Trees](07-decision-trees.md) - Tree-based classification
- [Examples](../../examples/ml_logreg/) - Working examples

