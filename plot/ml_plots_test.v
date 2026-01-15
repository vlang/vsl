module plot

import vsl.la

fn test_plot_confusion_matrix() {
	cm := [[50, 10], [5, 35]]
	class_names := ['Negative', 'Positive']

	plt := plot_confusion_matrix(cm, class_names)

	assert plt.traces.len == 1
	assert plt.layout.title == 'Confusion Matrix'
}

fn test_plot_roc_curve() {
	fpr := [0.0, 0.1, 0.2, 0.5, 1.0]
	tpr := [0.0, 0.4, 0.6, 0.8, 1.0]
	auc := 0.85

	plt := plot_roc_curve(fpr, tpr, auc)

	assert plt.traces.len == 2 // ROC curve + random line
	assert plt.layout.title == 'ROC Curve'
}

fn test_plot_precision_recall_curve() {
	precision := [1.0, 0.9, 0.8, 0.7, 0.5]
	recall := [0.0, 0.3, 0.5, 0.7, 1.0]
	ap := 0.78

	plt := plot_precision_recall_curve(precision, recall, ap)

	assert plt.traces.len == 1
	assert plt.layout.title == 'Precision-Recall Curve'
}

fn test_plot_correlation_matrix() {
	mut corr := la.Matrix.new[f64](3, 3)
	corr.set(0, 0, 1.0)
	corr.set(0, 1, 0.5)
	corr.set(0, 2, -0.3)
	corr.set(1, 0, 0.5)
	corr.set(1, 1, 1.0)
	corr.set(1, 2, 0.2)
	corr.set(2, 0, -0.3)
	corr.set(2, 1, 0.2)
	corr.set(2, 2, 1.0)

	feature_names := ['A', 'B', 'C']
	plt := plot_correlation_matrix(corr, feature_names)

	assert plt.traces.len == 1
	assert plt.layout.title == 'Correlation Matrix'
}

fn test_plot_feature_importance() {
	importances := [0.3, 0.1, 0.4, 0.2]
	names := ['Feature A', 'Feature B', 'Feature C', 'Feature D']

	plt := plot_feature_importance(importances, names, 3)

	assert plt.traces.len == 1
	assert plt.layout.title == 'Feature Importance'
}

fn test_plot_residuals() {
	y_pred := [1.0, 2.0, 3.0, 4.0, 5.0]
	residuals := [0.1, -0.2, 0.15, -0.1, 0.05]

	plt := plot_residuals(y_pred, residuals)

	assert plt.traces.len == 2 // residuals + zero line
	assert plt.layout.title == 'Residual Plot'
}

fn test_plot_actual_vs_predicted() {
	y_true := [1.0, 2.0, 3.0, 4.0, 5.0]
	y_pred := [1.1, 1.9, 3.1, 3.9, 5.1]

	plt := plot_actual_vs_predicted(y_true, y_pred)

	assert plt.traces.len == 2 // predictions + perfect line
	assert plt.layout.title == 'Actual vs Predicted'
}
