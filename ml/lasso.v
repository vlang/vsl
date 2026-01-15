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
@[heap]
pub struct Lasso {
mut:
	name   string // name of this model
	data   &Data[f64] = unsafe { nil } // x-y data
	fitted bool
pub mut:
	coef_      []f64 // learned coefficients (theta)
	intercept_ f64   // learned intercept (bias)
	alpha      f64        = 1.0            // regularization strength
	max_iter   int        = 1000           // maximum iterations
	tol        f64        = 1e-4           // convergence tolerance
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
	m := o.data.nb_samples
	n := o.data.nb_features
	x := o.data.x
	y := o.data.y

	// Initialize coefficients
	o.coef_ = []f64{len: n}
	o.intercept_ = 0.0

	// Center y (compute and store mean)
	mut y_mean := 0.0
	for val in y {
		y_mean += val
	}
	y_mean /= f64(m)

	// Compute X column norms for normalization
	mut x_norms := []f64{len: n}
	for j in 0 .. n {
		mut norm := 0.0
		for i in 0 .. m {
			val := x.get(i, j)
			norm += val * val
		}
		x_norms[j] = norm
	}

	// Residuals
	mut residual := y.clone()
	for i in 0 .. m {
		residual[i] -= y_mean
	}

	// Coordinate descent
	for iter := 0; iter < o.max_iter; iter++ {
		mut max_change := 0.0

		for j in 0 .. n {
			// Add back the contribution of current coefficient
			old_coef := o.coef_[j]
			if old_coef != 0 {
				for i in 0 .. m {
					residual[i] += x.get(i, j) * old_coef
				}
			}

			// Compute the simple linear regression coefficient
			mut rho := 0.0
			for i in 0 .. m {
				rho += x.get(i, j) * residual[i]
			}

			// Apply soft thresholding (L1 regularization)
			if x_norms[j] > 0 {
				o.coef_[j] = soft_threshold(rho, o.alpha * f64(m) / 2.0) / x_norms[j]
			} else {
				o.coef_[j] = 0.0
			}

			// Update residual
			if o.coef_[j] != 0 {
				for i in 0 .. m {
					residual[i] -= x.get(i, j) * o.coef_[j]
				}
			}

			// Track convergence
			change := math.abs(o.coef_[j] - old_coef)
			if change > max_change {
				max_change = change
			}
		}

		// Check convergence
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
