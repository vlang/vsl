// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module la

import vsl.math

pub type VectorApplyFn = fn (i int, x f64) f64

// apply sets this []f64 with the scaled components of another []f64
// this := a * another   ⇒   this[i] := a * another[i]
// NOTE: "another" may be "this"
pub fn vector_apply(mut o []f64, a f64, another []f64) {
	for i := 0; i < o.len; i++ {
		o[i] = a * another[i]
	}
}

// apply_func runs a function over all components of a []f64
// vi = f(i,vi)
pub fn vector_apply_func(mut o []f64, f VectorApplyFn) {
	for i := 0; i < o.len; i++ {
		o[i] = f(i, o[i])
	}
}

// unit returns the unit []f64 parallel to this []f64
// b := a / norm(a)
pub fn vector_unit(mut o []f64) []f64 {
	mut unit := []f64{len: o.len}
	s := vector_norm(o)
	if s > 0 {
		vector_apply(mut unit, 1.0 / s, o)
	}
	return unit
}

// accum sum/accumulates all components in a []f64
// sum := Σ_i v[i]
pub fn vector_accum(o []f64) f64 {
	mut sum := 0.0
	for i := 0; i < o.len; i++ {
		sum += o[i]
	}
	return sum
}

// norm returns the Euclidean norm of a []f64:
// nrm := ‖v‖
pub fn vector_norm(o []f64) f64 {
	return math.sqrt(vector_dot(o, o))
}

// rms returns the root-mean-square of this []f64
//
pub fn vector_rms(o []f64) f64 {
	mut rms := 0.0
	for i := 0; i < o.len; i++ {
		rms += o[i] * o[i]
	}
	rms = math.sqrt(rms / f64(o.len))
	return rms
}

// norm_diff returns the Euclidean norm of the difference:
// nrm := ||u - v||
pub fn vector_norm_diff(o, v []f64) f64 {
	mut nrm := 0.0
	for i := 0; i < v.len; i++ {
		nrm += (o[i] - v[i]) * (o[i] - v[i])
	}
	nrm = math.sqrt(nrm)
	return nrm
}

// largest returns the largest component |u[i]| of this []f64, normalised by den
// largest := |u[i]| / den
pub fn vector_largest(o []f64, den f64) f64 {
	mut largest := math.abs(o[0])
	for i := 1; i < o.len; i++ {
		tmp := math.abs(o[i])
		if tmp > largest {
			largest = tmp
		}
	}
	return largest / den
}
