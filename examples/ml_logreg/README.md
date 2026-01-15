# Logistic Regression Example 🤖

This example demonstrates binary classification using VSL's logistic regression algorithm.
Learn how to predict categorical outcomes (pass/fail, spam/not spam, etc.) using the sigmoid function.

## 🎯 What You'll Learn

- Logistic regression fundamentals
- Binary classification with probability outputs
- Model training using gradient descent
- Interpreting prediction probabilities
- Decision boundary visualization

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Basic understanding of machine learning concepts

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/ml_logreg

# Run the example
v run main.v
```

## 📊 Expected Output

The example will output:

- Initial and final cost values
- Predictions for test cases with probabilities
- Model parameters (weights and bias)
- A plot showing the data points and decision boundary

```text
Initial cost: 0.693147
Final cost: 0.123456
Cost reduction: 0.569691

=== Predictions ===
Average student:
  Features: [3.0, 5.0]
  Probability of passing: 0.4523
  Predicted class: FAIL

Good student:
  Features: [4.0, 6.0]
  Probability of passing: 0.6789
  Predicted class: PASS
```

## 🔍 Code Walkthrough

### 1. Data Preparation

The example uses a student dataset where:
- **Features**: `[hours_studied, hours_slept]`
- **Target**: `0.0` (fail) or `1.0` (pass)

```v
mut data := ml.Data.from_raw_xy_sep([
    [1.0, 4.0],  // Failed students
    [5.0, 7.0],  // Passed students
    // ...
], [
    0.0,  // fail
    1.0,  // pass
    // ...
])!
```

### 2. Model Initialization

Create a logistic regression model:

```v
mut model := ml.LogReg.new(mut data, 'student_pass_predictor')
```

The model automatically registers as an observer of the data, so it will update if the data changes.

### 3. Training

Train the model using gradient descent:

```v
model.train(epochs: 1000, learning_rate: 0.1)
```

You can also use Newton's method for faster convergence:

```v
model.train(epochs: 10, use_newton: true)
```

### 4. Prediction

Make predictions and interpret probabilities:

```v
probability := model.predict([4.0, 6.0])
predicted_class := if probability >= 0.5 { 'PASS' } else { 'FAIL' }
```

The `predict()` method returns a probability between 0 and 1, representing the likelihood of the positive class.

## 📐 Mathematical Background

### Sigmoid Function

Logistic regression uses the sigmoid (logistic) function to map linear combinations to probabilities:

```
σ(z) = 1 / (1 + e^(-z))
```

Where `z = b + x₁θ₁ + x₂θ₂ + ...`

### Cost Function

The cost function for logistic regression is:

```
C = (1/m) Σ[-y·log(h(x)) - (1-y)·log(1-h(x))] + (λ/2m)Σθ²
```

Where:
- `h(x)` is the sigmoid function
- `m` is the number of samples
- `λ` is the regularization parameter

### Training

The model minimizes the cost function using:
- **Gradient Descent**: Iteratively updates parameters using gradients
- **Newton's Method**: Uses second-order derivatives (Hessian) for faster convergence

## 🎨 Experiment Ideas

Try modifying the example to:

- **Add more features**: Include additional student attributes (attendance, quiz scores, etc.)
- **Change the threshold**: Use different probability thresholds (e.g., 0.6 instead of 0.5)
- **Try Newton's method**: Compare training speed with gradient descent
- **Regularization**: Experiment with different lambda values to prevent overfitting
- **Real data**: Use actual student performance data
- **Multi-class**: Extend to multi-class classification (though this requires one-vs-rest)

## 📚 Related Examples

- `ml_linreg_plot` - Linear regression for continuous predictions
- `ml_knn_plot` - K-Nearest Neighbors classification
- `ml_svm` - Support Vector Machine classification

## 📖 Related Tutorials

- [Classification](../../docs/machine-learning/04-classification.md) - Classification algorithms overview
- [Logistic Regression](../../docs/machine-learning/05-logistic-regression.md) - Detailed logistic regression guide

## 🔬 Technical Details

**Key VSL Components:**

- `ml.LogReg` - Logistic regression model
- `ml.Data` - Data container with observer pattern
- `ml.ParamsReg` - Parameter management

**Training Methods:**

- Gradient Descent: `train(epochs, learning_rate)`
- Newton's Method: `train(epochs, use_newton: true)`

**Performance Notes:**

- Gradient descent is more stable but slower
- Newton's method converges faster but requires more computation per iteration
- For large datasets, gradient descent is often preferred

## 🐛 Troubleshooting

**Model doesn't converge**: Try adjusting the learning rate or increasing epochs

**Predictions are always 0 or 1**: The model may be overfitting; try regularization

**Cost increases during training**: Learning rate may be too high; reduce it

**Plot doesn't open**: Ensure web browser is installed and set as default

**Module errors**: Verify VSL installation with `v list` command

---

Happy coding! Explore more ML examples in the [examples directory](../).

