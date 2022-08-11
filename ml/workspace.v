module ml

import math
import math.stats
import vsl.la

// Stat holds statistics about data
//
// NOTE: Stat is an Observer of Data; thus, data.notify_update() will recompute stat
//
[heap]
pub struct Stat<T> {
pub mut:
	data   &Data<T> // data
	name   string   // name of this object
	min_x  []T      // [n_features] min x values
	max_x  []T      // [n_features] max x values
	sum_x  []T      // [n_features] sum of x values
	mean_x []T      // [n_features] mean of x values
	sig_x  []T      // [n_features] standard deviations of x
	del_x  []T      // [n_features] difference: max(x) - min(x)
	min_y  T        // min of y values
	max_y  T        // max of y values
	sum_y  T        // sum of y values
	mean_y T        // mean of y values
	sig_y  T        // standard deviation of y
	del_y  T        // difference: max(y) - min(y)
}

// stat returns a new Stat object
pub fn stat_from_data<T>(mut data Data<T>, name string) &Stat<T> {
	mut o := &Stat<T>{
		name: name
		data: data
		min_x: []T{len: data.nb_features}
		max_x: []T{len: data.nb_features}
		sum_x: []T{len: data.nb_features}
		mean_x: []T{len: data.nb_features}
		sig_x: []T{len: data.nb_features}
		del_x: []T{len: data.nb_features}
	}
	data.add_observer(o)
	return o
}

// name returns the name of this stat object (thus defining the Observer interface)
pub fn (o &Stat<T>) name() string {
	return o.name
}

// update compute statistics for given data (an Observer of Data)
pub fn (mut o Stat<T>) update() {
	// constants
	m := o.data.x.m // number of samples
	n := o.data.x.n // number of features
	// x values
	mf := T(m)
	for j in 0 .. n {
		o.min_x[j] = o.data.x.get(0, j)
		o.max_x[j] = o.min_x[j]
		o.sum_x[j] = 0.0
		for i in 0 .. m {
			xval := o.data.x.get(i, j)
			o.min_x[j] = math.min(o.min_x[j], xval)
			o.max_x[j] = math.max(o.max_x[j], xval)
			o.sum_x[j] += xval
		}
		o.mean_x[j] = o.sum_x[j] / mf
		o.sig_x[j] = stats.sample_stddev_mean(o.data.x.get_col(j), o.mean_x[j])
		o.del_x[j] = o.max_x[j] - o.min_x[j]
	}
	// y values
	if o.data.y.len > 0 {
		o.min_y = o.data.y[0]
		o.max_y = o.min_y
		o.sum_y = 0.0
		for i in 0 .. m {
			o.min_y = math.min(o.min_y, o.data.y[i])
			o.max_y = math.max(o.max_y, o.data.y[i])
			o.sum_y += o.data.y[i]
		}
		o.mean_y = o.sum_y / mf
		o.sig_y = stats.sample_stddev_mean(o.data.y, o.mean_y)
		o.del_y = o.max_y - o.min_y
	}
}

// sum_vars computes the sums along the columns of X and y
// Output:
// t -- scalar t = oᵀy  sum of columns of the y vector: t = Σ_i^m o_i y_i
// s -- vector s = Xᵀo  sum of columns of the X matrix: s_j = Σ_i^m o_i X_ij  [n_features]
pub fn (mut o Stat<T>) sum_vars() ([]T, T) {
	one := []T{len: o.data.x.m, init: T(1)}
	s := la.matrix_tr_vector_mul(1.0, o.data.x, one)
	mut t := 0.0
	if o.data.y.len > 0 {
		t = la.vector_dot(one, o.data.y)
	}
	return s, t
}

// copy_into copies stat into p
pub fn (o &Stat<T>) copy_into(mut p Stat<T>) {
	p.min_x = o.min_x.clone()
	p.max_x = o.max_x.clone()
	p.sum_x = o.sum_x.clone()
	p.mean_x = o.mean_x.clone()
	p.sig_x = o.sig_x.clone()
	p.del_x = o.del_x.clone()
	p.min_y = o.min_y
	p.max_y = o.max_y
	p.sum_y = o.sum_y
	p.mean_y = o.mean_y
	p.sig_y = o.sig_y
	p.del_y = o.del_y
}

// str is a custom str function for observers to avoid printing data
pub fn (o &Stat<T>) str() string {
	mut res := []string{}
	res << 'vsl.ml.Stat<$T.name>{'
	res << '    name: $o.name'
	res << '    min_x: $o.min_x'
	res << '    max_x: $o.max_x'
	res << '    sum_x: $o.sum_x'
	res << '    mean_x: $o.mean_x'
	res << '    sig_x: $o.sig_x'
	res << '    del_x: $o.del_x'
	res << '    min_y: $o.min_y'
	res << '    max_y: $o.max_y'
	res << '    sum_y: $o.sum_y'
	res << '    mean_y: $o.mean_y'
	res << '    sig_y: $o.sig_y'
	res << '    del_y: $o.del_y'
	res << '}'
	return res.join('\n')
}
