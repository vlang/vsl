// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module stats

import vsl.la
import vsl.math

// Stat holds statistics about data
//
// NOTE: Stat is an Observer of Data; thus, data.notify_update() will recompute stat
//
pub struct Stat {
pub mut:
	data   &Data // data
	min_x  []f64 // [nFeatures] min x values
	max_x  []f64 // [nFeatures] max x values
	sum_x  []f64 // [nFeatures] sum of x values
	mean_x []f64 // [nFeatures] mean of x values
	sig_x  []f64 // [nFeatures] standard deviations of x
	del_x  []f64 // [nFeatures] difference: max(x) - min(x)
	min_y  f64 // min of y values
	max_y  f64 // max of y values
	sum_y  f64 // sum of y values
	mean_y f64 // mean of y values
	sig_y  f64 // standard deviation of y
	del_y  f64 // difference: max(y) - min(y)
}

// stat returns a new Stat object
pub fn stat_from_data(data mut &Data) Stat {
	mut o := Stat{
		data: data
	}
	o.min_x = [0.0].repeat(data.nb_features)
	o.max_x = [0.0].repeat(data.nb_features)
	o.sum_x = [0.0].repeat(data.nb_features)
	o.mean_x = [0.0].repeat(data.nb_features)
	o.sig_x = [0.0].repeat(data.nb_features)
	o.del_x = [0.0].repeat(data.nb_features)
	data.add_observer(o)
	return o
}

// update compute statistics for given data (an Observer of Data)
pub fn (o mut Stat) update() {
	// constants
	m := o.data.x.m // number of samples
	n := o.data.x.n // number of features
	// x values
	mf := f64(m)
	for j := 0; j < n; j++ {
		o.min_x[j] = o.data.x.get(0, j)
		o.max_x[j] = o.min_x[j]
		o.sum_x[j] = 0.0
		for i := 0; i < m; i++ {
			xval := o.data.x.get(i, j)
			o.min_x[j] = math.min(o.min_x[j], xval)
			o.max_x[j] = math.max(o.max_x[j], xval)
			o.sum_x[j] += xval
		}
		o.mean_x[j] = o.sum_x[j] / mf
		o.sig_x[j] = sample_stddev_mean(o.data.x.col(j), o.mean_x[j])
		o.del_x[j] = o.max_x[j] - o.min_x[j]
	}
	// y values
	if o.data.y.len > 0 {
		o.min_y = o.data.y[0]
		o.max_y = o.min_y
		o.sum_y = 0.0
		for i := 0; i < m; i++ {
			o.min_y = math.min(o.min_y, o.data.y[i])
			o.max_y = math.max(o.max_y, o.data.y[i])
			o.sum_y += o.data.y[i]
		}
		o.mean_y = o.sum_y / mf
		o.sig_y = sample_stddev_mean(o.data.y, o.mean_y)
		o.del_y = o.max_y - o.min_y
	}
}

// sum_vars computes the sums along the columns of X and y
// Output:
// t -- scalar t = oᵀy  sum of columns of the y vector: t = Σ_i^m o_i y_i
// s -- vector s = Xᵀo  sum of columns of the X matrix: s_j = Σ_i^m o_i X_ij  [nFeatures]
pub fn (o mut Stat) sum_vars() ([]f64, f64) {
	one := [1.0].repeat(o.data.x.m)
	s := la.matrix_tr_vector_mul(1, o.data.x, one)
	mut t := 0.0
	if o.data.y.len > 0 {
		t = la.vector_dot(one, o.data.y)
	}
	return s, t
}

// copy_into copies stat into p
pub fn (o Stat) copy_into(p mut Stat) {
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
