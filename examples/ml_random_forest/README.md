# Random Forest Example 🤖

This example demonstrates ensemble learning using VSL's Random Forest algorithm.
Learn how combining multiple decision trees improves prediction accuracy and reduces overfitting.

## 🎯 What You'll Learn

- Random Forest fundamentals
- Ensemble learning concepts
- Bootstrap aggregation (bagging)
- Classification and regression with Random Forest
- Feature importance
- Comparison with single decision trees

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Basic understanding of machine learning concepts

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/ml_random_forest

# Run the example
v run main.v
```

## 📊 Expected Output

The example will output:

- Training configuration
- Number of trees trained
- Predictions with probabilities
- Comparison with single decision tree
- Regression example
- A plot showing data points

```text
Training Random Forest...
Number of trees: 50
Bootstrap sampling: true

Training completed!
Number of trees trained: 50

=== Predictions ===
Setosa-like flower:
  Features: [5.0, 3.4, 1.5, 0.2]
  Predicted class: SETOSA
  Probability (class 1): 0.0200
```

## 🔍 Code Walkthrough

### 1. Data Preparation

The example uses a flower classification dataset:

```v ignore
mut data := ml.Data.from_raw_xy_sep([
	[5.1, 3.5, 1.4, 0.2], // Features: [sepal_length, sepal_width, petal_length, petal_width]
	// ...
], [
	0.0, // Target: setosa
	1.0, // Target: versicolor
	// ...
])!
```

### 2. Model Configuration

Configure the Random Forest:

```v ignore
mut model := ml.RandomForest.new(mut data, 'flower_classifier')
model.set_n_estimators(50) // Number of trees
model.set_bootstrap(true) // Use bootstrap sampling
```

### 3. Training

Train the ensemble:

```v ignore
model.train()
```

The algorithm:
1. Creates bootstrap samples for each tree
2. Trains decision trees on different samples
3. Combines predictions through voting (classification) or averaging (regression)

### 4. Prediction

Make predictions:

```v ignore
predicted_class := model.predict([6.2, 3.0, 4.5, 1.5])
probability := model.predict_proba([6.2, 3.0, 4.5, 1.5])
```

## 📐 Mathematical Background

### Bootstrap Aggregation (Bagging)

Random Forest uses bagging:

1. **Bootstrap Sampling**: Each tree trains on a random sample (with replacement) of the data
2. **Feature Sampling**: Each split considers a random subset of features
3. **Aggregation**: Predictions are combined:
   - **Classification**: Majority vote
   - **Regression**: Average

### Why Random Forest Works

- **Reduces Variance**: Averaging multiple trees reduces overfitting
- **Increases Robustness**: Less sensitive to noise and outliers
- **Handles Non-linearity**: Multiple trees capture different patterns
- **Feature Importance**: Can identify important features

### Ensemble Prediction

**Classification:**
```
prediction = mode(tree₁(x), tree₂(x), ..., treeₙ(x))
```

**Regression:**
```
prediction = (1/n) × Σ treeᵢ(x)
```

## 🎨 Experiment Ideas

Try modifying the example to:

- **Change number of trees**: See how n_estimators affects accuracy
- **Disable bootstrap**: Compare with and without bootstrap sampling
- **Compare with single tree**: See improvement from ensemble
- **Feature importance**: Analyze which features matter most
- **Different datasets**: Try real-world classification/regression problems
- **Tune tree parameters**: Adjust max_depth, min_samples_split for individual trees

## 📚 Related Examples

- `ml_decision_tree` - Single decision tree for comparison
- `ml_logreg` - Logistic regression
- `ml_svm` - Support Vector Machine

## 📖 Related Tutorials

- [Classification](../../docs/machine-learning/04-classification.md) - Classification overview
- [Decision Trees](../../docs/machine-learning/07-decision-trees.md) - Single trees
- [Random Forest](../../docs/machine-learning/08-random-forest.md) - Detailed guide

## 🔬 Technical Details

**Key VSL Components:**

- `ml.RandomForest` - Random Forest model
- `ml.DecisionTree` - Individual trees
- `ml.Data` - Data container

**Hyperparameters:**

- **n_estimators**: Number of trees (more = better but slower, typical: 50-200)
- **bootstrap**: Whether to use bootstrap sampling (default: true)
- **max_features**: Features per split (default: sqrt(n_features))

**Performance Notes:**

- Training: O(n_estimators × n_samples × log(n_samples))
- Prediction: O(n_estimators × depth) - still fast
- Memory: O(n_estimators × n_samples) - more than single tree

## 🐛 Troubleshooting

**Model overfits**: Reduce n_estimators, increase tree regularization

**Slow training**: Reduce n_estimators, use fewer features

**Poor accuracy**: Increase n_estimators, check data quality

**Plot doesn't open**: Ensure web browser is installed

**Module errors**: Verify VSL installation with `v list` command

---

Happy coding! Explore more ML examples in the [examples directory](../).
