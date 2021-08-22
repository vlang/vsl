module la

import vsl.blas
import math

/*
* vector_rms_error returns the scaled root-mean-square of the difference between two vectors
 * with components normalised by a scaling factor
 *                __________________________
 *               /     ————              2
 *              /  1   \    /  error[i]  \
 *   rms =  \  /  ———  /    | —————————— |
 *           \/    N   ———— \  scale[i]  /
 *
 *   error[i] = |u[i] - v[i]|
 *
 *   scale[i] = a + m*|s[i]|
*/
pub fn vector_rms_error(u []f64, v []f64, a f64, m f64, s []f64) f64 {
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
pub fn vector_dot(u []f64, v []f64) f64 {
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
	mut res := []f64{len: v.len}
	n := u.len
	cutoff := 150
	if beta == 1 && n > cutoff {
		res = v.clone()
		blas.daxpy(n, alpha, u, 1, mut res, 1)
		return res
	}
	m := n % 4
	for i in 0 .. m {
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
pub fn vector_max_diff(u []f64, v []f64) f64 {
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
pub fn vector_scale_abs(a f64, m f64, x []f64) []f64 {
	mut scale := []f64{len: x.len}
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
	mut v := []f64{len: a.m}
	if a.m < 9 && a.n < 9 {
		for i := 0; i < a.m; i++ {
			v[i] = 0.0
			for j := 0; j < a.n; j++ {
				v[i] += alpha * a.get(i, j) * u[j]
			}
		}
		return v
	}
	blas.dgemv(false, a.m, a.n, alpha, a.data, a.m, u, 1, 0.0, mut v, v.len)
	return v
}

// matrix_tr_vector_mul returns the transpose(matrix)-vector multiplication
//
// v = alpha⋅aᵀ⋅u    ⇒    vi = alpha * aji * uj = alpha * uj * aji
//
pub fn matrix_tr_vector_mul(alpha f64, a Matrix, u []f64) []f64 {
	mut v := []f64{len: a.n}
	if a.m < 9 && a.n < 9 {
		for i := 0; i < a.n; i++ {
			v[i] = 0.0
			for j := 0; j < a.m; j++ {
				v[i] += alpha * a.get(j, i) * u[j]
			}
		}
		return v
	}
	blas.dgemv(true, a.m, a.n, alpha, a.data, a.n, u, 1, 0.0, mut v, v.len)
	return v
}

// vector_vector_tr_mul returns the matrix = vector-transpose(vector) multiplication
// (e.g. dyadic product)
//
// a = alpha⋅u⋅vᵀ    ⇒    aij = alpha * ui * vj
//
pub fn vector_vector_tr_mul(alpha f64, u []f64, v []f64) &Matrix {
	mut m := new_matrix(u.len, v.len)
	if m.m < 9 && m.n < 9 {
		for i in 0 .. m.m {
			for j in 0 .. m.n {
				m.set(i, j, alpha * u[i] * v[j])
			}
		}
		return m
	}
	mut a := []f64{len: u.len * v.len}
	blas.dger(m.m, m.n, alpha, u, 1, v, 1, mut a, int(math.max(m.m, m.n)))
	return matrix_raw(u.len, v.len, a)
}

// matrix_vector_mul_add returns the matrix-vector multiplication with addition
//
// v += alpha⋅a⋅u    ⇒    vi += alpha * aij * uj
//
pub fn matrix_vector_mul_add(alpha f64, a Matrix, u []f64) []f64 {
	mut v := []f64{len: a.m}
	blas.dgemv(false, a.m, a.n, alpha, a.data, a.m, u, 1, 1.0, mut v, v.len)
	return v
}

// matrix_matrix_mul returns the matrix multiplication (scaled)
//
//  c := alpha⋅a⋅b    ⇒    cij := alpha * aik * bkj
//
pub fn matrix_matrix_mul(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	if c.m < 6 && c.n < 6 && a.n < 30 {
		for i := 0; i < c.m; i++ {
			for j := 0; j < c.n; j++ {
				c.set(i, j, 0.0)
				for k := 0; k < a.n; k++ {
					c.add(i, j, alpha * a.get(i, k) * b.get(k, j))
				}
			}
		}
		return
	}
	blas.dgemm(false, false, a.m, b.n, a.n, alpha, a.data, a.m, b.data, b.m, 0.0, mut
		c.data, c.m)
}

// matrix_tr_matrix_mul returns the matrix multiplication (scaled) with transposed(a)
//
//  c := alpha⋅aᵀ⋅b    ⇒    cij := alpha * aki * bkj
//
pub fn matrix_tr_matrix_mul(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	if c.m < 6 && c.n < 6 && a.m < 30 {
		for i := 0; i < c.m; i++ {
			for j := 0; j < c.n; j++ {
				c.set(i, j, 0.0)
				for k := 0; k < a.m; k++ {
					c.add(i, j, alpha * a.get(k, i) * b.get(k, j))
				}
			}
		}
		return
	}
	blas.dgemm(true, false, a.n, b.n, a.m, alpha, a.data, a.n, b.data, b.m, 0.0, mut c.data,
		c.m)
}

// matrix_matrix_tr_mul returns the matrix multiplication (scaled) with transposed(b)
//
//  c := alpha⋅a⋅bᵀ    ⇒    cij := alpha * aik * bjk
//
pub fn matrix_matrix_tr_mul(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	blas.dgemm(false, true, a.m, b.m, a.n, alpha, a.data, a.n, b.data, b.m, 0.0, mut c.data,
		c.m)
}

// matrix_tr_matrix_tr_mul returns the matrix multiplication (scaled) with transposed(a) and transposed(b)
//
//  c := alpha⋅aᵀ⋅bᵀ    ⇒    cij := alpha * aki * bjk
//
pub fn matrix_tr_matrix_tr_mul(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	blas.dgemm(true, true, a.n, b.m, a.m, alpha, a.data, a.n, b.data, b.m, 0.0, mut c.data,
		c.m)
}

// matrix_matrix_muladd returns the matrix multiplication (scaled)
//
//  c += alpha⋅a⋅b    ⇒    cij += alpha * aik * bkj
//
pub fn matrix_matrix_muladd(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	blas.dgemm(false, false, a.m, b.n, a.n, alpha, a.data, a.n, b.data, b.m, 1.0, mut
		c.data, c.m)
}

// matrix_tr_matrix_muladd returns the matrix multiplication (scaled) with transposed(a)
//
//  c += alpha⋅aᵀ⋅b    ⇒    cij += alpha * aki * bkj
//
pub fn matrix_tr_matrix_muladd(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	blas.dgemm(true, false, a.n, b.n, a.m, alpha, a.data, a.n, b.data, b.m, 1.0, mut c.data,
		c.m)
}

// matrix_matrix_tr_muladd returns the matrix multiplication (scaled) with transposed(b)
//
//  c += alpha⋅a⋅bᵀ    ⇒    cij += alpha * aik * bjk
//
pub fn matrix_matrix_tr_muladd(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	blas.dgemm(false, true, a.m, b.m, a.n, alpha, a.data, a.n, b.data, b.m, 1.0, mut c.data,
		c.m)
}

// matrix_tr_matrix_tr_mul_add returns the matrix multiplication (scaled) with transposed(a) and transposed(b)
//
//  c += alpha⋅aᵀ⋅bᵀ    ⇒    cij += alpha * aki * bjk
//
pub fn matrix_tr_matrix_tr_mul_add(mut c Matrix, alpha f64, a Matrix, b Matrix) {
	blas.dgemm(true, true, a.n, b.m, a.m, alpha, a.data, a.n, b.data, b.m, 1.0, mut c.data,
		c.m)
}

// matrix_add adds the scaled components of two matrices
//   res := alpha⋅a + beta⋅b   ⇒   result[i][j] := alpha⋅a[i][j] + beta⋅b[i][j]
pub fn matrix_add(mut res Matrix, alpha f64, a Matrix, beta f64, b Matrix) {
	n := a.data.len // treating these matrices as vectors
	cutoff := 150
	if beta == 1 && n > cutoff {
		res.data = b.data.clone()
		blas.daxpy(n, alpha, a.data, 1, mut res.data, 1)
		return
	}
	m := n % 4
	for i in 0 .. m {
		res.data[i] = alpha * a.data[i] + beta * b.data[i]
	}
	for i := m; i < n; i += 4 {
		res.data[i + 0] = alpha * a.data[i + 0] + beta * b.data[i + 0]
		res.data[i + 1] = alpha * a.data[i + 1] + beta * b.data[i + 1]
		res.data[i + 2] = alpha * a.data[i + 2] + beta * b.data[i + 2]
		res.data[i + 3] = alpha * a.data[i + 3] + beta * b.data[i + 3]
	}
	return
}
