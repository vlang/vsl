# VSL Metrics Module

The `vsl.metrics` module provides evaluation metrics for machine learning
models, including classification and regression metrics.

## Features

### Classification Metrics
- **accuracy_score**: Classification accuracy
- **precision_score**: Precision (positive predictive value)
- **recall_score**: Recall (sensitivity, true positive rate)
- **f1_score**: F1 score (harmonic mean of precision and recall)
- **confusion_matrix**: Confusion matrix for binary classification
- **roc_curve**: Receiver Operating Characteristic curve
- **roc_auc_score**: Area Under the ROC Curve
- **precision_recall_curve**: Precision-Recall curve
- **average_precision_score**: Average precision score
- **log_loss**: Logistic loss (cross-entropy)
- **gini_coefficient**: Gini coefficient
- **ks_statistic**: Kolmogorov-Smirnov statistic

### Regression Metrics
- **mean_squared_error**: Mean Squared Error (MSE)
- **root_mean_squared_error**: Root Mean Squared Error (RMSE)
- **mean_absolute_error**: Mean Absolute Error (MAE)
- **r2_score**: Coefficient of determination (R²)
- **mean_absolute_percentage_error**: MAPE
- **explained_variance_score**: Explained variance
- **max_error**: Maximum absolute error
- **median_absolute_error**: Median absolute error
- **mean_squared_log_error**: Mean squared logarithmic error

## Quick Start

### Classification Metrics

```v
import vsl.metrics

y_true := [1.0, 1.0, 0.0, 0.0, 1.0, 0.0]
y_pred := [1.0, 0.0, 0.0, 0.0, 1.0, 1.0]

// Basic metrics
acc := metrics.accuracy_score(y_true, y_pred)!
prec := metrics.precision_score(y_true, y_pred)!
rec := metrics.recall_score(y_true, y_pred)!
f1 := metrics.f1_score(y_true, y_pred)!

println('Accuracy: ${acc}')
println('Precision: ${prec}')
println('Recall: ${rec}')
println('F1 Score: ${f1}')

// Confusion matrix
cm := metrics.confusion_matrix(y_true, y_pred)!
println('Confusion Matrix: ${cm}')
// [[TN, FP], [FN, TP]]
```

### ROC Curve and AUC

```v
import vsl.metrics

y_true := [1.0, 1.0, 0.0, 0.0]
y_score := [0.9, 0.8, 0.3, 0.1] // prediction probabilities

// Compute ROC curve
roc := metrics.roc_curve(y_true, y_score)!
println('FPR: ${roc.fpr}')
println('TPR: ${roc.tpr}')

// Compute AUC
auc := metrics.roc_auc_score(y_true, y_score)!
println('AUC: ${auc}')
```

### Precision-Recall Curve

```v
import vsl.metrics

y_true := [1.0, 1.0, 0.0, 0.0]
y_score := [0.9, 0.8, 0.3, 0.1]

pr := metrics.precision_recall_curve(y_true, y_score)!
println('Precision: ${pr.precision}')
println('Recall: ${pr.recall}')

ap := metrics.average_precision_score(y_true, y_score)!
println('Average Precision: ${ap}')
```

### Gini and KS Statistics

```v
import vsl.metrics

y_true := [1.0, 1.0, 0.0, 0.0]
y_score := [0.9, 0.8, 0.2, 0.1]

gini := metrics.gini_coefficient(y_true, y_score)!
println('Gini: ${gini}')

ks := metrics.ks_statistic(y_true, y_score)!
println('KS Statistic: ${ks}')
```

### Regression Metrics

```v
import vsl.metrics

y_true := [3.0, -0.5, 2.0, 7.0]
y_pred := [2.5, 0.0, 2.0, 8.0]

mse := metrics.mean_squared_error(y_true, y_pred)!
rmse := metrics.root_mean_squared_error(y_true, y_pred)!
mae := metrics.mean_absolute_error(y_true, y_pred)!
r2 := metrics.r2_score(y_true, y_pred)!

println('MSE: ${mse}')
println('RMSE: ${rmse}')
println('MAE: ${mae}')
println('R²: ${r2}')
```

## API Reference

### Classification Functions

| Function | Description |
|----------|-------------|
| `confusion_matrix(y_true, y_pred)` | Returns [[TN, FP], [FN, TP]] |
| `accuracy_score(y_true, y_pred)` | (TP + TN) / total |
| `precision_score(y_true, y_pred)` | TP / (TP + FP) |
| `recall_score(y_true, y_pred)` | TP / (TP + FN) |
| `f1_score(y_true, y_pred)` | 2 * P * R / (P + R) |
| `roc_curve(y_true, y_score)` | Returns FPR, TPR, thresholds |
| `roc_auc_score(y_true, y_score)` | Area under ROC curve |
| `precision_recall_curve(y_true, y_score)` | Returns precision, recall, thresholds |
| `average_precision_score(y_true, y_score)` | AP from predictions |
| `log_loss(y_true, y_pred)` | Cross-entropy loss |
| `gini_coefficient(y_true, y_score)` | 2 * AUC - 1 |
| `ks_statistic(y_true, y_score)` | Max difference between CDFs |
| `auc(x, y)` | Area under curve (trapezoidal) |

### Regression Functions

| Function | Description |
|----------|-------------|
| `mean_squared_error(y_true, y_pred)` | Σ(y - ŷ)² / n |
| `root_mean_squared_error(y_true, y_pred)` | √MSE |
| `mean_absolute_error(y_true, y_pred)` | Σ\|y - ŷ\| / n |
| `r2_score(y_true, y_pred)` | 1 - SS_res / SS_tot |
| `mean_absolute_percentage_error(y_true, y_pred)` | MAPE in % |
| `explained_variance_score(y_true, y_pred)` | 1 - Var(residuals) / Var(y) |
| `max_error(y_true, y_pred)` | max(\|y - ŷ\|) |
| `median_absolute_error(y_true, y_pred)` | median(\|y - ŷ\|) |
| `mean_squared_log_error(y_true, y_pred)` | MSLE (for non-negative) |

## Integration with ML Models

```v ignore
import vsl.metrics
import vsl.ml

// Train a model
mut model := ml.LogReg.new(mut data, 'my_model')
model.train(ml.LogRegTrainConfig{})

// Make predictions
mut predictions := []f64{}
for i in 0 .. test_data.nb_samples {
	x := test_data.x.get_row(i)
	predictions << model.predict(x)
}

// Evaluate
accuracy := metrics.accuracy_score(test_data.y, predictions)!
auc := metrics.roc_auc_score(test_data.y, predictions)!

println('Test Accuracy: ${accuracy}')
println('Test AUC: ${auc}')
```

## Visualization with Metrics

```v ignore
import vsl.metrics
import vsl.plot

// Compute ROC curve
roc := metrics.roc_curve(y_true, y_score)!
auc_val := metrics.roc_auc_score(y_true, y_score)!

// Plot ROC curve
mut plt := plot.Plot.new()
plt.scatter(
	x:    roc.fpr
	y:    roc.tpr
	mode: 'lines'
	name: 'ROC (AUC = ${auc_val:.3f})'
)
plt.scatter(
	x:    [0.0, 1.0]
	y:    [0.0, 1.0]
	mode: 'lines'
	name: 'Random'
)
plt.layout(
	title: 'ROC Curve'
	xaxis: plot.Axis{
		title: plot.AxisTitle{
			text: 'False Positive Rate'
		}
	}
	yaxis: plot.Axis{
		title: plot.AxisTitle{
			text: 'True Positive Rate'
		}
	}
)
plt.show()!
```

## Notes

- For binary classification, labels should be 0.0 or 1.0 (or values that threshold at 0.5)
- `y_score` parameters expect probability scores, not class labels
- R² can be negative for predictions worse than the mean
- MAPE and MSLE have specific requirements for input values

## See Also

- [Preprocessing](../preprocessing/README.md)
- [Machine Learning](../ml/README.md)
- [Visualization](../plot/README.md)
