module iter

import math
import vsl.errors

struct IntIter {
	start i64
	stop  i64
	step  i64
mut:
	i i64
pub:
	len i64
}

@[params]
pub struct IntIterParams {
pub:
	start i64
	stop  i64 @[required]
	step  i64 = 1
}

// IntIter.new returns an iterator of evenly spaced integers numbers in the half-open interval `[start, stop)`.
//----------
// parameters:
//	IntIterParams {
//	  -start i64 :           the start of the range.
//	  -stop  i64 [required]: the end of the range (exclusive).
//	  -step  i64 = 1:        the step between the numbers.
//}
pub fn IntIter.new(params IntIterParams) !IntIter {
	if params.step == 0 {
		return errors.error(@MOD + '.' + @FN + ': step cannot be 0', .erange)
	}

	mut len := i64((params.stop - params.start) / params.step) +
		i64((params.stop - params.start) % params.step != 0)
	if len < 0 {
		len = 0
	}

	return IntIter{
		start: params.start
		stop: params.stop
		step: params.step
		i: 0
		len: len
	}
}

// next returns the next element of the iterator if possible.
pub fn (mut r IntIter) next() ?i64 {
	if r.i == r.len {
		return none
	}
	defer {
		r.i++
	}
	return r.start + r.i * r.step
}

struct FloatIter {
	start f64
	stop  f64
	step  f64
mut:
	i f64
pub:
	len i64
}

@[params]
pub struct FloatIterParams {
pub:
	start f64
	stop  f64 @[required]
	step  f64 = 1.0
}

// FloatIter.new returns an iterator of evenly spaced floats in the half-open interval `[start, stop)`.
//----------
// parameters:
//	FloatIterParams {
//	 -start f64 :           the start of the range.
//	 -stop  f64 [required]: the end of the range (exclusive).
//	 -step  f64 = 1:        the step between the numbers.
//}
pub fn FloatIter.new(params FloatIterParams) !FloatIter {
	if params.step == 0 {
		return errors.error(@MOD + '.' + @FN + ': step cannot be 0', .erange)
	}
	mut len := int((params.stop - params.start) / params.step) +
		int(math.fmod((params.stop - params.start), params.step) != 0)
	if len < 0 {
		len = 0
	}
	return FloatIter{
		start: params.start
		stop: params.stop
		step: params.step
		i: 0
		len: len
	}
}

// next returns the next element of the iterator if possible.
pub fn (mut r FloatIter) next() ?f64 {
	if r.i == r.len {
		return none
	}
	defer {
		r.i++
	}
	return r.start + r.i * r.step
}

struct LinearIter {
	start    f64
	stop     f64
	endpoint bool
mut:
	i i64
pub:
	len  i64 = 50
	step f64
}

@[params]
pub struct LinearIterParams {
pub:
	start    f64 @[required]
	stop     f64 @[required]
	len      i64  = 50
	endpoint bool = true
}

// LinearIter.new returns an iterator of `len` evenly spaced floats in the interval `[start, stop]`.
// The endpoint of the interval can optionally be excluded.
//----------
// parameters:
//	LinearIterParams {
//	 -start    f64 :           The start of the range.
//	 -stop     f64 [required]: The end of the range.
//	 -len      i64  = 50:      Number of samples to generate. Must be non-negative.
//   -endpoint bool = true:    If true, `stop` is the last sample. Otherwise, it is not included.
//}
pub fn LinearIter.new(params LinearIterParams) !LinearIter {
	if params.len < 0 {
		return errors.error(@MOD + '.' + @FN + ': number of samples must be non negative',
			.erange)
	}
	mut step := f64(1)
	if params.endpoint {
		step = (params.stop - params.start) / (params.len - 1)
	} else {
		step = (params.stop - params.start) / params.len
	}
	return LinearIter{
		start: params.start
		stop: params.stop
		step: step
		len: params.len
		endpoint: params.endpoint
	}
}

// next returns the next element of the iterator if possible.
pub fn (mut o LinearIter) next() ?f64 {
	defer {
		o.i += 1
	}
	if o.i < o.len - 1 {
		return o.start + o.i * o.step
	} else if o.i == o.len - 1 {
		if o.endpoint {
			return o.stop
		} else {
			return o.start + o.i * o.step
		}
	} else {
		return none
	}
}

struct LogIter {
	base f64
pub:
	len i64
mut:
	linear_iter LinearIter
}

@[params]
pub struct LogIterParams {
	start    f64 @[required]
	stop     f64 @[required]
	len      i64  = 50
	base     f64  = 10.0
	endpoint bool = true
}

// LogIter.new returns an iterator of `len` numbers evenly spaced on a logarithmic scale.
// The sequence starts at `base ^ start` and ends in `base ^ stop` (if `endpoint` = true).
//-------
// parameters:
//  LogIterParams {
//   -start    f64 [required]: `base ^ start` is the starting value of the sequence.
//	 -stop     f64 [required]: `base ^ stop` is the final value of the sequence, unless endpoint is false. In that case, num + 1 values are spaced over the interval in log-space, of which all but the last (a sequence of length len) are returned.
//	 -len      i64  = 50:      Number of samples to generate.
//	 -base     f64  = 10.0:    The base of the log space.
//	 -endpoint bool = true:    If true, bas ^ stop is the last sample. Otherwise, it is not included.
//}
pub fn LogIter.new(params LogIterParams) !LogIter {
	if params.len < 0 {
		return errors.error(@MOD + '.' + @FN + ': number of samples must be non negative',
			.erange)
	}
	return LogIter{
		linear_iter: LinearIter.new(
			start: params.start
			stop: params.stop
			len: params.len
			endpoint: params.endpoint
		)!
		base: params.base
		len: params.len
	}
}

// next returns the next element of the iterator if possible.
pub fn (mut o LogIter) next() ?f64 {
	return math.pow(o.base, o.linear_iter.next()?)
}
