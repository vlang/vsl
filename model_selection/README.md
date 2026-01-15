# VSL Model Selection Module

The `vsl.model_selection` module provides utilities for splitting data and
performing cross-validation for machine learning model evaluation.

## Features

### Train-Test Splitting
- **train_test_split**: Split arrays into random train and test subsets
- **train_val_test_split**: Three-way split into train, validation, and test
- **Stratified splitting**: Preserve class proportions in splits

### Cross-Validation
- **KFold**: K-Fold cross-validation iterator
- **StratifiedKFold**: Stratified K-Fold (preserves class balance)
- **LeaveOneOut**: Leave-one-out cross-validation
- **ShuffleSplit**: Random permutation cross-validator

## Quick Start

### Basic Train-Test Split

```v
import vsl.model_selection

x := [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [7.0, 8.0], [9.0, 10.0]]
y := [0.0, 1.0, 0.0, 1.0, 0.0]

result := model_selection.train_test_split(x, y, model_selection.TrainTestSplitConfig{
	test_size:   0.2
	shuffle:     true
	random_seed: 42
})!

println('Train size: ${result.x_train.len}')
println('Test size: ${result.x_test.len}')
```

### Stratified Split (Preserve Class Proportions)

```v
import vsl.model_selection

x := [[1.0], [2.0], [3.0], [4.0], [5.0], [6.0], [7.0], [8.0],
	[9.0], [10.0]]
y := [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0]

result := model_selection.train_test_split(x, y, model_selection.TrainTestSplitConfig{
	test_size: 0.3
	stratify:  true // Maintains 50/50 class balance in both sets
})!
```

### Train-Validation-Test Split

```v ignore
import vsl.model_selection

result := model_selection.train_val_test_split(x, y, model_selection.TrainValTestConfig{
	val_size:  0.1 // 10% validation
	test_size: 0.2 // 20% test (70% train)
	stratify:  true
})!

println('Train: ${result.x_train.len}')
println('Val: ${result.x_val.len}')
println('Test: ${result.x_test.len}')
```

### K-Fold Cross-Validation

```v ignore
import vsl.model_selection

kf := model_selection.KFold.new(5, true, 42)
folds := kf.split(100)! // 100 samples

for i, fold in folds {
	println('Fold ${i + 1}:')
	println('  Train indices: ${fold.train_indices.len}')
	println('  Test indices: ${fold.test_indices.len}')

	// Get actual data for this fold
	x_train, y_train, x_test, y_test := model_selection.get_fold_data(x, y, fold)

	// Train and evaluate your model here
}
```

### Stratified K-Fold

```v
import vsl.model_selection

y := [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

skf := model_selection.StratifiedKFold.new(5, true, 42)
folds := skf.split(y)!

// Each fold maintains class proportions
```

### Leave-One-Out Cross-Validation

```v
import vsl.model_selection

loo := model_selection.LeaveOneOut.new()
folds := loo.split(10) // Returns 10 folds, each with 1 test sample

for fold in folds {
	// fold.test_indices has exactly 1 element
	// fold.train_indices has n-1 elements
}
```

### Shuffle Split (Multiple Random Splits)

```v
import vsl.model_selection

ss := model_selection.ShuffleSplit.new(10, 0.2, 42) // 10 splits, 20% test
folds := ss.split(100)!

// Creates 10 different random splits
```

## API Reference

### TrainTestSplitConfig

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `test_size` | `f64` | `0.25` | Proportion for test set (0.0-1.0) |
| `shuffle` | `bool` | `true` | Whether to shuffle before splitting |
| `stratify` | `bool` | `false` | Preserve class proportions |
| `random_seed` | `u32` | `42` | Random seed for reproducibility |

### TrainValTestConfig

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `val_size` | `f64` | `0.1` | Proportion for validation set |
| `test_size` | `f64` | `0.2` | Proportion for test set |
| `shuffle` | `bool` | `true` | Whether to shuffle |
| `stratify` | `bool` | `false` | Preserve class proportions |
| `random_seed` | `u32` | `42` | Random seed |

### Cross-Validators

| Class | Description |
|-------|-------------|
| `KFold` | Standard K-Fold CV |
| `StratifiedKFold` | Stratified K-Fold (for classification) |
| `LeaveOneOut` | Leave-one-out CV (n folds for n samples) |
| `ShuffleSplit` | Random permutation splits |

### Fold Structure

```v
pub struct Fold {
pub:
	train_indices []int // Indices for training
	test_indices  []int // Indices for testing
}
```

### Helper Functions

| Function | Description |
|----------|-------------|
| `get_fold_data(x, y, fold)` | Extract actual data arrays from fold indices |

## Integration with ML Pipeline

```v ignore
import vsl.model_selection
import vsl.metrics
import vsl.ml

// Prepare data
x := your_features
y := your_labels

// Cross-validation
kf := model_selection.KFold.new(5, true, 42)
folds := kf.split(x.len)!

mut scores := []f64{}

for fold in folds {
	x_train, y_train, x_test, y_test := model_selection.get_fold_data(x, y, fold)

	// Create ML Data
	mut train_data := ml.Data.from_raw_xy_sep(x_train, y_train)!

	// Train model
	mut model := ml.LogReg.new(mut train_data, 'cv_model')
	model.train(ml.LogRegTrainConfig{})

	// Predict
	mut predictions := []f64{}
	for row in x_test {
		predictions << model.predict(row)
	}

	// Evaluate
	acc := metrics.accuracy_score(y_test, predictions)!
	scores << acc
}

// Report average score
mut avg := 0.0
for s in scores {
	avg += s
}
avg /= f64(scores.len)
println('Average CV Accuracy: ${avg}')
```

## Best Practices

1. **Use stratified splitting for classification** - Ensures representative class distribution
2. **Set random_seed for reproducibility** - Same seed = same splits
3. **K=5 or K=10 for cross-validation** - Common choices balancing bias-variance
4. **Use LeaveOneOut for small datasets** - Maximizes training data
5. **Use ShuffleSplit for large datasets** - Faster than full K-Fold

## Notes

- Stratified methods require labels to be integers (class labels)
- Cross-validation returns indices, use `get_fold_data` for actual arrays
- Train and test indices are always disjoint within each fold
- Random seed ensures reproducibility across runs

## See Also

- [Preprocessing](../preprocessing/README.md)
- [Metrics](../metrics/README.md)
- [Machine Learning](../ml/README.md)
