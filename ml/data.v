module ml

import vsl.util
import vsl.la
import vsl.errors

/*
* Data holds data in matrix format; e.g. for regression computations
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
pub struct Data {
	util.Observable
pub mut:
	nb_samples  int        // number of data points (samples). number of rows in x and y
	nb_features int        // number of features. number of columns in x
	x           &la.Matrix // [nb_samples][nb_features] x values
	y           []f64      // [nb_samples] y values [optional]
}

// data returns a new object to hold ML data
// Input:
// nb_samples  -- number of data samples (rows in x)
// nb_features -- number of features (columns in x)
// use_y       -- use y data vector
// allocate    -- allocates x (and y); otherwise,
// x and y must be set using set() method
// Output:
// new object
pub fn new_data(nb_samples int, nb_features int, use_y bool, allocate bool) ?&Data {
	x := if allocate { la.new_matrix(nb_samples, nb_features) } else { la.new_matrix(0, 0) }
	mut y := []f64{}
	if allocate && use_y {
		y = []f64{len: nb_samples}
	}
	return &Data{
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
pub fn (mut o Data) set(x &la.Matrix, y []f64) {
	o.x = x
	o.y = y
	o.notify_update()
}

// data_from_raw_x returns a new object with data set from raw x values
// Input:
// xraw -- [nb_samples][nb_features] table with x values (NO y values)
// Output:
// new object
pub fn data_from_raw_x(xraw [][]f64) ?&Data {
	// check
	nb_samples := xraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xraw[0].len
	mut o := new_data(nb_samples, nb_features, true, true) ?
	// copy data from raw table to x matrix
	for i := 0; i < nb_samples; i++ {
		for j := 0; j < nb_features; j++ {
			o.x.set(i, j, xraw[i][j])
		}
	}
	return o
}

// data_from_raw_xy_sep accepts two parameters: xraw [][]f64 and
// yraw []f64. It acts similarly to data_from_raw_xy, but instead
// of using the last column of xraw as the y data, it uses yraw
// instead.
pub fn data_from_raw_xy_sep(xraw [][]f64, yraw []f64) ?&Data {
	// check
	nb_samples := xraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xraw[0].len
	mut o := new_data(nb_samples, nb_features, false, true) ?
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
pub fn data_from_raw_xy(xyraw [][]f64) ?&Data {
	// check
	nb_samples := xyraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xyraw[0].len - 1 // -1 because of y column
	mut o := new_data(nb_samples, nb_features, true, true) ?
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
pub fn (o &Data) clone() ?&Data {
	use_y := o.y.len > 0
	mut p := new_data(o.nb_samples, o.nb_features, use_y, true) ?
	o.x.copy_into(mut p.x, 1)
	if use_y {
		p.y = o.y.clone()
	}
	return p
}
