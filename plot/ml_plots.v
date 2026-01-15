module plot

import vsl.la

// SortPair is a helper struct for sorting
struct SortPair {
	idx   int
	value f64
}

// plot_confusion_matrix creates a heatmap visualization of a confusion matrix
pub fn plot_confusion_matrix(cm [][]int, class_names []string) &Plot {
	// Convert int matrix to f64
	mut z := [][]f64{}
	for row in cm {
		mut frow := []f64{}
		for val in row {
			frow << f64(val)
		}
		z << frow
	}

	mut x_labels := class_names.clone()
	if x_labels.len == 0 {
		for i in 0 .. cm[0].len {
			x_labels << '${i}'
		}
	}
	mut y_labels := class_names.clone()
	if y_labels.len == 0 {
		for i in 0 .. cm.len {
			y_labels << '${i}'
		}
	}

	// Create text array for cell values
	mut text_vals := [][]string{}
	for row in cm {
		mut text_row := []string{}
		for val in row {
			text_row << '${val}'
		}
		text_vals << text_row
	}

	mut plt := Plot.new()
	plt.heatmap(HeatmapTrace{
		z:          z
		x:          x_labels
		y:          y_labels
		colorscale: 'Blues'
	})
	plt.layout(Layout{
		title: 'Confusion Matrix'
		xaxis: Axis{
			title: AxisTitle{
				text: 'Predicted'
			}
		}
		yaxis: Axis{
			title: AxisTitle{
				text: 'Actual'
			}
		}
	})

	return plt
}

// plot_roc_curve creates a ROC curve plot
pub fn plot_roc_curve(fpr []f64, tpr []f64, auc_score f64) &Plot {
	mut plt := Plot.new()

	// ROC curve
	plt.scatter(ScatterTrace{
		x:    fpr
		y:    tpr
		mode: 'lines'
		name: 'ROC (AUC = ${auc_score:.3f})'
		line: Line{
			color: '#1f77b4'
			width: 2.0
		}
	})

	// Random classifier line
	plt.scatter(ScatterTrace{
		x:    [0.0, 1.0]
		y:    [0.0, 1.0]
		mode: 'lines'
		name: 'Random'
		line: Line{
			color: '#d62728'
			width: 1.0
			dash:  'dash'
		}
	})

	plt.layout(Layout{
		title:  'ROC Curve'
		xaxis:  Axis{
			title: AxisTitle{
				text: 'False Positive Rate'
			}
			range: [0.0, 1.0]
		}
		yaxis:  Axis{
			title: AxisTitle{
				text: 'True Positive Rate'
			}
			range: [0.0, 1.05]
		}
		width:  700
		height: 500
	})

	return plt
}

// plot_precision_recall_curve creates a precision-recall curve plot
pub fn plot_precision_recall_curve(precision []f64, recall []f64, ap_score f64) &Plot {
	mut plt := Plot.new()

	plt.scatter(ScatterTrace{
		x:    recall
		y:    precision
		mode: 'lines'
		name: 'PR (AP = ${ap_score:.3f})'
		line: Line{
			color: '#2ca02c'
			width: 2.0
		}
	})

	plt.layout(Layout{
		title:  'Precision-Recall Curve'
		xaxis:  Axis{
			title: AxisTitle{
				text: 'Recall'
			}
			range: [0.0, 1.0]
		}
		yaxis:  Axis{
			title: AxisTitle{
				text: 'Precision'
			}
			range: [0.0, 1.05]
		}
		width:  700
		height: 500
	})

	return plt
}

// plot_correlation_matrix creates a heatmap of a correlation matrix
pub fn plot_correlation_matrix(corr &la.Matrix[f64], feature_names []string) &Plot {
	// Convert matrix to 2D array
	mut z := [][]f64{}
	for i in 0 .. corr.m {
		z << corr.get_row(i)
	}

	mut labels := feature_names.clone()
	if labels.len == 0 {
		for i in 0 .. corr.n {
			labels << 'Feature ${i}'
		}
	}

	mut plt := Plot.new()
	plt.heatmap(HeatmapTrace{
		z:          z
		x:          labels
		y:          labels
		colorscale: 'RdBu'
	})
	plt.layout(Layout{
		title:  'Correlation Matrix'
		width:  700
		height: 600
	})

	return plt
}

// plot_feature_importance creates a horizontal bar chart of feature importances
pub fn plot_feature_importance(importances []f64, feature_names []string, top_n int) &Plot {
	// Create sorted list manually
	mut sorted_pairs := []SortPair{}
	for i, imp in importances {
		sorted_pairs << SortPair{
			idx:   i
			value: imp
		}
	}
	sorted_pairs.sort(a.value > b.value)

	// Take top N
	n := if top_n > 0 && top_n < sorted_pairs.len { top_n } else { sorted_pairs.len }
	mut sorted_names := []string{}
	mut sorted_values := []f64{}

	for i in 0 .. n {
		pair := sorted_pairs[i]
		name := if feature_names.len > pair.idx {
			feature_names[pair.idx]
		} else {
			'Feature ${pair.idx}'
		}
		sorted_names << name
		sorted_values << pair.value
	}

	// Reverse for horizontal bar (top feature at top)
	sorted_names.reverse_in_place()
	sorted_values.reverse_in_place()

	mut plt := Plot.new()
	plt.bar(BarTrace{
		x:      sorted_values
		y:      sorted_names
		name:   'Importance'
		marker: Marker{
			color: ['#1f77b4']
		}
	})
	plt.layout(Layout{
		title:  'Feature Importance'
		xaxis:  Axis{
			title: AxisTitle{
				text: 'Importance'
			}
		}
		yaxis:  Axis{
			title: AxisTitle{
				text: 'Feature'
			}
		}
		width:  700
		height: int(100 + n * 25)
	})

	return plt
}

// plot_learning_curve creates a plot of training and validation scores vs training size
pub fn plot_learning_curve(train_sizes []f64, train_scores []f64, val_scores []f64) &Plot {
	mut plt := Plot.new()

	plt.scatter(ScatterTrace{
		x:    train_sizes
		y:    train_scores
		mode: 'lines+markers'
		name: 'Training Score'
		line: Line{
			color: '#1f77b4'
		}
	})

	plt.scatter(ScatterTrace{
		x:    train_sizes
		y:    val_scores
		mode: 'lines+markers'
		name: 'Validation Score'
		line: Line{
			color: '#ff7f0e'
		}
	})

	plt.layout(Layout{
		title:  'Learning Curve'
		xaxis:  Axis{
			title: AxisTitle{
				text: 'Training Size'
			}
		}
		yaxis:  Axis{
			title: AxisTitle{
				text: 'Score'
			}
		}
		width:  700
		height: 500
	})

	return plt
}

// plot_residuals creates a residual plot for regression
pub fn plot_residuals(y_pred []f64, residuals []f64) &Plot {
	mut plt := Plot.new()

	plt.scatter(ScatterTrace{
		x:      y_pred
		y:      residuals
		mode:   'markers'
		name:   'Residuals'
		marker: Marker{
			color:   ['#1f77b4']
			opacity: 0.6
		}
	})

	// Add horizontal line at y=0
	min_pred := array_min(y_pred)
	max_pred := array_max(y_pred)
	plt.scatter(ScatterTrace{
		x:    [min_pred, max_pred]
		y:    [0.0, 0.0]
		mode: 'lines'
		name: 'Zero'
		line: Line{
			color: '#d62728'
			dash:  'dash'
		}
	})

	plt.layout(Layout{
		title:  'Residual Plot'
		xaxis:  Axis{
			title: AxisTitle{
				text: 'Predicted Values'
			}
		}
		yaxis:  Axis{
			title: AxisTitle{
				text: 'Residuals'
			}
		}
		width:  700
		height: 500
	})

	return plt
}

// plot_actual_vs_predicted creates a scatter plot of actual vs predicted values
pub fn plot_actual_vs_predicted(y_true []f64, y_pred []f64) &Plot {
	mut plt := Plot.new()

	plt.scatter(ScatterTrace{
		x:      y_true
		y:      y_pred
		mode:   'markers'
		name:   'Predictions'
		marker: Marker{
			color:   ['#1f77b4']
			opacity: 0.6
		}
	})

	// Add perfect prediction line
	min_val := array_min(y_true)
	max_val := array_max(y_true)
	plt.scatter(ScatterTrace{
		x:    [min_val, max_val]
		y:    [min_val, max_val]
		mode: 'lines'
		name: 'Perfect Prediction'
		line: Line{
			color: '#d62728'
			dash:  'dash'
		}
	})

	plt.layout(Layout{
		title:  'Actual vs Predicted'
		xaxis:  Axis{
			title: AxisTitle{
				text: 'Actual Values'
			}
		}
		yaxis:  Axis{
			title: AxisTitle{
				text: 'Predicted Values'
			}
		}
		width:  700
		height: 500
	})

	return plt
}

// Helper functions
fn array_min(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	mut min := arr[0]
	for v in arr {
		if v < min {
			min = v
		}
	}
	return min
}

fn array_max(arr []f64) f64 {
	if arr.len == 0 {
		return 0.0
	}
	mut max := arr[0]
	for v in arr {
		if v > max {
			max = v
		}
	}
	return max
}
