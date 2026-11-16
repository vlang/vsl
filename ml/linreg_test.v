module ml

import math
import vsl.float.float64

fn test_lin_reg() {
	xy := [
		[0.99, 90.01],
		[1.02, 89.05],
		[1.15, 91.43],
		[1.29, 93.74],
		[1.46, 96.73],
		[1.36, 94.45],
		[0.87, 87.59],
		[1.23, 91.77],
		[1.55, 99.42],
		[1.40, 93.65],
		[1.19, 93.54],
		[1.15, 92.52],
		[0.98, 90.56],
		[1.01, 89.54],
		[1.11, 89.85],
		[1.20, 90.39],
		[1.26, 93.25],
		[1.32, 93.41],
		[1.43, 94.98],
		[0.95, 87.33],
	]
	mut data := Data.from_raw_xy(xy)!
	mut reg := LinReg.new(mut data, 'linear regression')

	reg.train()
	assert float64.tolerance(reg.cost(), 5.312454218805082e-01, 1e-15)
}

fn test_lin_reg_pred() {
	xy := [
		[0.99, 90.01],
		[1.02, 89.05],
		[1.15, 91.43],
		[1.29, 93.74],
		[1.46, 96.73],
		[1.36, 94.45],
		[0.87, 87.59],
		[1.23, 91.77],
		[1.55, 99.42],
		[1.40, 93.65],
		[1.19, 93.54],
		[1.15, 92.52],
		[0.98, 90.56],
		[1.01, 89.54],
		[1.11, 89.85],
		[1.20, 90.39],
		[1.26, 93.25],
		[1.32, 93.41],
		[1.43, 94.98],
		[0.95, 87.33],
	]
	mut data := Data.from_raw_xy(xy)!
	mut reg := LinReg.new(mut data, 'linear regression')

	// set regularization parameter
	reg.params.set_lambda(1e12) // very high bias => constant line

	reg.train()

	for x0 in [0.8, 1.2, 2.0] {
		pred := reg.predict([x0])
		assert float64.tolerance(pred, reg.stat.mean_y, 1e-3)
	}
}

fn test_lin_reg_weighted_fit() {
	mut data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
	mut reg := LinReg.new(mut data, 'weighted linear regression')
	reg.params.set_lambda(0.25)

	reg.train_with_sample_weights([1.0, 3.0, 0.0])!

	assert float64.tolerance(reg.params.access_thetas()[0], 0.75, 1e-12)
	assert float64.tolerance(reg.params.get_bias(), 1.1875, 1e-12)
}

fn test_lin_reg_weighted_fit_is_stable_with_large_feature_offsets() {
	mut data := Data.from_raw_xy_sep[f64]([[1e12], [1e12 + 1.0]], [0.0, 1.0])!
	mut reg := LinReg.new(mut data, 'large-offset weighted linear regression')

	reg.train_with_sample_weights([1.0, 1.0])!

	assert float64.tolerance(reg.params.access_thetas()[0], 1.0, 1e-12)
	assert math.abs(reg.predict([1e12])) < 1e-10
	assert math.abs(reg.predict([1e12 + 1.0]) - 1.0) < 1e-10
}

fn test_lin_reg_weighted_cost() {
	mut data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
	mut reg := LinReg.new(mut data, 'weighted linear regression cost')
	reg.params.set_lambda(0.25)
	reg.train_with_sample_weights([1.0, 3.0, 0.0])!

	assert float64.tolerance(reg.cost(), 0.0234375, 1e-12)
}

fn test_lin_reg_weighted_gradients() {
	mut data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
	mut reg := LinReg.new(mut data, 'weighted linear regression gradients')
	reg.params.set_lambda(0.25)
	reg.train_with_sample_weights([1.0, 3.0, 0.0])!

	gradient, bias_gradient := reg.gradients()
	assert float64.tolerance(gradient[0], 0.0, 1e-12)
	assert float64.tolerance(bias_gradient, 0.0, 1e-12)
}

fn test_lin_reg_weighted_fit_rejects_invalid_weights() {
	assert weighted_linreg_rejects([1.0])
	assert weighted_linreg_rejects([1.0, -1.0, 1.0])
	assert weighted_linreg_rejects([0.0, 0.0, 0.0])
	assert weighted_linreg_rejects([1.0, math.nan(), 1.0])
	assert weighted_linreg_rejects([1.0, math.inf(1), 1.0])
	assert weighted_linreg_rejects([math.max_f64, math.max_f64, 0.0])
}

fn weighted_linreg_rejects(weights []f64) bool {
	mut data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0]) or {
		panic(err)
	}
	mut reg := LinReg.new(mut data, 'invalid weighted linear regression')
	reg.train_with_sample_weights(weights) or { return true }
	return false
}

fn test_lin_reg_weighted_fit_rejects_nonfinite_target() {
	mut data := Data.from_raw_xy_sep[f64]([[0.0], [1.0]], [1.0, math.nan()])!
	mut reg := LinReg.new(mut data, 'nonfinite weighted linear regression')
	reg.train_with_sample_weights([1.0, 1.0]) or { return }
	assert false, 'expected a non-finite target to fail'
}

fn test_lin_reg_weighted_fit_rejects_nonfinite_feature() {
	mut feature_data := Data.from_raw_xy_sep[f64]([[0.0], [math.inf(1)]], [1.0, 2.0])!
	mut feature_reg := LinReg.new(mut feature_data, 'nonfinite weighted feature')
	feature_reg.train_with_sample_weights([1.0, 1.0]) or { return }
	assert false, 'expected a non-finite feature to fail'
}
