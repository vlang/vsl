module ml

import vsl.la
import vsl.util

pub struct ParamsReg {
pub mut:
	observers  []util.Observer // list of interested parties
	// main
	theta      []f64 // theta parameter [nb_features]
	bias       f64 // bias parameter
	lambda     f64 // regularization parameter
	degree     int // degree of polynomial
	// backup
	bkp_theta  []f64 // copy of theta
	bkp_bias   f64 // copy of b
	bkp_lambda f64 // copy of lambda
	bkp_degree int // copy of degree
}

// new_params_reg returns a new object to hold regression parameters
pub fn new_params_reg(nb_features int) ParamsReg {
	theta := []f64{len: nb_features}
	bkp_theta := []f64{len: nb_features}
	return ParamsReg{
		theta: theta
		bkp_theta: bkp_theta
	}
}

// init initializes ParamsReg with nb_features (number of features)
pub fn (mut o ParamsReg) init(nb_features int) {
	o.theta = []f64{len: nb_features}
	o.bkp_theta = []f64{len: nb_features}
}

// backup creates an internal copy of parameters
pub fn (mut o ParamsReg) backup() {
	o.bkp_theta = o.theta.clone()
	o.bkp_bias = o.bias
	o.bkp_lambda = o.lambda
	o.bkp_degree = o.degree
}

// restore restores an internal copy of parameters and notifies observers
pub fn (mut o ParamsReg) restore(skip_notification bool) {
	o.theta = o.bkp_theta.clone()
	o.bias = o.bkp_bias
	o.lambda = o.bkp_lambda
	o.degree = o.bkp_degree
	if !skip_notification {
		o.notify_update()
	}
}

// set_params sets theta and b and notifies observers
pub fn (mut o ParamsReg) set_params(theta []f64, b f64) {
	o.theta = theta.clone()
	o.bias = b
	o.notify_update()
}

// set_param sets either theta or b (use negative indices for b). Notifies observers
//  i -- index of theta or -1 for bias
pub fn (mut o ParamsReg) set_param(i int, value f64) {
	defer {
		o.notify_update()
	}
	if i < 0 {
		o.bias = value
		return
	}
	o.theta[i] = value
}

// get_param returns either theta or b (use negative indices for b)
//  i -- index of theta or -1 for bias
pub fn (o ParamsReg) get_param(i int) f64 {
	if i < 0 {
		return o.bias
	}
	return o.theta[i]
}

// set_thetas sets the whole vector theta and notifies observers
pub fn (mut o ParamsReg) set_thetas(theta []f64) {
	la.vector_apply(mut o.theta, 1.0, theta)
	o.notify_update()
}

// get_thetas gets a copy of theta
pub fn (o ParamsReg) get_thetas() []f64 {
	return o.theta.clone()
}

// access_thetas returns access (slice) to theta
pub fn (o ParamsReg) access_thetas() []f64 {
	return o.theta
}

// access_bias returns access (pointer) to b
pub fn (o ParamsReg) access_bias() &f64 {
	return &o.bias
}

// set_theta sets one component of theta and notifies observers
pub fn (mut o ParamsReg) set_theta(i int, thetai f64) {
	o.theta[i] = thetai
	o.notify_update()
}

// get_theta returns the value of theta[i]
pub fn (o ParamsReg) get_theta(i int) f64 {
	return o.theta[i]
}

// set_bias sets b and notifies observers
pub fn (mut o ParamsReg) set_bias(b f64) {
	o.bias = b
	o.notify_update()
}

// get_bias gets a copy of b
pub fn (o ParamsReg) get_bias() f64 {
	return o.bias
}

// set_lambda sets lambda and notifies observers
pub fn (mut o ParamsReg) set_lambda(lambda f64) {
	o.lambda = lambda
	o.notify_update()
}

// get_lambda gets a copy of lambda
pub fn (o ParamsReg) get_lambda() f64 {
	return o.lambda
}

// set_degree sets p and notifies observers
pub fn (mut o ParamsReg) set_degree(p int) {
	o.degree = p
	o.notify_update()
}

// get_degree gets a copy of p
pub fn (o ParamsReg) get_degree() int {
	return o.degree
}

// add_observer adds an object to the list of interested observers
pub fn (mut o ParamsReg) add_observer(obs util.Observer) {
	o.observers << obs
}

// notify_update notifies observers of updates
pub fn (o ParamsReg) notify_update() {
	for obs in o.observers {
		obs.update()
	}
}
