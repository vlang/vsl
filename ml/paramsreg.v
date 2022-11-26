module ml

import vsl.la
import vsl.util

[heap]
pub struct ParamsReg[T] {
pub mut:
	observable util.Observable
	// main
	theta  []T // theta parameter [nb_features]
	bias   T   // bias parameter
	lambda T   // regularization parameter
	degree int // degree of polynomial
	// backup
	bkp_theta  []T // copy of theta
	bkp_bias   T   // copy of b
	bkp_lambda T   // copy of lambda
	bkp_degree int // copy of degree
}

// new_params_reg returns a new object to hold regression parameters
pub fn new_params_reg[T](nb_features int) &ParamsReg[T] {
	theta := []T{len: nb_features}
	bkp_theta := []T{len: nb_features}
	return &ParamsReg[T]{
		theta: theta
		bkp_theta: bkp_theta
	}
}

// init initializes ParamsReg with nb_features (number of features)
pub fn (mut o ParamsReg[T]) init(nb_features int) {
	o.theta = []T{len: nb_features}
	o.bkp_theta = []T{len: nb_features}
}

// backup creates an internal copy of parameters
pub fn (mut o ParamsReg[T]) backup() {
	o.bkp_theta = o.theta.clone()
	o.bkp_bias = o.bias
	o.bkp_lambda = o.lambda
	o.bkp_degree = o.degree
}

// restore restores an internal copy of parameters and notifies observers
pub fn (mut o ParamsReg[T]) restore(skip_notification bool) {
	o.theta = o.bkp_theta.clone()
	o.bias = o.bkp_bias
	o.lambda = o.bkp_lambda
	o.degree = o.bkp_degree
	if !skip_notification {
		o.notify_update()
	}
}

// set_params sets theta and b and notifies observers
pub fn (mut o ParamsReg[T]) set_params(theta []T, b T) {
	o.theta = theta.clone()
	o.bias = b
	o.notify_update()
}

// set_param sets either theta or b (use negative indices for b). Notifies observers
//  i -- index of theta or -1 for bias
pub fn (mut o ParamsReg[T]) set_param(i int, value T) {
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
pub fn (o &ParamsReg[T]) get_param(i int) T {
	if i < 0 {
		return o.bias
	}
	return o.theta[i]
}

// set_thetas sets the whole vector theta and notifies observers
pub fn (mut o ParamsReg[T]) set_thetas(theta []T) {
	la.vector_apply(mut o.theta, 1.0, theta)
	o.notify_update()
}

// get_thetas gets a copy of theta
pub fn (o &ParamsReg[T]) get_thetas() []T {
	return o.theta.clone()
}

// access_thetas returns access (slice) to theta
pub fn (o &ParamsReg[T]) access_thetas() []T {
	return o.theta
}

// access_bias returns access (pointer) to b
pub fn (o &ParamsReg[T]) access_bias() &T {
	return &o.bias
}

// set_theta sets one component of theta and notifies observers
pub fn (mut o ParamsReg[T]) set_theta(i int, thetai T) {
	o.theta[i] = thetai
	o.notify_update()
}

// get_theta returns the value of theta[i]
pub fn (o &ParamsReg[T]) get_theta(i int) T {
	return o.theta[i]
}

// set_bias sets b and notifies observers
pub fn (mut o ParamsReg[T]) set_bias(b T) {
	o.bias = b
	o.notify_update()
}

// get_bias gets a copy of b
pub fn (o &ParamsReg[T]) get_bias() T {
	return o.bias
}

// set_lambda sets lambda and notifies observers
pub fn (mut o ParamsReg[T]) set_lambda(lambda T) {
	o.lambda = lambda
	o.notify_update()
}

// get_lambda gets a copy of lambda
pub fn (o &ParamsReg[T]) get_lambda() T {
	return o.lambda
}

// set_degree sets p and notifies observers
pub fn (mut o ParamsReg[T]) set_degree(p int) {
	o.degree = p
	o.notify_update()
}

// get_degree gets a copy of p
pub fn (o &ParamsReg[T]) get_degree() int {
	return o.degree
}

// add_observer adds an object to the list of interested observers
pub fn (mut o ParamsReg[T]) add_observer(obs util.Observer) {
	o.observable.add_observer(obs)
}

// notify_update notifies observers of updates
pub fn (mut o ParamsReg[T]) notify_update() {
	o.observable.notify_update()
}
