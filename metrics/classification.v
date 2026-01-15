module metrics

import math
import vsl.errors

// confusion_matrix computes the confusion matrix for binary classification.
// Returns a 2x2 matrix: [[TN, FP], [FN, TP]]
pub fn confusion_matrix(y_true []f64, y_pred []f64) ![][]int {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut tn := 0
	mut fp := 0
	mut fn_ := 0
	mut tp := 0

	for i in 0 .. y_true.len {
		actual := y_true[i] >= 0.5
		predicted := y_pred[i] >= 0.5

		if actual && predicted {
			tp++
		} else if actual && !predicted {
			fn_++
		} else if !actual && predicted {
			fp++
		} else {
			tn++
		}
	}

	return [[tn, fp], [fn_, tp]]
}

// accuracy_score computes the accuracy classification score
pub fn accuracy_score(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut correct := 0
	for i in 0 .. y_true.len {
		actual := y_true[i] >= 0.5
		predicted := y_pred[i] >= 0.5
		if actual == predicted {
			correct++
		}
	}

	return f64(correct) / f64(y_true.len)
}

// precision_score computes the precision: tp / (tp + fp)
pub fn precision_score(y_true []f64, y_pred []f64) !f64 {
	cm := confusion_matrix(y_true, y_pred)!
	tp := cm[1][1]
	fp := cm[0][1]

	if tp + fp == 0 {
		return 0.0
	}
	return f64(tp) / f64(tp + fp)
}

// recall_score computes the recall: tp / (tp + fn)
pub fn recall_score(y_true []f64, y_pred []f64) !f64 {
	cm := confusion_matrix(y_true, y_pred)!
	tp := cm[1][1]
	fn_ := cm[1][0]

	if tp + fn_ == 0 {
		return 0.0
	}
	return f64(tp) / f64(tp + fn_)
}

// f1_score computes the F1 score: 2 * (precision * recall) / (precision + recall)
pub fn f1_score(y_true []f64, y_pred []f64) !f64 {
	prec := precision_score(y_true, y_pred)!
	rec := recall_score(y_true, y_pred)!

	if prec + rec == 0 {
		return 0.0
	}
	return 2.0 * prec * rec / (prec + rec)
}

// RocCurveResult holds the result of ROC curve computation
pub struct RocCurveResult {
pub:
	fpr        []f64 // false positive rates
	tpr        []f64 // true positive rates
	thresholds []f64 // thresholds used
}

// roc_curve computes Receiver Operating Characteristic (ROC) curve
pub fn roc_curve(y_true []f64, y_score []f64) !RocCurveResult {
	if y_true.len != y_score.len {
		return errors.error('y_true and y_score must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	// Get sorted unique thresholds
	mut thresholds := y_score.clone()
	thresholds.sort(a > b) // descending order

	// Add boundary values
	mut unique_thresholds := [thresholds[0] + 1.0] // Start with a threshold above max
	for t in thresholds {
		if unique_thresholds.len == 0 || t != unique_thresholds[unique_thresholds.len - 1] {
			unique_thresholds << t
		}
	}

	// Count positives and negatives
	mut n_pos := 0
	mut n_neg := 0
	for y in y_true {
		if y >= 0.5 {
			n_pos++
		} else {
			n_neg++
		}
	}

	if n_pos == 0 || n_neg == 0 {
		return errors.error('y_true must contain both positive and negative samples',
			.einval)
	}

	mut fpr := []f64{}
	mut tpr := []f64{}
	mut thresh := []f64{}

	for threshold in unique_thresholds {
		mut tp := 0
		mut fp := 0

		for i in 0 .. y_true.len {
			predicted := y_score[i] >= threshold
			actual := y_true[i] >= 0.5

			if predicted {
				if actual {
					tp++
				} else {
					fp++
				}
			}
		}

		fpr << f64(fp) / f64(n_neg)
		tpr << f64(tp) / f64(n_pos)
		thresh << threshold
	}

	return RocCurveResult{
		fpr:        fpr
		tpr:        tpr
		thresholds: thresh
	}
}

// roc_auc_score computes Area Under the ROC Curve using the trapezoidal rule
pub fn roc_auc_score(y_true []f64, y_score []f64) !f64 {
	roc := roc_curve(y_true, y_score)!
	return auc(roc.fpr, roc.tpr)
}

// auc computes Area Under the Curve using the trapezoidal rule
pub fn auc(x []f64, y []f64) !f64 {
	if x.len != y.len {
		return errors.error('x and y must have the same length', .einval)
	}
	if x.len < 2 {
		return errors.error('need at least 2 points to compute AUC', .einval)
	}

	// Sort by x values
	mut indices := []int{len: x.len, init: index}
	indices.sort_with_compare(fn [x] (a &int, b &int) int {
		if x[*a] < x[*b] {
			return -1
		} else if x[*a] > x[*b] {
			return 1
		}
		return 0
	})

	mut area := 0.0
	for i in 1 .. indices.len {
		idx1 := indices[i - 1]
		idx2 := indices[i]
		dx := x[idx2] - x[idx1]
		dy := (y[idx1] + y[idx2]) / 2.0
		area += dx * dy
	}

	return math.abs(area)
}

// PrecisionRecallResult holds the result of precision-recall curve computation
pub struct PrecisionRecallResult {
pub:
	precision  []f64 // precision values
	recall     []f64 // recall values
	thresholds []f64 // thresholds used
}

// precision_recall_curve computes precision-recall pairs for different thresholds
pub fn precision_recall_curve(y_true []f64, y_score []f64) !PrecisionRecallResult {
	if y_true.len != y_score.len {
		return errors.error('y_true and y_score must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	// Get sorted unique thresholds
	mut thresholds := y_score.clone()
	thresholds.sort(a > b) // descending order

	mut unique_thresholds := []f64{}
	for t in thresholds {
		if unique_thresholds.len == 0 || t != unique_thresholds[unique_thresholds.len - 1] {
			unique_thresholds << t
		}
	}

	// Count total positives
	mut n_pos := 0
	for y in y_true {
		if y >= 0.5 {
			n_pos++
		}
	}

	mut precision := []f64{}
	mut recall := []f64{}
	mut thresh := []f64{}

	for threshold in unique_thresholds {
		mut tp := 0
		mut fp := 0

		for i in 0 .. y_true.len {
			predicted := y_score[i] >= threshold
			actual := y_true[i] >= 0.5

			if predicted {
				if actual {
					tp++
				} else {
					fp++
				}
			}
		}

		prec := if tp + fp > 0 { f64(tp) / f64(tp + fp) } else { 1.0 }
		rec := if n_pos > 0 { f64(tp) / f64(n_pos) } else { 0.0 }

		precision << prec
		recall << rec
		thresh << threshold
	}

	return PrecisionRecallResult{
		precision:  precision
		recall:     recall
		thresholds: thresh
	}
}

// average_precision_score computes average precision from prediction scores
pub fn average_precision_score(y_true []f64, y_score []f64) !f64 {
	pr := precision_recall_curve(y_true, y_score)!

	if pr.recall.len < 2 {
		return 0.0
	}

	// Compute AP as sum of (R_n - R_{n-1}) * P_n
	mut ap := 0.0
	for i in 1 .. pr.recall.len {
		delta_recall := math.abs(pr.recall[i - 1] - pr.recall[i])
		ap += delta_recall * pr.precision[i]
	}

	return ap
}

// log_loss computes the logistic loss (cross-entropy loss)
pub fn log_loss(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	eps := 1e-15
	mut total := 0.0

	for i in 0 .. y_true.len {
		p := math.max(eps, math.min(1.0 - eps, y_pred[i]))
		y := y_true[i]
		total += -(y * math.log(p) + (1.0 - y) * math.log(1.0 - p))
	}

	return total / f64(y_true.len)
}

// gini_coefficient computes the Gini coefficient from predictions
pub fn gini_coefficient(y_true []f64, y_score []f64) !f64 {
	auc_val := roc_auc_score(y_true, y_score)!
	return 2.0 * auc_val - 1.0
}

// ks_statistic computes the Kolmogorov-Smirnov statistic
pub fn ks_statistic(y_true []f64, y_score []f64) !f64 {
	if y_true.len != y_score.len {
		return errors.error('y_true and y_score must have the same length', .einval)
	}

	// Separate scores by class
	mut pos_scores := []f64{}
	mut neg_scores := []f64{}

	for i in 0 .. y_true.len {
		if y_true[i] >= 0.5 {
			pos_scores << y_score[i]
		} else {
			neg_scores << y_score[i]
		}
	}

	if pos_scores.len == 0 || neg_scores.len == 0 {
		return errors.error('need both positive and negative samples', .einval)
	}

	// Sort scores
	pos_scores.sort(a < b)
	neg_scores.sort(a < b)

	// Compute KS statistic
	mut all_scores := y_score.clone()
	all_scores.sort(a < b)

	mut max_ks := 0.0
	for threshold in all_scores {
		// CDF for positive class
		mut pos_cdf := 0.0
		for s in pos_scores {
			if s <= threshold {
				pos_cdf += 1.0
			}
		}
		pos_cdf /= f64(pos_scores.len)

		// CDF for negative class
		mut neg_cdf := 0.0
		for s in neg_scores {
			if s <= threshold {
				neg_cdf += 1.0
			}
		}
		neg_cdf /= f64(neg_scores.len)

		ks := math.abs(pos_cdf - neg_cdf)
		if ks > max_ks {
			max_ks = ks
		}
	}

	return max_ks
}
