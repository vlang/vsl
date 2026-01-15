module metrics

import math
import vsl.errors

// mean_squared_error computes the mean squared error (MSE)
pub fn mean_squared_error(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut sum := 0.0
	for i in 0 .. y_true.len {
		diff := y_true[i] - y_pred[i]
		sum += diff * diff
	}

	return sum / f64(y_true.len)
}

// root_mean_squared_error computes the root mean squared error (RMSE)
pub fn root_mean_squared_error(y_true []f64, y_pred []f64) !f64 {
	mse := mean_squared_error(y_true, y_pred)!
	return math.sqrt(mse)
}

// mean_absolute_error computes the mean absolute error (MAE)
pub fn mean_absolute_error(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut sum := 0.0
	for i in 0 .. y_true.len {
		sum += math.abs(y_true[i] - y_pred[i])
	}

	return sum / f64(y_true.len)
}

// r2_score computes the coefficient of determination (R² score)
// R² = 1 - SS_res / SS_tot
// where SS_res = Σ(y_true - y_pred)² and SS_tot = Σ(y_true - mean(y_true))²
pub fn r2_score(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	// Compute mean of y_true
	mut sum := 0.0
	for y in y_true {
		sum += y
	}
	mean := sum / f64(y_true.len)

	// Compute SS_res and SS_tot
	mut ss_res := 0.0
	mut ss_tot := 0.0
	for i in 0 .. y_true.len {
		diff_pred := y_true[i] - y_pred[i]
		diff_mean := y_true[i] - mean
		ss_res += diff_pred * diff_pred
		ss_tot += diff_mean * diff_mean
	}

	if ss_tot == 0 {
		// All y_true values are the same
		if ss_res == 0 {
			return 1.0 // Perfect prediction
		}
		return 0.0
	}

	return 1.0 - ss_res / ss_tot
}

// mean_absolute_percentage_error computes MAPE
// MAPE = (1/n) * Σ|y_true - y_pred| / |y_true| * 100
pub fn mean_absolute_percentage_error(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut sum := 0.0
	mut valid_count := 0

	for i in 0 .. y_true.len {
		if y_true[i] != 0 {
			sum += math.abs((y_true[i] - y_pred[i]) / y_true[i])
			valid_count++
		}
	}

	if valid_count == 0 {
		return errors.error('all y_true values are zero', .einval)
	}

	return (sum / f64(valid_count)) * 100.0
}

// explained_variance_score computes the explained variance regression score
pub fn explained_variance_score(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	n := f64(y_true.len)

	// Compute residuals
	mut residuals := []f64{len: y_true.len}
	for i in 0 .. y_true.len {
		residuals[i] = y_true[i] - y_pred[i]
	}

	// Variance of residuals
	mut sum_res := 0.0
	for r in residuals {
		sum_res += r
	}
	mean_res := sum_res / n

	mut var_res := 0.0
	for r in residuals {
		diff := r - mean_res
		var_res += diff * diff
	}
	var_res /= n

	// Variance of y_true
	mut sum_y := 0.0
	for y in y_true {
		sum_y += y
	}
	mean_y := sum_y / n

	mut var_y := 0.0
	for y in y_true {
		diff := y - mean_y
		var_y += diff * diff
	}
	var_y /= n

	if var_y == 0 {
		return 1.0
	}

	return 1.0 - var_res / var_y
}

// max_error computes the maximum absolute error
pub fn max_error(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut max_err := 0.0
	for i in 0 .. y_true.len {
		err := math.abs(y_true[i] - y_pred[i])
		if err > max_err {
			max_err = err
		}
	}

	return max_err
}

// median_absolute_error computes the median absolute error
pub fn median_absolute_error(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut errors_ := []f64{len: y_true.len}
	for i in 0 .. y_true.len {
		errors_[i] = math.abs(y_true[i] - y_pred[i])
	}

	errors_.sort(a < b)

	n := errors_.len
	if n % 2 == 0 {
		return (errors_[n / 2 - 1] + errors_[n / 2]) / 2.0
	}
	return errors_[n / 2]
}

// mean_squared_log_error computes the mean squared logarithmic error
// Only valid for non-negative values
pub fn mean_squared_log_error(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len {
		return errors.error('y_true and y_pred must have the same length', .einval)
	}
	if y_true.len == 0 {
		return errors.error('empty input arrays', .einval)
	}

	mut sum := 0.0
	for i in 0 .. y_true.len {
		if y_true[i] < 0 || y_pred[i] < 0 {
			return errors.error('mean_squared_log_error requires non-negative values',
				.einval)
		}
		diff := math.log(y_true[i] + 1.0) - math.log(y_pred[i] + 1.0)
		sum += diff * diff
	}

	return sum / f64(y_true.len)
}
