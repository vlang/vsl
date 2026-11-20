module ml

import math
import vsl.la
import vsl.plot
import vsl.util
import vsl.errors

// RegularizationType specifies the type of regularization
pub enum RegularizationType {
	none       // No regularization
	l1         // Lasso (L1)
	l2         // Ridge (L2)
	elasticnet // ElasticNet (L1 + L2)
}

// Lasso implements a linear regression model with L1 regularization
// Uses coordinate descent algorithm for optimization

// Lasso defines a public data structure for this module.

// Lasso defines a public data structure for this module.
@[heap]
pub struct Lasso {
mut:
	name   string // name of this model
	data   &Data[f64] = unsafe { nil } // x-y data
	fitted bool
pub mut:
	coef_      []f64 // learned coefficients (theta)
	intercept_ f64   // learned intercept (bias)
	alpha      f64        = 1.0          // regularization strength
	max_iter   int        = 1000         // maximum iterations
	tol        f64        = 1e-4         // convergence tolerance
	stat       &Stat[f64] = unsafe { nil } // statistics
}

// Lasso.new creates a new Lasso regression model
pub fn Lasso.new(mut data Data[f64], name string, alpha f64) &Lasso {
	if alpha < 0 {
		errors.vsl_panic('alpha must be non-negative', .einval)
	}

	mut stat := Stat.from_data(mut data, 'stat_' + name)
	stat.update()

	return &Lasso{
		name:  name
		data:  data
		alpha: alpha
		stat:  stat
		coef_: []f64{len: data.nb_features}
	}
}

// name returns the model name
pub fn (o &Lasso) name() string {
	return o.name
}

// predict returns the prediction for a feature vector
pub fn (o &Lasso) predict(x []f64) f64 {
	if x.len != o.coef_.len {
		errors.vsl_panic('input dimension mismatch', .einval)
	}
	return o.intercept_ + la.vector_dot(x, o.coef_)
}

// train fits the Lasso model using coordinate descent
pub fn (mut o Lasso) train() {
	o.train_with_sample_weights([]f64{}) or { panic(err) }
}

// train_with_sample_weights fits the Lasso model using one finite,
// non-negative weight per sample. An empty slice assigns unit weight to each
// sample. Weights scale the data terms, and the L1 threshold scales with their
// sum so integer weights match fitting duplicated observations.
pub fn (mut o Lasso) train_with_sample_weights(sample_weights []f64) ! {
	m := o.data.nb_samples
	n := o.data.nb_features
	x := o.data.x
	y := o.data.y
	if m <= 0 || x.m != m || x.n != n || y.len != m {
		return errors.error('training data dimensions do not match', .einval)
	}
	if sample_weights.len != 0 && sample_weights.len != m {
		return errors.error('sample_weights must be empty or match the number of samples',
			.einval)
	}
	if math.is_nan(o.alpha) || math.is_inf(o.alpha, 0) || o.alpha < 0.0 {
		return errors.error('alpha must be finite and non-negative', .einval)
	}

	mut weight_sum := 0.0
	mut y_sum := 0.0
	mut x_sums := []f64{len: n}
	for i in 0 .. m {
		weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[i] }
		if math.is_nan(weight) || math.is_inf(weight, 0) || weight < 0.0 {
			return errors.error('sample weights must be finite and non-negative', .einval)
		}
		weight_sum += weight
		if math.is_inf(weight_sum, 0) {
			return errors.error('sum of sample weights overflowed', .einval)
		}
		if weight == 0.0 {
			continue
		}
		if math.is_nan(y[i]) || math.is_inf(y[i], 0) {
			return errors.error('training targets must be finite', .einval)
		}
		y_sum += weight * y[i]
		if math.is_nan(y_sum) || math.is_inf(y_sum, 0) {
			return errors.error('weighted target sum overflowed', .einval)
		}
		for j in 0 .. n {
			value := x.get(i, j)
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('training features must be finite', .einval)
			}
			x_sums[j] += weight * value
			if math.is_nan(x_sums[j]) || math.is_inf(x_sums[j], 0) {
				return errors.error('weighted feature sum overflowed', .einval)
			}
		}
	}
	if weight_sum <= 0.0 {
		return errors.error('sample weights must have a positive sum', .einval)
	}

	y_mean := y_sum / weight_sum
	mut x_means := []f64{len: n}
	for j in 0 .. n {
		x_means[j] = x_sums[j] / weight_sum
		if math.is_nan(x_means[j]) || math.is_inf(x_means[j], 0) {
			return errors.error('weighted feature mean overflowed', .einval)
		}
	}
	if math.is_nan(y_mean) || math.is_inf(y_mean, 0) {
		return errors.error('weighted target mean overflowed', .einval)
	}
	mut x_norms := []f64{len: n}
	for j in 0 .. n {
		for i in 0 .. m {
			weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[i] }
			if weight == 0.0 {
				continue
			}
			centered := x.get(i, j) - x_means[j]
			x_norms[j] += weight * centered * centered
		}
		if math.is_nan(x_norms[j]) || math.is_inf(x_norms[j], 0) {
			return errors.error('weighted feature norm overflowed', .einval)
		}
	}

	mut coefficients := []f64{len: n}
	mut residual := y.clone()
	for i in 0 .. m {
		weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[i] }
		if weight == 0.0 {
			residual[i] = 0.0
			continue
		}
		residual[i] -= y_mean
		if math.is_nan(residual[i]) || math.is_inf(residual[i], 0) {
			return errors.error('centered targets overflowed', .einval)
		}
	}

	threshold := o.alpha * weight_sum / 2.0
	if math.is_nan(threshold) || math.is_inf(threshold, 0) {
		return errors.error('L1 threshold overflowed', .einval)
	}
	for iter := 0; iter < o.max_iter; iter++ {
		mut max_change := 0.0
		for j in 0 .. n {
			old_coef := coefficients[j]
			if old_coef != 0.0 {
				for i in 0 .. m {
					weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[i] }
					if weight == 0.0 {
						continue
					}
					centered := x.get(i, j) - x_means[j]
					residual[i] += centered * old_coef
					if math.is_nan(residual[i]) || math.is_inf(residual[i], 0) {
						return errors.error('coordinate residual overflowed', .einval)
					}
				}
			}

			mut rho := 0.0
			for i in 0 .. m {
				weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[i] }
				if weight == 0.0 {
					continue
				}
				centered := x.get(i, j) - x_means[j]
				rho += weight * centered * residual[i]
			}
			if math.is_nan(rho) || math.is_inf(rho, 0) {
				return errors.error('weighted feature-target product overflowed', .einval)
			}

			mut new_coef := 0.0
			if x_norms[j] > 0.0 {
				new_coef = soft_threshold(rho, threshold) / x_norms[j]
			}
			if math.is_nan(new_coef) || math.is_inf(new_coef, 0) {
				return errors.error('coefficient update overflowed', .einval)
			}
			coefficients[j] = new_coef
			if new_coef != 0.0 {
				for i in 0 .. m {
					weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[i] }
					if weight == 0.0 {
						continue
					}
					centered := x.get(i, j) - x_means[j]
					residual[i] -= centered * new_coef
					if math.is_nan(residual[i]) || math.is_inf(residual[i], 0) {
						return errors.error('coordinate residual overflowed', .einval)
					}
				}
			}
			change := math.abs(new_coef - old_coef)
			if change > max_change {
				max_change = change
			}
		}
		if max_change < o.tol {
			break
		}
	}

	mut intercept := y_mean
	for j in 0 .. n {
		intercept -= coefficients[j] * x_means[j]
	}
	if math.is_nan(intercept) || math.is_inf(intercept, 0) {
		return errors.error('intercept update overflowed', .einval)
	}
	o.coef_ = coefficients
	o.intercept_ = intercept
	o.fitted = true
}

// soft_threshold applies soft thresholding for L1 regularization
fn soft_threshold(x f64, lambda f64) f64 {
	if x > lambda {
		return x - lambda
	} else if x < -lambda {
		return x + lambda
	}
	return 0.0
}

// get_plotter returns a plot for the model
pub fn (o &Lasso) get_plotter() &plot.Plot {
	min_x := o.stat.min_x[0]
	max_x := o.stat.max_x[0]
	x_values := util.lin_space(min_x, max_x, 100)
	y_values := x_values.map(o.predict([it]))

	mut plt := plot.Plot.new()
	plt.layout(title: 'Lasso Regression')
	plt.scatter(name: 'dataset', x: o.data.x.get_col(0), y: o.data.y, mode: 'markers')
	plt.scatter(name: 'prediction', x: x_values, y: y_values, mode: 'lines')

	return plt
}

// ElasticNet implements linear regression with combined L1 and L2 regularization

// ElasticNet defines a public data structure for this module.

// ElasticNet defines a public data structure for this module.
@[heap]
pub struct ElasticNet {
mut:
	name   string
	data   &Data[f64] = unsafe { nil }
	fitted bool
pub mut:
	coef_      []f64
	intercept_ f64
	alpha      f64        = 1.0 // regularization strength
	l1_ratio   f64        = 0.5 // ratio of L1 vs L2 (1.0 = pure Lasso, 0.0 = pure Ridge)
	max_iter   int        = 1000
	tol        f64        = 1e-4
	stat       &Stat[f64] = unsafe { nil }
}

// ElasticNet.new creates a new ElasticNet regression model
pub fn ElasticNet.new(mut data Data[f64], name string, alpha f64, l1_ratio f64) &ElasticNet {
	if alpha < 0 {
		errors.vsl_panic('alpha must be non-negative', .einval)
	}
	if l1_ratio < 0 || l1_ratio > 1 {
		errors.vsl_panic('l1_ratio must be between 0 and 1', .einval)
	}

	mut stat := Stat.from_data(mut data, 'stat_' + name)
	stat.update()

	return &ElasticNet{
		name:     name
		data:     data
		alpha:    alpha
		l1_ratio: l1_ratio
		stat:     stat
		coef_:    []f64{len: data.nb_features}
	}
}

// name returns the model name
pub fn (o &ElasticNet) name() string {
	return o.name
}

// predict returns the prediction for a feature vector
pub fn (o &ElasticNet) predict(x []f64) f64 {
	if x.len != o.coef_.len {
		errors.vsl_panic('input dimension mismatch', .einval)
	}
	return o.intercept_ + la.vector_dot(x, o.coef_)
}

// train fits the ElasticNet model using coordinate descent
pub fn (mut o ElasticNet) train() {
	m := o.data.nb_samples
	n := o.data.nb_features
	x := o.data.x
	y := o.data.y

	// Initialize coefficients
	o.coef_ = []f64{len: n}
	o.intercept_ = 0.0

	// Center y
	mut y_mean := 0.0
	for val in y {
		y_mean += val
	}
	y_mean /= f64(m)

	// Compute X column norms
	mut x_norms := []f64{len: n}
	for j in 0 .. n {
		mut norm := 0.0
		for i in 0 .. m {
			val := x.get(i, j)
			norm += val * val
		}
		x_norms[j] = norm
	}

	// Regularization parameters
	l1_penalty := o.alpha * o.l1_ratio * f64(m) / 2.0
	l2_penalty := o.alpha * (1.0 - o.l1_ratio) * f64(m)

	// Residuals
	mut residual := y.clone()
	for i in 0 .. m {
		residual[i] -= y_mean
	}

	// Coordinate descent
	for iter := 0; iter < o.max_iter; iter++ {
		mut max_change := 0.0

		for j in 0 .. n {
			old_coef := o.coef_[j]
			if old_coef != 0 {
				for i in 0 .. m {
					residual[i] += x.get(i, j) * old_coef
				}
			}

			// Compute gradient
			mut rho := 0.0
			for i in 0 .. m {
				rho += x.get(i, j) * residual[i]
			}

			// Apply soft thresholding with L2 adjustment
			denom := x_norms[j] + l2_penalty
			if denom > 0 {
				o.coef_[j] = soft_threshold(rho, l1_penalty) / denom
			} else {
				o.coef_[j] = 0.0
			}

			// Update residual
			if o.coef_[j] != 0 {
				for i in 0 .. m {
					residual[i] -= x.get(i, j) * o.coef_[j]
				}
			}

			change := math.abs(o.coef_[j] - old_coef)
			if change > max_change {
				max_change = change
			}
		}

		if max_change < o.tol {
			break
		}
	}

	// Compute intercept
	o.intercept_ = y_mean
	for j in 0 .. n {
		mut x_mean := 0.0
		for i in 0 .. m {
			x_mean += x.get(i, j)
		}
		x_mean /= f64(m)
		o.intercept_ -= o.coef_[j] * x_mean
	}

	o.fitted = true
}

// get_plotter returns a plot for the model
pub fn (o &ElasticNet) get_plotter() &plot.Plot {
	min_x := o.stat.min_x[0]
	max_x := o.stat.max_x[0]
	x_values := util.lin_space(min_x, max_x, 100)
	y_values := x_values.map(o.predict([it]))

	mut plt := plot.Plot.new()
	plt.layout(title: 'ElasticNet Regression')
	plt.scatter(name: 'dataset', x: o.data.x.get_col(0), y: o.data.y, mode: 'markers')
	plt.scatter(name: 'prediction', x: x_values, y: y_values, mode: 'lines')

	return plt
}

// Ridge implements linear regression with L2 regularization only
// This is a convenience wrapper using the existing LinReg with lambda

// Ridge defines a public data structure for this module.

// Ridge defines a public data structure for this module.
@[heap]
pub struct Ridge {
mut:
	name   string
	data   &Data[f64] = unsafe { nil }
	fitted bool
pub mut:
	coef_      []f64
	intercept_ f64
	alpha      f64        = 1.0
	stat       &Stat[f64] = unsafe { nil }
	linreg     &LinReg    = unsafe { nil }
}

// Ridge.new creates a new Ridge regression model
pub fn Ridge.new(mut data Data[f64], name string, alpha f64) &Ridge {
	if alpha < 0 {
		errors.vsl_panic('alpha must be non-negative', .einval)
	}

	mut stat := Stat.from_data(mut data, 'stat_' + name)
	stat.update()

	mut linreg := LinReg.new(mut data, name + '_linreg')
	linreg.params.set_lambda(alpha)

	return &Ridge{
		name:   name
		data:   data
		alpha:  alpha
		stat:   stat
		linreg: linreg
		coef_:  []f64{len: data.nb_features}
	}
}

// name returns the model name
pub fn (o &Ridge) name() string {
	return o.name
}

// predict returns the prediction for a feature vector
pub fn (o &Ridge) predict(x []f64) f64 {
	return o.linreg.predict(x)
}

// train fits the Ridge model
pub fn (mut o Ridge) train() {
	o.linreg.train()
	o.coef_ = o.linreg.params.access_thetas().clone()
	o.intercept_ = o.linreg.params.get_bias()
	o.fitted = true
}

// get_plotter returns a plot for the model
pub fn (o &Ridge) get_plotter() &plot.Plot {
	return o.linreg.get_plotter()
}
