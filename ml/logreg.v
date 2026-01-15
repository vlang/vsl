module ml

import math
import vsl.fun
import vsl.la
import vsl.plot
import vsl.util
import vsl.errors

// LogReg implements a logistic regression model (Observer of Data)
@[heap]
pub struct LogReg {
mut:
	// main
	name string // name of this "observer"
	data &Data[f64] = unsafe { nil } // x-y data
	// workspace
	ybar []f64 // bar{y}: yb[i] = (1 - y[i]) / m
	l    []f64 // vector l = b⋅o + x⋅θ [nb_samples]
	hmy  []f64 // vector e = h(l) - y [nb_samples]
pub mut:
	params &ParamsReg[f64] = unsafe { nil } // parameters: θ, b, λ
	stat   &Stat[f64]      = unsafe { nil } // statistics
}

// LogReg.new returns a new LogReg object
//   Input:
//     data   -- x,y data
//     name   -- unique name of this (observer) object
//   Output:
//     new LogReg object
pub fn LogReg.new(mut data Data[f64], name string) &LogReg {
	if data.y.len == 0 {
		errors.vsl_panic('LogReg requires y data (binary classification)', .einval)
	}
	mut stat := Stat.from_data(mut data, 'stat_' + name)
	stat.update()
	params := ParamsReg.new[f64](data.nb_features)
	mut log_reg := &LogReg{
		name:   name
		data:   data
		params: params
		stat:   stat
		ybar:   []f64{len: data.nb_samples}
		l:      []f64{len: data.nb_samples}
		hmy:    []f64{len: data.nb_samples}
	}
	data.add_observer(log_reg) // need to recompute ybar upon changes on y
	log_reg.update() // compute first ybar
	return log_reg
}

// name returns the name of this LogReg object (thus defining the Observer interface)
pub fn (o &LogReg) name() string {
	return o.name
}

// update perform updates after data has been changed (as an Observer)
pub fn (mut o LogReg) update() {
	if o.data.nb_samples == 0 {
		return
	}
	m_1 := 1.0 / f64(o.data.nb_samples)
	// Resize arrays if needed
	if o.ybar.len != o.data.nb_samples {
		o.ybar = []f64{len: o.data.nb_samples}
	}
	if o.l.len != o.data.nb_samples {
		o.l = []f64{len: o.data.nb_samples}
	}
	if o.hmy.len != o.data.nb_samples {
		o.hmy = []f64{len: o.data.nb_samples}
	}
	// Recompute ybar
	for i in 0 .. o.data.nb_samples {
		o.ybar[i] = (1.0 - o.data.y[i]) * m_1
	}
}

// predict returns the model evaluation @ {x;θ,b}
//   Input:
//     x -- vector of features
//   Output:
//     y -- model prediction y(x) (probability between 0 and 1)
pub fn (o &LogReg) predict(x []f64) f64 {
	if x.len != o.data.nb_features {
		errors.vsl_panic('predict: x must have ${o.data.nb_features} features, got ${x.len}',
			.einval)
	}
	theta := o.params.access_thetas()
	b := o.params.get_bias()
	return fun.logistic(b + la.vector_dot(x, theta)) // g(b + xᵀθ) where g is logistic
}

// cost returns the cost c(x;θ,b)
//   Output:
//     c -- total cost (model error)
pub fn (mut o LogReg) cost() f64 {
	// auxiliary
	m_1 := 1.0 / f64(o.data.nb_samples)
	lambda := o.params.get_lambda()
	theta := o.params.access_thetas()

	// cost
	o.calcl()
	sq := o.calcsumq()
	mut c := sq * m_1 + la.vector_dot(o.ybar, o.l)
	if lambda > 0 {
		c += (0.5 * lambda * m_1) * la.vector_dot(theta, theta) // c += (0.5λ/m) θᵀθ
	}
	return c
}

// allocate_gradient allocate object to compute gradients
pub fn (o &LogReg) allocate_gradient() []f64 {
	return []f64{len: o.data.nb_features}
}

// gradients returns ∂C/∂θ and ∂C/∂b
//   Output:
//     dcdtheta -- ∂C/∂θ
//     dcdb -- ∂C/∂b
pub fn (mut o LogReg) gradients() ([]f64, f64) {
	// auxiliary
	m_1 := 1.0 / f64(o.data.nb_samples)
	lambda := o.params.get_lambda()
	theta := o.params.access_thetas()
	x := o.data.x

	// dcdtheta
	o.calcl() // l := b + x⋅θ
	o.calchmy() // hmy := h(l) - y
	mut dcdtheta := la.matrix_tr_vector_mul(1.0 * m_1, x, o.hmy) // dcdtheta := (1/m) xᵀhmy
	if lambda > 0 {
		dcdtheta = la.vector_add(1.0, dcdtheta, lambda * m_1, theta) // dcdtheta += (λ/m) θ
	}

	// dcdb
	return dcdtheta, m_1 * la.vector_accum(o.hmy) // dcdb = (1/m) oᵀhmy
}

// allocate_hessian allocate objects to compute hessian
pub fn (o &LogReg) allocate_hessian() ([]f64, []f64, &la.Matrix[f64], &la.Matrix[f64]) {
	m := o.data.nb_samples
	n := o.data.nb_features
	d := []f64{len: m}
	v := []f64{len: n}
	dm := la.Matrix.new[f64](m, n)
	hm := la.Matrix.new[f64](n, n)
	return d, v, dm, hm
}

// hessian computes the hessian matrix and other partial derivatives
//
//   Input:
//     d -- [nSamples]  d[i] = g(l[i]) * [ 1 - g(l[i]) ]  auxiliary vector
//     v -- [nFeatures] v = ∂²C/∂θ∂b second order partial derivative
//     dm -- [nSamples][nFeatures]  dm[i][j] = d[i]*x[i][j]  auxiliary matrix
//     hm -- [nFeatures][nFeatures]  hm = ∂²C/∂θ² hessian matrix
//
//   Output:
//     w -- ∂²C/∂b²
//
pub fn (mut o LogReg) hessian(mut d []f64, mut v []f64, mut dm la.Matrix[f64], mut hm la.Matrix[f64]) f64 {
	// auxiliary
	m := o.data.nb_samples
	n := o.data.nb_features
	x := o.data.x
	lambda := o.params.get_lambda()
	mm_1 := 1.0 / f64(m)

	// calc d vector and dm matrix
	o.calcl()
	for i in 0 .. m {
		d[i] = fun.logistic_d1(o.l[i]) // d vector
		for j in 0 .. n {
			dm.set(i, j, d[i] * x.get(i, j)) // dm matrix
		}
	}

	// calc hm matrix
	la.matrix_tr_matrix_mul(mut hm, 1.0 * mm_1, x, dm)
	if lambda > 0 {
		for i in 0 .. n {
			hm.set(i, i, hm.get(i, i) + lambda * mm_1) // hm += (λ/m) I
		}
	}

	// calc v
	v = la.matrix_tr_vector_mul(1.0 * mm_1, x, d) // v := (1/m) xᵀd

	// calc w
	w := la.vector_accum(d) * mm_1
	return w
}

// LogRegTrainConfig holds training configuration for logistic regression
pub struct LogRegTrainConfig {
pub:
	epochs        int = 1000 // maximum number of iterations
	learning_rate f64 = 0.01 // learning rate for gradient descent
	tolerance     f64 = 1e-6 // convergence tolerance
	use_newton    bool // use Newton's method instead of gradient descent
}

// train finds θ and b using gradient descent or Newton's method
pub fn (mut o LogReg) train(config LogRegTrainConfig) {
	if config.use_newton {
		o.train_newton(config)
	} else {
		o.train_gradient_descent(config)
	}
}

// train_gradient_descent trains model using gradient descent
fn (mut o LogReg) train_gradient_descent(config LogRegTrainConfig) {
	alpha := config.learning_rate
	mut prev_cost := o.cost()
	mut cost := prev_cost

	for epoch := 0; epoch < config.epochs; epoch++ {
		dcdtheta, dcdb := o.gradients()

		// update parameters
		theta := o.params.access_thetas()
		mut new_theta := la.vector_add(1.0, theta, -alpha, dcdtheta)
		o.params.set_thetas(new_theta)
		o.params.set_bias(o.params.get_bias() - alpha * dcdb)

		// check convergence
		cost = o.cost()
		if math.abs(cost - prev_cost) < config.tolerance {
			break
		}
		prev_cost = cost
	}
}

// train_newton trains model using Newton's method
fn (mut o LogReg) train_newton(config LogRegTrainConfig) {
	n := o.data.nb_features
	d, v, mut dm, mut hm := o.allocate_hessian()

	for epoch := 0; epoch < config.epochs; epoch++ {
		dcdtheta, dcdb := o.gradients()
		mut d_mut := d.clone()
		mut v_mut := v.clone()
		w := o.hessian(mut d_mut, mut v_mut, mut dm, mut hm)

		// build full Hessian matrix H = [hm v; vᵀ w]
		mut h_full := la.Matrix.new[f64](n + 1, n + 1)
		for i in 0 .. n {
			for j in 0 .. n {
				h_full.set(i, j, hm.get(i, j))
			}
			h_full.set(i, n, v[i])
			h_full.set(n, i, v[i])
		}
		h_full.set(n, n, w)

		// build gradient vector [dcdtheta; dcdb]
		mut grad := []f64{len: n + 1}
		theta := o.params.access_thetas()
		for i in 0 .. n {
			grad[i] = dcdtheta[i]
		}
		grad[n] = dcdb

		// solve H * delta = -grad
		mut delta := []f64{len: n + 1}
		for i in 0 .. n + 1 {
			delta[i] = -grad[i]
		}
		la.den_solve(mut delta, h_full, delta, false)

		// update parameters
		mut new_theta := []f64{len: n}
		for i in 0 .. n {
			new_theta[i] = theta[i] + delta[i]
		}
		o.params.set_thetas(new_theta)
		o.params.set_bias(o.params.get_bias() + delta[n])

		// check convergence
		if la.vector_norm(delta) < config.tolerance {
			break
		}
	}
}

// calcl calculates l vector (saves into o.l) (linear model)
//  Output: l = b⋅o + x⋅θ
pub fn (mut o LogReg) calcl() {
	theta := o.params.access_thetas()
	b := o.params.get_bias()
	x := o.data.x
	// l := b⋅o + x⋅θ
	// First compute x⋅θ, then add bias to each element
	o.l = la.matrix_vector_mul(1.0, x, theta) // l := x⋅θ
	for i in 0 .. o.data.nb_samples {
		o.l[i] += b // l := b⋅o + x⋅θ
	}
}

// calcsumq calculates Σq[i] where q[i] = log(1 + exp(-l[i]))
//  Input:
//    l -- precomputed o.l
//  Output:
//    sq -- sum(q)
pub fn (o &LogReg) calcsumq() f64 {
	mut sq := 0.0
	for i := 0; i < o.data.nb_samples; i++ {
		sq += safe_log_1p_exp(o.l[i])
	}
	return sq
}

// calchmy calculates h(l) - y vector (saves into o.hmy)
//  Input:
//    l -- precomputed o.l
//  Output:
//    hmy -- computes hmy = h(l) - y
pub fn (mut o LogReg) calchmy() {
	for i in 0 .. o.data.nb_samples {
		o.hmy[i] = fun.logistic(o.l[i]) - o.data.y[i]
	}
}

// safe_log_1p_exp computes log(1+exp(-z)) safely by checking if exp(-z) is >> 1,
// thus returning -z. This is the case when z<0 and |z| is too large
pub fn safe_log_1p_exp(z f64) f64 {
	if z < -500 {
		return -z
	}
	return math.log(1.0 + math.exp(-z))
}

// str is a custom str function for observers to avoid printing data
pub fn (o &LogReg) str() string {
	mut res := []string{}
	res << 'vsl.ml.LogReg{'
	res << '    name: ${o.name}'
	res << '    params: ${o.params}'
	res << '    stat: ${o.stat}'
	res << '}'
	return res.join('\n')
}

// get_plotter returns a plot.Plot struct for plotting the data and the logistic regression model
pub fn (o &LogReg) get_plotter() &plot.Plot {
	// Get the minimum and maximum values of the features
	min_x := o.stat.min_x[0]
	max_x := o.stat.max_x[0]

	// Generate a range based on the minimum and maximum values
	x_values := util.lin_space(min_x, max_x, 100)

	// Calculate prediction values for the range
	y_values := x_values.map(o.predict([it]))

	// Create plot
	mut plt := plot.Plot.new()
	plt.layout(
		title: 'Logistic Regression'
	)

	// Plot data points
	plt.scatter(
		name: 'dataset'
		x:    o.data.x.get_col(0)
		y:    o.data.y
		mode: 'markers'
	)

	// Plot decision boundary (sigmoid curve)
	plt.scatter(
		name: 'decision_boundary'
		x:    x_values
		y:    y_values
		mode: 'lines'
	)

	return plt
}
