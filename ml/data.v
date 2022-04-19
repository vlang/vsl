module ml

import vsl.util
import vsl.la
import vsl.errors

/*
* Data<T> holds data in matrix format; e.g. for regression computations
 *
 *   Example:
 *          _          _                                     _   _
 *         |  -1  0 -3  |                                   |  0  |
 *         |  -2  3  3  |                       (optional)  |  1  |
 *     x = |   3  1  4  |                               y = |  1  |
 *         |  -4  5  0  |                                   |  0  |
 *         |_  1 -8  5 _|(nb_samples x nb_features)         |_ 1 _|(nb_samples)
 *
 *   NOTE: remember to call data.notify_update() after changing x or y components
 *
*/
[heap]
pub struct Data<T> {
pub mut:
	observable util.Observable
	nb_samples  int // number of data points (samples). number of rows in x and y
	nb_features int // number of features. number of columns in x
	x           &la.Matrix<T> // [nb_samples][nb_features] x values
	y           []T // [nb_samples] y values [optional]
}

// new_data returns a new object to hold ML data
// Input:
// nb_samples  -- number of data samples (rows in x)
// nb_features -- number of features (columns in x)
// use_y       -- use y data vector
// allocate    -- allocates x (and y); otherwise,
// x and y must be set using set() method
// Output:
// new object
pub fn new_data<T>(nb_samples int, nb_features int, use_y bool, allocate bool) ?&Data<T> {
	x := if allocate {
		la.new_matrix<T>(nb_samples, nb_features)
	} else {
		la.new_matrix<T>(0, 0)
	}
	mut y := []T{}
	if allocate && use_y {
		y = []T{len: nb_samples}
	}
	return &Data<T>{
		x: x
		y: y
		nb_samples: nb_samples
		nb_features: nb_features
	}
}

// set sets x matrix and y vector [optional] and notify observers
// Input:
// x -- x values
// y -- y values [optional]
pub fn (mut o Data<T>) set(x &la.Matrix<T>, y []T) {
	o.x = x
	o.y = y
	o.observable.notify_update()
}

// data_from_raw_x returns a new object with data set from raw x values
// Input:
// xraw -- [nb_samples][nb_features] table with x values (NO y values)
// Output:
// new object
pub fn data_from_raw_x<T>(xraw [][]T) ?&Data<T> {
	// check
	nb_samples := xraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xraw[0].len
	mut o := new_data<T>(nb_samples, nb_features, true, true) ?
	// copy data from raw table to x matrix
	for i := 0; i < nb_samples; i++ {
		for j := 0; j < nb_features; j++ {
			o.x.set(i, j, xraw[i][j])
		}
	}
	return o
}

// data_from_raw_xy_sep accepts two parameters: xraw [][]T and
// yraw []T. It acts similarly to data_from_raw_xy, but instead
// of using the last column of xraw as the y data, it uses yraw
// instead.
pub fn data_from_raw_xy_sep<T>(xraw [][]T, yraw []T) ?&Data<T> {
	// check
	nb_samples := xraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xraw[0].len
	mut o := new_data<T>(nb_samples, nb_features, false, true) ?
	// copy data from raw table to x matrix
	for i := 0; i < nb_samples; i++ {
		for j := 0; j < nb_features; j++ {
			o.x.set(i, j, xraw[i][j])
		}
	}
	for i := 0; i < nb_samples; i++ {
		o.y << yraw[i]
	}
	return o
}

// data_from_raw_xy returns a new object with data set from raw Xy values
// Input:
// Xyraw -- [nb_samples][nb_features+1] table with x and y raw values,
// where the last column contains y-values
// Output:
// new object
pub fn data_from_raw_xy<T>(xyraw [][]T) ?&Data<T> {
	// check
	nb_samples := xyraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xyraw[0].len - 1 // -1 because of y column
	mut o := new_data<T>(nb_samples, nb_features, true, true) ?
	// copy data from raw table to x and y arrays
	for i := 0; i < nb_samples; i++ {
		for j := 0; j < nb_features; j++ {
			o.x.set(i, j, xyraw[i][j])
		}
		o.y[i] = xyraw[i][nb_features]
	}
	return o
}

// clone returns a deep copy of this object
pub fn (o &Data<T>) clone() ?&Data<T> {
	use_y := o.y.len > 0
	mut p := new_data<T>(o.nb_samples, o.nb_features, use_y, true) ?
	o.x.copy_into(mut p.x, 1)
	if use_y {
		p.y = o.y.clone()
	}
	return p
}

// add_observer adds an object to the list of interested observers
pub fn (mut o Data<T>) add_observer(obs util.Observer) {
	o.observable.add_observer(obs)
}

// notify_update notifies observers of updates
pub fn (mut o Data<T>) notify_update() {
	o.observable.notify_update()
}
