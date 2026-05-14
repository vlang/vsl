module la

import math
import vsl.errors

// vector_apply sets this []T with the scaled components of another []T
// this := a * another   ⇒   this[i] := a * another[i]
// NOTE: "another" may be "this"
pub fn vector_apply[T](mut o []T, a T, another []T) {
	for i in 0 .. o.len {
		o[i] = a * another[i]
	}
}

// vector_apply_func runs a function over all components of a []T
// vi = f(i,vi)
pub fn vector_apply_func[T](mut o []T, f fn (i int, x T) T) {
	for i in 0 .. o.len {
		o[i] = f(i, o[i])
	}
}

// vector_unit returns the unit []f64 parallel to this []f64
// b := a / norm(a)
pub fn vector_unit(mut o []f64) []f64 {
	mut unit := []f64{len: o.len}
	s := vector_norm(o)
	if s > 0 {
		vector_apply(mut unit, 1.0 / s, o)
	}
	return unit
}

// vector_accum sum/accumulates all components in a []T
// sum := Σ_i v[i]
pub fn vector_accum[T](o []T) T {
	mut sum := T{}
	for i in 0 .. o.len {
		sum += o[i]
	}
	return sum
}

// vector_norm returns the Euclidean norm of a []T:
// nrm := ‖v‖
pub fn vector_norm(o []f64) f64 {
	return math.sqrt(vector_dot(o, o))
}

// vector_rms returns the root-mean-square of this []T
//
pub fn vector_rms[T](o []T) T {
	mut rms := T{}
	for i in 0 .. o.len {
		rms += o[i] * o[i]
	}
	rms = T(math.sqrt(f64(rms / T(o.len))))
	return rms
}

// vector_norm_diff returns the Euclidean norm of the difference:
// nrm := ||u - v||
pub fn vector_norm_diff[T](o []T, v []T) T {
	mut nrm := T{}
	for i in 0 .. v.len {
		nrm += (o[i] - v[i]) * (o[i] - v[i])
	}
	nrm = T(math.sqrt(f64(nrm)))
	return nrm
}

// vector_largest returns the largest component |u[i]| of this []T, normalised by den
// largest := |u[i]| / den
pub fn vector_largest[T](o []T, den T) T {
	mut largest := math.abs(o[0])
	for i := 1; i < o.len; i++ {
		tmp := math.abs(o[i])
		if tmp > largest {
			largest = tmp
		}
	}
	return largest / den
}

// vector_cosine_similarity calculates the cosine similarity between two vectors
pub fn vector_cosine_similarity(a []f64, b []f64) f64 {
	if a.len != b.len {
		errors.vsl_panic('Vectors must have the same length', .efailed)
	}

	dot_product := vector_dot(a, b)
	norm_a := vector_norm(a)
	norm_b := vector_norm(b)

	if norm_a == 0 || norm_b == 0 {
		return 0
	}

	return dot_product / (norm_a * norm_b)
}
