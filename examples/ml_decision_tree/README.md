# Decision Tree Example 🤖

This example demonstrates classification and regression using VSL's Decision Tree algorithm.
Learn how decision trees make predictions by recursively splitting data based on feature values.

## 🎯 What You'll Learn

- Decision tree fundamentals
- Classification and regression with trees
- Splitting criteria (Gini, Entropy, MSE)
- Tree depth and overfitting
- Feature-based decision making

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Basic understanding of machine learning concepts

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/ml_decision_tree

# Run the example
v run main.v
```

## 📊 Expected Output

The example will output:

- Training configuration
- Predictions for test cases
- Regression example
- A plot showing data points

```text
Training decision tree...
Criterion: Gini impurity
Max depth: 5

Training completed!
Model trained: true

=== Predictions ===
Sunny, mild, normal:
  Features: [0.0, 1.0, 1.0]
  Predicted class: PLAY
```

## 🔍 Code Walkthrough

### 1. Data Preparation

The example uses a weather dataset for classification:

```v ignore
mut data := ml.Data.from_raw_xy_sep([
	[0.0, 0.0, 0.0], // Features: [outlook, temperature, humidity]
	// ...
], [
	0.0, // Target: don't play
	1.0, // Target: play
	// ...
])!
```

### 2. Model Configuration

Configure the decision tree:

```v ignore
mut model := ml.DecisionTree.new(mut data, 'weather_classifier')
model.set_criterion(.gini) // Gini impurity for classification
model.set_max_depth(5) // Limit depth to prevent overfitting
model.set_min_samples_split(2) // Minimum samples to split
model.set_min_samples_leaf(1) // Minimum samples in leaf
```

### 3. Training

Build the decision tree:

```v ignore
model.train()
```

The algorithm recursively splits data based on feature values to minimize impurity.

### 4. Prediction

Make predictions:

```v ignore
predicted_class := model.predict([0.0, 1.0, 1.0])
```

## 📐 Mathematical Background

### Gini Impurity

For classification, Gini impurity measures class distribution:

```
Gini = 1 - Σ(pᵢ)²
```

Where pᵢ is the proportion of class i.

### Information Gain

Information gain measures how much a split reduces entropy:

```
Gain = Entropy(parent) - Σ(|child|/|parent|) × Entropy(child)
```

### Mean Squared Error (MSE)

For regression, MSE measures variance:

```
MSE = (1/n) Σ(yᵢ - ȳ)²
```

## 🎨 Experiment Ideas

Try modifying the example to:

- **Change criterion**: Compare Gini vs Entropy for classification
- **Adjust max_depth**: See how depth affects overfitting
- **Modify min_samples_split**: Control when splits occur
- **Try regression**: Use continuous target values
- **Different datasets**: Try real-world classification problems
- **Visualize tree structure**: Print decision rules

## 📚 Related Examples

- `ml_random_forest` - Ensemble of decision trees
- `ml_logreg` - Logistic regression for comparison
- `ml_svm` - Support Vector Machine classification

## 📖 Related Tutorials

- [Classification](../../docs/machine-learning/04-classification.md) - Classification overview
- [Decision Trees](../../docs/machine-learning/07-decision-trees.md) - Detailed guide

## 🔬 Technical Details

**Key VSL Components:**

- `ml.DecisionTree` - Decision tree model
- `ml.CriterionType` - Splitting criteria
- `ml.Data` - Data container

**Splitting Criteria:**

- `.gini` - Gini impurity (fast, default for classification)
- `.entropy` - Information gain (slower, sometimes more accurate)
- `.mse` - Mean Squared Error (for regression)

**Performance Notes:**

- Training: O(n × m × log(n)) where n=samples, m=features
- Prediction: O(depth) - very fast
- Memory: O(n) for tree structure

## 🐛 Troubleshooting

**Model overfits**: Reduce max_depth or increase min_samples_split

**Poor accuracy**: Try different criterion, check data quality

**Tree too deep**: Set max_depth limit

**Plot doesn't open**: Ensure web browser is installed

**Module errors**: Verify VSL installation with `v list` command

---

Happy coding! Explore more ML examples in the [examples directory](../).
