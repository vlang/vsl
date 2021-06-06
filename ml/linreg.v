module ml

import vsl.la

// LinReg implements a linear regression model
[heap]
pub struct LinReg {
	ParamsReg
mut:
	// main
	name   string     // name of this "observer"
	data   &Data      // x-y data
	stat   &Stat      // statistics
	// workspace
	e []f64 // vector e = b⋅o + x⋅theta - y [nb_samples]
}

// new_lin_reg returns a new LinReg object
//   Input:
//     data   -- x,y data
//     name   -- unique name of this (observer) object
pub fn new_lin_reg(mut data Data, name string) &LinReg {
	mut stat := stat_from_data(mut data, 'stat_' + name)
	stat.update()
	mut reg := &LinReg{
		name: name
		data: data
		stat: stat
		e: []f64{len: data.nb_samples}
	}
	reg.init(data.nb_features)
	return reg
}

// name returns the name of this LinReg object (thus defining the Observer interface)
pub fn (o &LinReg) name() string {
	return o.name
}

// predict returns the model evaluation @ {x;theta,b}
//   Input:
//     x -- vector of features
//   Output:
//     y -- model prediction y(x)
pub fn (o &LinReg) predict(x []f64) f64 {
	theta := o.access_thetas()
	b := o.get_bias()
	return b + la.vector_dot(x, theta) // b + xᵀtheta
}

// cost returns the cost c(x;theta,b)
//   Input:
//     data -- x,y data
//     params -- theta and b
//     x -- vector of features
//   Output:
//     c -- total cost (model error)
pub fn (mut o LinReg) cost() f64 {
	// auxiliary
	m_1 := 1.0 / f64(o.data.nb_samples)
	lambda := o.get_lambda()
	theta := o.access_thetas()
	// cost
	o.calce() // e := b⋅o + x⋅theta - y
	mut c := (0.5 * m_1) * la.vector_dot(o.e, o.e) // C := (0.5/m) eᵀe
	if lambda > 0 {
		c += (0.5 * lambda * m_1) * la.vector_dot(theta, theta) // c += (0.5lambda/m) thetaᵀtheta
	}
	return c
}

// gradients returns ∂C/∂theta and ∂C/∂b
//   Output:
//     dcdtheta -- ∂C/∂theta
//     dcdb -- ∂C/∂b
pub fn (mut o LinReg) gradients() ([]f64, f64) {
	// auxiliary
	m_1 := 1.0 / f64(o.data.nb_samples)
	lambda := o.get_lambda()
	theta := o.access_thetas()
	x := o.data.x
	// dcdtheta
	o.calce() // e := b⋅o + x⋅theta - y
	mut dcdtheta := la.matrix_tr_vector_mul(1.0 * m_1, x, o.e) // dcdtheta := (1/m) xᵀe
	if lambda > 0 {
		dcdtheta = la.vector_add(1, dcdtheta, lambda * m_1, theta) // dcdtheta += (1/m) theta
	}
	// dcdb
	return dcdtheta, (1.0 * m_1) * la.vector_accum(o.e) // dcdb = (1/m) oᵀe
}

// train finds theta and b using closed-form solution
//   Input:
//     data -- x,y data
//   Output:
//     params -- theta and b
pub fn (mut o LinReg) train() {
	// auxiliary
	lambda := o.get_lambda()
	x, y := o.data.x, o.data.y
	s, t := o.stat.sum_vars()
	// r vector
	m_1 := 1.0 / f64(o.data.nb_samples)
	n := o.data.nb_features
	mut r := []f64{len: n}
	r = la.matrix_tr_vector_mul(1, x, y) // r := a = xᵀy
	r = la.vector_add(1.0, r, -t * m_1, s) // r := a - (t/m)s
	// K matrix
	mut b := la.new_matrix(n, n)
	mut k := la.new_matrix(n, n)
	b = la.vector_vector_tr_mul(1.0 * m_1, s, s) // b := (1/m) ssᵀ
	la.matrix_tr_matrix_mul(mut k, 1, x, x) // k := A = xᵀx
	la.matrix_add(mut k, 1, k, -1, b) // k := A - b
	if lambda > 0 {
		for i in 0 .. n {
			k.set(i, i, k.get(i, i) + lambda) // k := A - b + lambdaI
		}
	}
	// solve system
	mut theta := o.access_thetas()
	la.den_solve(mut theta, k, r, false)
	b_ := (t - la.vector_dot(s, theta)) * m_1
	o.set_bias(b_)
}

// calce calculates e vector (save into o.e)
//  Output: e = b⋅o + x⋅theta - y
pub fn (mut o LinReg) calce() {
	theta := o.access_thetas()
	b := o.get_bias()
	x, y := o.data.x, o.data.y
	o.e = [b]
	{
		len:
		o.e.len
	} // e := b⋅o
	o.e = la.matrix_vector_mul_add(1, x, theta) // e := b⋅o + x⋅theta
	o.e = la.vector_add(1, o.e, -1, y) // e := b⋅o + x⋅theta - y
}

// str is a custom str function for observers to avoid printing data
pub fn (o &LinReg) str() string {
	mut res := []string{}
	res << 'vsl.ml.LinReg{'
	res << '	name: $o.name'
	res << '    theta: $o.theta'
	res << '    bias: $o.bias'
	res << '    lambda: $o.lambda'
	res << '    degree: $o.degree'
	res << '    bkp_theta: $o.bkp_theta'
	res << '    bkp_bias: $o.bkp_bias'
	res << '    bkp_lambda: $o.bkp_lambda'
	res << '    bkp_degree: $o.bkp_degree'
	res << '    stat: $o.stat'
	res << '    e: $o.e'
	res << '}'
	return res.join('\n')
}
