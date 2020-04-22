// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module la

import vsl.blas
import vsl.math

// vector_rms_error returns the scaled root-mean-square of the difference between two vectors
// with components normalised by a scaling factor
// __________________________
// /     ————              2
// /  1   \    /  error[i]  \
// rms =  \  /  ———  /    | —————————— |
// \/    N   ———— \  scale[i]  /
//
// error[i] = |u[i] - v[i]|
//
// scale[i] = a + m*|s[i]|
//
pub fn vector_rms_error(u, v []f64, a, m f64, s []f64) f64 {
	mut rms := 0.0
	for i := 0; i < u.len; i++ {
		scale := a + m * math.abs(s[i])
		err := math.abs(u[i] - v[i])
		rms += err * err / (scale * scale)
	}
	return math.sqrt(rms / f64(u.len))
}

// vector_dot returns the dot product between two vectors:
// s := u・v
pub fn vector_dot(u, v []f64) f64 {
	mut res := 0.0
	cutoff := 150
	if u.len <= cutoff {
		for i := 0; i < u.len; i++ {
			res += u[i] * v[i]
		}
		return res
	}
	return blas.ddot(u.len, u, 1, v, 1)
}

// vector_add adds the scaled components of two vectors
// res := alpha⋅u + beta⋅v   ⇒   result[i] := alpha⋅u[i] + beta⋅v[i]
pub fn vector_add(alpha f64, u []f64, beta f64, v []f64) []f64 {
	mut res := [0.0].repeat(v.len)
	n := u.len
	cutoff := 150
	if beta == 1 && n > cutoff {
		res = v.clone()
		blas.daxpy(n, alpha, u, 1, mut res, 1)
		return res
	}
	m := n % 4
	for i := 0; i < m; i++ {
		res[i] = alpha * u[i] + beta * v[i]
	}
	for i := m; i < n; i += 4 {
		res[i + 0] = alpha * u[i + 0] + beta * v[i + 0]
		res[i + 1] = alpha * u[i + 1] + beta * v[i + 1]
		res[i + 2] = alpha * u[i + 2] + beta * v[i + 2]
		res[i + 3] = alpha * u[i + 3] + beta * v[i + 3]
	}
	return res
}

// vector_max_diff returns the maximum absolute difference between two vectors
// maxdiff = max(|u - v|)
pub fn vector_max_diff(u, v []f64) f64 {
	mut maxdiff := math.abs(u[0] - v[0])
	for i := 1; i < u.len; i++ {
		diff := math.abs(u[i] - v[i])
		if diff > maxdiff {
			maxdiff = diff
		}
	}
	return maxdiff
}

// vector_scale_abs creates a "scale" vector using the absolute value of another vector
// scale := a + m ⋅ |x|     ⇒      scale[i] := a + m ⋅ |x[i]|
pub fn vector_scale_abs(a, m f64, x []f64) []f64 {
	mut scale := [0.0].repeat(x.len)
	for i := 0; i < x.len; i++ {
		scale[i] = a + m * math.abs(x[i])
	}
	return scale
}

// matrix_vector_mul returns the matrix-vector multiplication
//
// v = alpha⋅a⋅u    ⇒    vi = alpha * aij * uj
//
pub fn matrix_vector_mul(alpha f64, a Matrix, u []f64) []f64 {
	mut v := [0.0].repeat(a.m)
	if a.m < 9 && a.n < 9 {
		for i := 0; i < a.m; i++ {
			v[i] = 0.0
			for j := 0; j < a.n; j++ {
				v[i] += alpha * a.get(i, j) * u[j]
			}
		}
		return v
	}
	blas.dgemv(false, a.m, a.n, alpha, a.data, a.m, u, 1, 0.0, mut v, 1)
	return v
}

// matrix_tr_vector_mul returns the transpose(matrix)-vector multiplication
//
// v = alpha⋅aᵀ⋅u    ⇒    vi = alpha * aji * uj = alpha * uj * aji
//
pub fn matrix_tr_vector_mul(alpha f64, a Matrix, u []f64) []f64 {
	mut v := [0.0].repeat(a.n)
	if a.m < 9 && a.n < 9 {
		for i := 0; i < a.n; i++ {
			v[i] = 0.0
			for j := 0; j < a.m; j++ {
				v[i] += alpha * a.get(j, i) * u[j]
			}
		}
		return v
	}
	blas.dgemv(true, a.m, a.n, alpha, a.data, a.m, u, 1, 0.0, mut v, 1)
	return v
}

// vector_vector_tr_mul returns the matrix = vector-transpose(vector) multiplication
// (e.g. dyadic product)
//
// a = alpha⋅u⋅vᵀ    ⇒    aij = alpha * ui * vj
//
pub fn vector_vector_tr_mul(alpha f64, u, v []f64) Matrix {
	mut a := matrix(u.len, v.len)
	if a.m < 9 && a.n < 9 {
		for i := 0; i < a.m; i++ {
			for j := 0; j < a.n; j++ {
				a.set(i, j, alpha * u[i] * v[j])
			}
		}
		return a
	}
	blas.dger(a.m, a.n, alpha, u, 1, mut v, 1, a.data, int(math.max(a.m, a.n)))
	return a
}

// matrix_vector_mul_add returns the matrix-vector multiplication with addition
//
// v += alpha⋅a⋅u    ⇒    vi += alpha * aij * uj
//
pub fn matrix_vector_mul_add(alpha f64, a Matrix, u []f64) []f64 {
	mut v := [0.0].repeat(a.m)
	blas.dgemv(false, a.m, a.n, alpha, a.data, a.m, u, 1, 1.0, mut v, 1)
	return v
}
