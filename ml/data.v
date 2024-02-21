module ml

import math
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
@[heap]
pub struct Data[T] {
pub mut:
	observable  util.Observable = util.Observable{}
	nb_samples  int // number of data points (samples). number of rows in x and y
	nb_features int // number of features. number of columns in x
	x           &la.Matrix[T] = unsafe { nil } // [nb_samples][nb_features] x values
	y           []T           // [nb_samples] y values [optional]
}

// Data.new returns a new object to hold ML data
// Input:
// nb_samples  -- number of data samples (rows in x)
// nb_features -- number of features (columns in x)
// use_y       -- use y data vector
// allocate    -- allocates x (and y); otherwise,
// x and y must be set using set() method
// Output:
// new object
pub fn Data.new[T](nb_samples int, nb_features int, use_y bool, allocate bool) !&Data[T] {
	x := if allocate {
		la.Matrix.new[T](nb_samples, nb_features)
	} else {
		&la.Matrix[T](unsafe { nil })
	}
	mut y := []T{}
	if allocate && use_y {
		y = []T{len: nb_samples}
	}
	return &Data[T]{
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
pub fn (mut o Data[T]) set(x &la.Matrix[T], y []T) ! {
	if y.len < o.nb_samples || x.n < o.nb_features || x.m < o.nb_samples {
		return errors.error('x matrix must have same dimensions as number of samples and features',
			.efailed)
	}
	o.x = x
	o.y = y
	o.observable.notify_update()
}

pub fn (mut o Data[T]) set_y(y []T) ! {
	if y.len < o.nb_samples {
		return errors.error('y vector must have same length as number of samples', .efailed)
	}
	o.y = y
	o.observable.notify_update()
}

pub fn (mut o Data[T]) set_x(x &la.Matrix[T]) ! {
	if x.n < o.nb_samples || x.m < o.nb_features {
		return errors.error('x matrix must have same dimensions as number of samples and features',
			.efailed)
	}
	o.x = x
	o.observable.notify_update()
}

// Data.from_raw_x returns a new object with data set from raw x values
// Input:
// xraw -- [nb_samples][nb_features] table with x values (NO y values)
// Output:
// new object
pub fn Data.from_raw_x[T](xraw [][]T) !&Data[T] {
	// check
	nb_samples := xraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xraw[0].len
	mut o := Data.new[T](nb_samples, nb_features, true, true)!
	// copy data from raw table to x matrix
	for i := 0; i < nb_samples; i++ {
		for j := 0; j < nb_features; j++ {
			o.x.set(i, j, xraw[i][j])
		}
	}
	return o
}

// Data.from_raw_xy_sep accepts two parameters: xraw [][]T and
// yraw []T. It acts similarly to Data.from_raw_xy, but instead
// of using the last column of xraw as the y data, it uses yraw
// instead.
pub fn Data.from_raw_xy_sep[T](xraw [][]T, yraw []T) !&Data[T] {
	// check
	nb_samples := xraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xraw[0].len
	mut o := Data.new[T](nb_samples, nb_features, false, true)!
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

// Data.from_raw_xy returns a new object with data set from raw Xy values
// Input:
// Xyraw -- [nb_samples][nb_features+1] table with x and y raw values,
// where the last column contains y-values
// Output:
// new object
pub fn Data.from_raw_xy[T](xyraw [][]T) !&Data[T] {
	// check
	nb_samples := xyraw.len
	if nb_samples < 1 {
		return errors.error('at least one row of data in table must be provided', .efailed)
	}
	// allocate new object
	nb_features := xyraw[0].len - 1 // -1 because of y column
	mut o := Data.new[T](nb_samples, nb_features, true, true)!
	// copy data from raw table to x and y arrays
	for i := 0; i < nb_samples; i++ {
		for j := 0; j < nb_features; j++ {
			o.x.set(i, j, xyraw[i][j])
		}
		o.y[i] = xyraw[i][nb_features]
	}
	return o
}

// clone returns a deep copy of this object removing the observers
pub fn (o &Data[T]) clone() !&Data[T] {
	use_y := o.y.len > 0
	mut p := Data.new[T](o.nb_samples, o.nb_features, use_y, true)!
	o.x.copy_into(mut p.x, 1)
	if use_y {
		p.y = o.y.clone()
	}
	return p
}

// clone_with_same_x returns a deep copy of this object, but with the same reference to x removing the observers
pub fn (o &Data[T]) clone_with_same_x() !&Data[T] {
	use_y := o.y.len > 0
	return &Data[T]{
		x: o.x
		y: if use_y { o.y.clone() } else { []T{} }
		nb_samples: o.nb_samples
		nb_features: o.nb_features
	}
}

// add_observer adds an object to the list of interested observers
pub fn (mut o Data[T]) add_observer(obs util.Observer) {
	o.observable.add_observer(obs)
}

// notify_update notifies observers of updates
pub fn (mut o Data[T]) notify_update() {
	o.observable.notify_update()
}

// split returns a new object with data split into two parts
// Input:
// ratio -- ratio of samples to be put in the first part
// Output:
// new object
pub fn (o &Data[T]) split(ratio f64) !(&Data[T], &Data[T]) {
	if ratio <= 0.0 || ratio >= 1.0 {
		return errors.error('ratio must be between 0 and 1', .efailed)
	}
	nb_features := o.nb_features
	nb_samples := o.nb_samples

	nb_samples1 := int(math.floor((ratio * nb_samples)))
	nb_samples2 := nb_samples - nb_samples1

	m1, m2 := o.x.split_by_row(nb_samples1)!

	mut o1 := Data.new[T](nb_samples1, nb_features, false, false)!
	mut o2 := Data.new[T](nb_samples2, nb_features, false, false)!

	o1.set(m1, o.y[..nb_samples1])!
	o2.set(m2, o.y[nb_samples1..])!

	return o1, o2
}
