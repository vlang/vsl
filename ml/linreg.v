module ml

import math
import vsl.la
import vsl.plot
import vsl.util
import vsl.errors

// LinReg implements a linear regression model

// LinReg defines a public data structure for this module.

// LinReg defines a public data structure for this module.
@[heap]
pub struct LinReg {
mut:
	// main
	name string // name of this "observer"
	data &Data[f64] = unsafe { nil } // x-y data
	// workspace
	e              []f64 // vector e = b⋅o + x⋅theta - y [nb_samples]
	sample_weights []f64
	weight_sum     f64
pub mut:
	stat   &Stat[f64]      = unsafe { nil } // statistics
	params &ParamsReg[f64] = unsafe { nil }
}

// LinReg.new returns a new LinReg object
//   Input:
//     data   -- x,y data
//     name   -- unique name of this (observer) object
pub fn LinReg.new(mut data Data[f64], name string) &LinReg {
	mut stat := Stat.from_data(mut data, 'stat_' + name)
	stat.update()
	params := ParamsReg.new[f64](data.nb_features)
	mut reg := &LinReg{
		name:   name
		data:   data
		stat:   stat
		e:      []f64{len: data.nb_samples}
		params: params
	}
	data.add_observer(reg)
	return reg
}

// name returns the name of this LinReg object (thus defining the Observer interface)
pub fn (o &LinReg) name() string {
	return o.name
}

pub fn (mut o LinReg) update() {
	o.reset_stale_sample_weights()
}

// predict returns the model evaluation @ {x;theta,b}
//   Input:
//     x -- vector of features
//   Output:
//     y -- model prediction y(x)
pub fn (o &LinReg) predict(x []f64) f64 {
	theta := o.params.access_thetas()
	b := o.params.get_bias()
	return b + la.vector_dot(x, theta) // b + xᵀtheta
}

fn (mut o LinReg) reset_stale_sample_weights() {
	if o.sample_weights.len > 0 && o.sample_weights.len != o.data.nb_samples {
		o.sample_weights = []f64{}
		o.weight_sum = 0.0
	}
}

// cost returns the cost c(x;theta,b)
//   Input:
//     data -- x,y data
//     params -- theta and b
//     x -- vector of features
//   Output:
//     c -- total cost (model error)
pub fn (mut o LinReg) cost() f64 {
	o.reset_stale_sample_weights()
	// auxiliary
	weight_sum := if o.sample_weights.len == 0 { f64(o.data.nb_samples) } else { o.weight_sum }
	m_1 := 1.0 / weight_sum
	lambda := o.params.get_lambda()
	theta := o.params.access_thetas()
	// cost
	o.calce() // e := b⋅o + x⋅theta - y
	mut squared_error := 0.0
	if o.sample_weights.len == 0 {
		squared_error = la.vector_dot(o.e, o.e)
	} else {
		for i in 0 .. o.data.nb_samples {
			squared_error += o.sample_weights[i] * o.e[i] * o.e[i]
		}
	}
	mut c := (0.5 * m_1) * squared_error
	if lambda > 0 {
		c += (0.5 * lambda * m_1) * la.vector_dot(theta, theta)
	}
	return c
}

// gradients returns ∂C/∂theta and ∂C/∂b
//   Output:
//     dcdtheta -- ∂C/∂theta
//     dcdb -- ∂C/∂b
pub fn (mut o LinReg) gradients() ([]f64, f64) {
	o.reset_stale_sample_weights()
	// auxiliary
	weight_sum := if o.sample_weights.len == 0 { f64(o.data.nb_samples) } else { o.weight_sum }
	m_1 := 1.0 / weight_sum
	lambda := o.params.get_lambda()
	theta := o.params.access_thetas()
	x := o.data.x
	// dcdtheta
	o.calce() // e := b⋅o + x⋅theta - y
	mut dcdtheta := []f64{len: o.data.nb_features}
	if o.sample_weights.len == 0 {
		dcdtheta = la.matrix_tr_vector_mul(m_1, x, o.e)
	} else {
		for j in 0 .. o.data.nb_features {
			for i in 0 .. o.data.nb_samples {
				dcdtheta[j] += o.sample_weights[i] * x.get(i, j) * o.e[i] * m_1
			}
		}
	}
	if lambda > 0 {
		dcdtheta = la.vector_add(1.0, dcdtheta, lambda * m_1, theta)
	}
	// dcdb
	mut bias_gradient := la.vector_accum(o.e) * m_1
	if o.sample_weights.len > 0 {
		bias_gradient = 0.0
		for i in 0 .. o.data.nb_samples {
			bias_gradient += o.sample_weights[i] * o.e[i] * m_1
		}
	}
	return dcdtheta, bias_gradient
}

// train finds theta and b using closed-form solution
//   Input:
//     data -- x,y data
//   Output:
//     params -- theta and b
pub fn (mut o LinReg) train() {
	o.sample_weights = []
	o.weight_sum = 0.0
	// auxiliary
	lambda := o.params.get_lambda()
	x, y := o.data.x, o.data.y
	s, t := o.stat.sum_vars()
	// r vector
	m_1 := 1.0 / f64(o.data.nb_samples)
	n := o.data.nb_features
	mut r := []f64{len: n}
	r = la.matrix_tr_vector_mul(1.0, x, y) // r := a = xᵀy
	r = la.vector_add(1.0, r, -t * m_1, s) // r := a - (t/m)s
	// K matrix
	mut b := la.Matrix.new[f64](n, n)
	mut k := la.Matrix.new[f64](n, n)
	b = la.vector_vector_tr_mul(1.0 * m_1, s, s) // b := (1/m) ssᵀ
	la.matrix_tr_matrix_mul(mut k, 1, x, x) // k := A = xᵀx
	la.matrix_add(mut k, 1, k, -1, b) // k := A - b
	if lambda > 0 {
		for i in 0 .. n {
			k.set(i, i, k.get(i, i) + lambda) // k := A - b + lambdaI
		}
	}
	// solve system
	mut theta := o.params.access_thetas()
	la.den_solve(mut theta, k, r, false)
	b_ := (t - la.vector_dot(s, theta)) * m_1
	o.params.set_bias(b_)
}

// train_with_sample_weights fits the model using one finite, non-negative
// weight per sample. An empty slice assigns unit weight to every sample.
pub fn (mut o LinReg) train_with_sample_weights(sample_weights []f64) ! {
	m := o.data.nb_samples
	n := o.data.nb_features
	if m <= 0 || o.data.x.m != m || o.data.x.n != n || o.data.y.len != m {
		return errors.error('training data dimensions do not match', .einval)
	}
	if sample_weights.len != 0 && sample_weights.len != m {
		return errors.error('sample_weights must be empty or match the number of samples',
			.einval)
	}
	weights := if sample_weights.len == 0 {
		[]f64{len: m, init: 1.0}
	} else {
		sample_weights.clone()
	}
	mut total_weight := 0.0
	for i in 0 .. m {
		weight := weights[i]
		if math.is_nan(weight) || math.is_inf(weight, 0) || weight < 0.0 {
			return errors.error('sample weights must be finite and non-negative', .einval)
		}
		total_weight += weight
		if math.is_inf(total_weight, 0) {
			return errors.error('sum of sample weights overflowed', .einval)
		}
		if math.is_nan(o.data.y[i]) || math.is_inf(o.data.y[i], 0) {
			return errors.error('training targets must be finite', .einval)
		}
		for j in 0 .. n {
			value := o.data.x.get(i, j)
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('training features must be finite', .einval)
			}
		}
	}
	if total_weight <= 0.0 {
		return errors.error('sample weights must have a positive sum', .einval)
	}

	mut sum_x := []f64{len: n}
	mut sum_y := 0.0
	for i in 0 .. m {
		weight := weights[i]
		sum_y += weight * o.data.y[i]
		for j in 0 .. n {
			sum_x[j] += weight * o.data.x.get(i, j)
		}
	}
	if math.is_nan(sum_y) || math.is_inf(sum_y, 0) {
		return errors.error('weighted target sum overflowed', .einval)
	}
	for j in 0 .. n {
		if math.is_nan(sum_x[j]) || math.is_inf(sum_x[j], 0) {
			return errors.error('weighted feature sums overflowed', .einval)
		}
	}

	mut mean_x := []f64{len: n}
	for j in 0 .. n {
		mean_x[j] = sum_x[j] / total_weight
		if math.is_nan(mean_x[j]) || math.is_inf(mean_x[j], 0) {
			return errors.error('weighted feature means overflowed', .einval)
		}
	}
	mean_y := sum_y / total_weight
	if math.is_nan(mean_y) || math.is_inf(mean_y, 0) {
		return errors.error('weighted target mean overflowed', .einval)
	}

	mut rhs := []f64{len: n}
	mut covariance := la.Matrix.new[f64](n, n)
	for i in 0 .. m {
		weight := weights[i]
		if weight == 0.0 {
			continue
		}
		y_centered := o.data.y[i] - mean_y
		for j in 0 .. n {
			x_j_centered := o.data.x.get(i, j) - mean_x[j]
			rhs[j] += weight * x_j_centered * y_centered
			for k in 0 .. n {
				x_k_centered := o.data.x.get(i, k) - mean_x[k]
				covariance.set(j, k, covariance.get(j, k) + weight * x_j_centered *
					x_k_centered)
			}
		}
	}
	for j in 0 .. n {
		if math.is_nan(rhs[j]) || math.is_inf(rhs[j], 0) {
			return errors.error('centered weighted target products overflowed', .einval)
		}
		for k in 0 .. n {
			value := covariance.get(j, k)
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('centered weighted feature products overflowed', .einval)
			}
		}
	}
	if n == 0 {
		o.params.set_bias(sum_y / total_weight)
	} else {
		lambda := o.params.get_lambda()
		if lambda > 0.0 {
			for j in 0 .. n {
				covariance.set(j, j, covariance.get(j, j) + lambda)
			}
		}
		mut theta := o.params.access_thetas()
		la.den_solve(mut theta, covariance, rhs, false)
		bias := mean_y - la.vector_dot(mean_x, theta)
		o.params.set_bias(bias)
	}
	o.sample_weights = if sample_weights.len == 0 { []f64{} } else { weights }
	o.weight_sum = total_weight
}

// calce calculates e vector (save into o.e)
//  Output: e = b⋅o + x⋅theta - y
pub fn (mut o LinReg) calce() {
	theta := o.params.access_thetas()
	b := o.params.get_bias()
	x, y := o.data.x, o.data.y
	o.e = la.matrix_vector_mul_add(1.0, x, theta)
	for i in 0 .. o.data.nb_samples {
		o.e[i] += b
	}
	o.e = la.vector_add(1.0, o.e, -1.0, y)
}

// str is a custom str function for observers to avoid printing data
pub fn (o &LinReg) str() string {
	mut res := []string{}
	res << 'vsl.ml.LinReg{'
	res << '    name: ${o.name}'
	res << '    params: ${o.params}'
	res << '    stat: ${o.stat}'
	res << '    e: ${o.e}'
	res << '}'
	return res.join('\n')
}

// get_plotter returns a plot.Plot struct for plotting the data and the linear regression model
pub fn (o &LinReg) get_plotter() &plot.Plot {
	// Get the minimum and maximum values of the features
	min_x := o.stat.min_x[0]
	max_x := o.stat.max_x[0]

	// Generate a range based on the minimum and maximum values
	x_values :=
		util.lin_space(min_x, max_x, 100) // You can adjust the number of points (100 in this case)

	// Calculate prediction values for the range
	y_values := x_values.map(o.predict([it]))

	// Rest of the code for plotting the graph
	mut plt := plot.Plot.new()
	plt.layout(
		title: 'Linear Regression Example'
	)
	plt.scatter(
		name: 'dataset'
		x:    o.data.x.get_col(0)
		y:    o.data.y
		mode: 'markers'
	)
	plt.scatter(
		name: 'prediction'
		x:    x_values
		y:    y_values
		mode: 'lines'
	)

	return plt
}
