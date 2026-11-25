module ml

import math
import vsl.la

struct LogRegPanic {
mut:
	message string
}

fn capture_logreg_panic(f fn (), mut result LogRegPanic) {
	defer {
		if message := recover() {
			result.message = message
		}
	}
	f()
}

fn logreg_panic_message(f fn ()) string {
	mut result := LogRegPanic{}
	capture_logreg_panic(f, mut result)
	return result.message
}

fn assert_logreg_close(left f64, right f64) {
	assert math.abs(left - right) < 1e-10
}

fn test_logreg_unit_weights_match_default_objective_and_derivatives() {
	x := [[-1.0], [0.5], [2.0]]
	y := [0.0, 1.0, 1.0]
	mut default_data := Data.from_raw_xy_sep(x, y)!
	mut weighted_data := Data.from_raw_xy_sep(x, y)!
	mut default_model := LogReg.new(mut default_data, 'logreg_unit_default')
	mut weighted_model := LogReg.new(mut weighted_data, 'logreg_unit_explicit')
	default_model.params.set_thetas([0.7])
	default_model.params.set_bias(-0.2)
	default_model.params.set_lambda(0.3)
	weighted_model.params.set_thetas([0.7])
	weighted_model.params.set_bias(-0.2)
	weighted_model.params.set_lambda(0.3)
	weighted_model.train(sample_weights: [1.0, 1.0, 1.0], epochs: 0)

	assert_logreg_close(default_model.cost(), weighted_model.cost())
	default_gradient, default_bias_gradient := default_model.gradients()
	weighted_gradient, weighted_bias_gradient := weighted_model.gradients()
	assert_logreg_close(default_gradient[0], weighted_gradient[0])
	assert_logreg_close(default_bias_gradient, weighted_bias_gradient)

	mut default_d, default_v, mut default_dm, mut default_hm := default_model.allocate_hessian()
	mut weighted_d, weighted_v, mut weighted_dm, mut weighted_hm := weighted_model.allocate_hessian()
	default_w := default_model.hessian(mut default_d, mut default_v, mut default_dm,
		mut default_hm)
	weighted_w := weighted_model.hessian(mut weighted_d, mut weighted_v, mut weighted_dm,
		mut weighted_hm)
	assert_logreg_close(default_hm.get(0, 0), weighted_hm.get(0, 0))
	assert_logreg_close(default_v[0], weighted_v[0])
	assert_logreg_close(default_w, weighted_w)

	default_model.train(epochs: 20, learning_rate: 0.1)
	weighted_model.train(epochs: 20, learning_rate: 0.1, sample_weights: [1.0, 1.0, 1.0])
	assert_logreg_close(default_model.params.get_theta(0), weighted_model.params.get_theta(0))
	assert_logreg_close(default_model.params.get_bias(), weighted_model.params.get_bias())
	assert_logreg_close(default_model.cost(), weighted_model.cost())
}

fn test_logreg_weighted_loss_and_derivatives_match_positive_weight_subset() {
	x := [[-1.0], [0.5], [2.0]]
	y := [0.0, 1.0, 1.0]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut subset_data := Data.from_raw_xy_sep([[-1.0], [2.0]], [0.0, 1.0])!
	mut model := LogReg.new(mut data, 'logreg_weighted')
	mut subset_model := LogReg.new(mut subset_data, 'logreg_weighted_subset')
	model.params.set_thetas([0.4])
	model.params.set_bias(-0.1)
	model.params.set_lambda(0.2)
	subset_model.params.set_thetas([0.4])
	subset_model.params.set_bias(-0.1)
	subset_model.params.set_lambda(0.2)
	model.train(sample_weights: [2.0, 0.0, 1.0], epochs: 0)
	subset_model.train(sample_weights: [2.0, 1.0], epochs: 0)

	assert_logreg_close(model.cost(), subset_model.cost())
	gradient, bias_gradient := model.gradients()
	subset_gradient, subset_bias_gradient := subset_model.gradients()
	assert_logreg_close(gradient[0], subset_gradient[0])
	assert_logreg_close(bias_gradient, subset_bias_gradient)

	mut d, v, mut dm, mut hm := model.allocate_hessian()
	mut subset_d, subset_v, mut subset_dm, mut subset_hm := subset_model.allocate_hessian()
	w := model.hessian(mut d, mut v, mut dm, mut hm)
	subset_w := subset_model.hessian(mut subset_d, mut subset_v, mut subset_dm, mut subset_hm)
	assert_logreg_close(hm.get(0, 0), subset_hm.get(0, 0))
	assert_logreg_close(v[0], subset_v[0])
	assert_logreg_close(w, subset_w)
}

fn test_logreg_large_and_subnormal_weights_match_scaled_reference() {
	for weights in [[5e307, 5e307], [1e-320, 1e-320]] {
		mut data := Data.from_raw_xy_sep([[0.0], [0.0]], [1.0, 1.0])!
		mut reference_data := Data.from_raw_xy_sep([[0.0], [0.0]], [1.0, 1.0])!
		mut model := LogReg.new(mut data, 'logreg_extreme_weights')
		mut reference_model := LogReg.new(mut reference_data, 'logreg_scaled_weights')
		model.params.set_thetas([0.0])
		model.params.set_bias(-2.0)
		reference_model.params.set_thetas([0.0])
		reference_model.params.set_bias(-2.0)
		model.params.set_lambda(0.0)
		reference_model.params.set_lambda(0.0)
		model.train(sample_weights: weights, epochs: 0)
		reference_model.train(sample_weights: [1.0, 1.0], epochs: 0)

		cost := model.cost()
		assert !math.is_nan(cost) && !math.is_inf(cost, 0)
		assert_logreg_close(cost, reference_model.cost())
		gradient, bias_gradient := model.gradients()
		reference_gradient, reference_bias_gradient := reference_model.gradients()
		assert !math.is_nan(gradient[0]) && !math.is_inf(gradient[0], 0)
		assert !math.is_nan(bias_gradient) && !math.is_inf(bias_gradient, 0)
		assert_logreg_close(gradient[0], reference_gradient[0])
		assert_logreg_close(bias_gradient, reference_bias_gradient)

		mut d, v, mut dm, mut hm := model.allocate_hessian()
		mut reference_d, reference_v, mut reference_dm, mut reference_hm := reference_model.allocate_hessian()
		w := model.hessian(mut d, mut v, mut dm, mut hm)
		reference_w := reference_model.hessian(mut reference_d, mut reference_v,
			mut reference_dm, mut reference_hm)
		hessian_value := hm.get(0, 0)
		assert !math.is_nan(hessian_value) && !math.is_inf(hessian_value, 0)
		assert !math.is_nan(v[0]) && !math.is_inf(v[0], 0)
		assert !math.is_nan(w) && !math.is_inf(w, 0)
		assert_logreg_close(hessian_value, reference_hm.get(0, 0))
		assert_logreg_close(v[0], reference_v[0])
		assert_logreg_close(w, reference_w)
	}
}

fn test_logreg_weighted_newton_matches_repeated_samples() {
	mut weighted_data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
	mut repeated_data := Data.from_raw_xy_sep([[0.0], [0.0], [1.0]], [0.0, 0.0, 1.0])!
	mut weighted_model := LogReg.new(mut weighted_data, 'logreg_weighted_newton')
	mut repeated_model := LogReg.new(mut repeated_data, 'logreg_repeated_newton')
	weighted_model.params.set_lambda(0.1)
	repeated_model.params.set_lambda(0.1)

	weighted_model.train(epochs: 5, use_newton: true, sample_weights: [2.0, 1.0])
	repeated_model.train(epochs: 5, use_newton: true)

	assert_logreg_close(weighted_model.params.get_theta(0), repeated_model.params.get_theta(0))
	assert_logreg_close(weighted_model.params.get_bias(), repeated_model.params.get_bias())
	assert_logreg_close(weighted_model.cost(), repeated_model.cost())
}

fn test_logreg_invalid_sample_weights_panic_explicitly() {
	assert logreg_panic_message(fn () {
		mut data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
		mut model := LogReg.new(mut data, 'logreg_bad_weight_length')
		model.train(sample_weights: [1.0])
	}).contains('one value per sample')
	for invalid_weights in [[1.0, -1.0], [math.nan(), 1.0], [math.inf(1), 1.0], [math.inf(-1),
		1.0], [0.0, 0.0], [1e308, 1e308]] {
		assert logreg_panic_message(fn [invalid_weights] () {
			mut data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
			mut model := LogReg.new(mut data, 'logreg_bad_weight_value')
			model.train(sample_weights: invalid_weights)
		}).contains('sample_weights')
	}
}

fn test_logreg_unrepresentable_regularization_coefficient_panics() {
	assert logreg_panic_message(fn () {
		mut data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
		mut model := LogReg.new(mut data, 'logreg_unrepresentable_reg_cost')
		model.params.set_lambda(1.0)
		model.train(sample_weights: [1e-320, 1e-320], epochs: 0)
		_ := model.cost()
	}).contains('regularization coefficient is not representable')

	assert logreg_panic_message(fn () {
		mut data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
		mut model := LogReg.new(mut data, 'logreg_unrepresentable_reg_gradient')
		model.params.set_lambda(1.0)
		model.train(sample_weights: [1e-320, 1e-320], epochs: 0)
		gradient, bias_gradient := model.gradients()
		assert !math.is_nan(gradient[0]) && !math.is_nan(bias_gradient)
	}).contains('regularization coefficient is not representable')

	assert logreg_panic_message(fn () {
		mut data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
		mut model := LogReg.new(mut data, 'logreg_unrepresentable_reg_hessian')
		model.params.set_lambda(1.0)
		model.train(sample_weights: [1e-320, 1e-320], epochs: 0)
		mut d, v, mut dm, mut hm := model.allocate_hessian()
		_ := model.hessian(mut d, mut v, mut dm, mut hm)
	}).contains('regularization coefficient is not representable')

	assert logreg_panic_message(fn () {
		mut data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
		mut model := LogReg.new(mut data, 'logreg_underflow_reg_coefficient')
		model.params.set_lambda(1e-320)
		model.train(sample_weights: [5e307, 5e307], epochs: 0)
		_ := model.cost()
	}).contains('regularization coefficient is not representable')
}

fn test_logreg_observer_resize_clears_stale_sample_weights() {
	mut data := Data.from_raw_xy_sep([[0.0], [1.0]], [0.0, 1.0])!
	mut model := LogReg.new(mut data, 'logreg_weighted_observer')
	model.train(sample_weights: [2.0, 1.0], epochs: 0)

	new_x := la.Matrix.deep2([[0.0], [1.0], [2.0]])
	data.set(new_x, [0.0, 1.0, 1.0])!

	assert model.sample_weights.len == 0
	assert !math.is_nan(model.cost())
}
