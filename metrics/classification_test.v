module metrics

import math

fn test_confusion_matrix_basic() {
	y_true := [1.0, 1.0, 0.0, 0.0, 1.0, 0.0]
	y_pred := [1.0, 0.0, 0.0, 0.0, 1.0, 1.0]

	cm := confusion_matrix(y_true, y_pred)!

	// TN=2, FP=1, FN=1, TP=2
	assert cm[0][0] == 2 // TN
	assert cm[0][1] == 1 // FP
	assert cm[1][0] == 1 // FN
	assert cm[1][1] == 2 // TP
}

fn test_accuracy_score() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_pred := [1.0, 0.0, 0.0, 0.0]

	acc := accuracy_score(y_true, y_pred)!

	// 3 out of 4 correct
	assert math.abs(acc - 0.75) < 1e-10
}

fn test_precision_score() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_pred := [1.0, 1.0, 1.0, 0.0]

	prec := precision_score(y_true, y_pred)!

	// TP=2, FP=1, precision = 2/3
	assert math.abs(prec - 2.0 / 3.0) < 1e-10
}

fn test_recall_score() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_pred := [1.0, 0.0, 0.0, 0.0]

	rec := recall_score(y_true, y_pred)!

	// TP=1, FN=1, recall = 1/2
	assert math.abs(rec - 0.5) < 1e-10
}

fn test_f1_score() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_pred := [1.0, 1.0, 1.0, 0.0]

	f1 := f1_score(y_true, y_pred)!

	// precision = 2/3, recall = 1.0
	// f1 = 2 * (2/3 * 1) / (2/3 + 1) = 2 * 2/3 / 5/3 = 4/5 = 0.8
	assert math.abs(f1 - 0.8) < 1e-10
}

fn test_roc_curve() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_score := [0.9, 0.8, 0.3, 0.1]

	roc := roc_curve(y_true, y_score)!

	assert roc.fpr.len > 0
	assert roc.tpr.len > 0
	assert roc.fpr.len == roc.tpr.len

	// First point should be (0, 0) and last should be (1, 1)
	assert roc.fpr[0] == 0.0
	assert roc.tpr[0] == 0.0
}

fn test_roc_auc_score_perfect() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_score := [0.9, 0.8, 0.2, 0.1]

	auc_val := roc_auc_score(y_true, y_score)!

	// Perfect separation should give AUC = 1.0
	assert math.abs(auc_val - 1.0) < 1e-10
}

fn test_roc_auc_score_random() {
	y_true := [1.0, 0.0, 1.0, 0.0]
	y_score := [0.5, 0.5, 0.5, 0.5]

	auc_val := roc_auc_score(y_true, y_score)!

	// Random predictions should give AUC around 0.5
	assert auc_val >= 0.0 && auc_val <= 1.0
}

fn test_precision_recall_curve() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_score := [0.9, 0.8, 0.3, 0.1]

	pr := precision_recall_curve(y_true, y_score)!

	assert pr.precision.len > 0
	assert pr.recall.len > 0
	assert pr.precision.len == pr.recall.len
}

fn test_log_loss() {
	y_true := [1.0, 0.0]
	y_pred := [0.9, 0.1]

	ll := log_loss(y_true, y_pred)!

	// Should be small for good predictions
	assert ll < 0.5
}

fn test_log_loss_perfect() {
	y_true := [1.0, 0.0]
	y_pred := [0.999999, 0.000001]

	ll := log_loss(y_true, y_pred)!

	// Should be very small
	assert ll < 0.001
}

fn test_gini_coefficient() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_score := [0.9, 0.8, 0.2, 0.1]

	gini := gini_coefficient(y_true, y_score)!

	// Perfect predictions: Gini = 2*1 - 1 = 1
	assert math.abs(gini - 1.0) < 1e-10
}

fn test_ks_statistic() {
	y_true := [1.0, 1.0, 0.0, 0.0]
	y_score := [0.9, 0.8, 0.2, 0.1]

	ks := ks_statistic(y_true, y_score)!

	// Perfect separation should give high KS
	assert ks > 0.5
}

fn test_auc_basic() {
	x := [0.0, 0.5, 1.0]
	y := [0.0, 0.5, 1.0]

	area := auc(x, y)!

	// Triangle: 0.5
	assert math.abs(area - 0.5) < 1e-10
}

fn test_auc_rectangle() {
	x := [0.0, 1.0]
	y := [1.0, 1.0]

	area := auc(x, y)!

	// Rectangle: 1.0
	assert math.abs(area - 1.0) < 1e-10
}

fn test_metrics_length_mismatch() {
	y_true := [1.0, 0.0]
	y_pred := [1.0]

	if _ := accuracy_score(y_true, y_pred) {
		assert false, 'should have returned error'
	}
}
