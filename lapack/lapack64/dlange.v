module lapack64

import math

// dlange returns the value of the specified norm of a general m×n matrix A:
//
//	MatrixNorm.max_abs:       the maximum absolute value of any element.
//	MatrixNorm.max_column_sum: the maximum column sum of the absolute values of the elements (1-norm).
//	MatrixNorm.max_row_sum:    the maximum row sum of the absolute values of the elements (infinity-norm).
//	MatrixNorm.frobenius:    the square root of the sum of the squares of the elements (Frobenius norm).
//
// If norm == MatrixNorm.max_column_sum, work must be of length n, and this function will
// panic otherwise. There are no restrictions on work for the other matrix norms.
pub fn dlange(norm MatrixNorm, m int, n int, a []f64, lda int, mut work []f64) f64 {
	if norm != .max_row_sum && norm != .max_column_sum && norm != .frobenius && norm != .max_abs {
		panic(bad_norm)
	}
	if m < 0 {
		panic(m_lt0)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	// Quick return if possible.
	if m == 0 || n == 0 {
		return 0.0
	}

	if a.len < (m - 1) * lda + n {
		panic(bad_ld_a)
	}
	if norm == .max_column_sum && work.len < n {
		panic(short_work)
	}

	match norm {
		.max_abs {
			mut value := 0.0
			for i in 0 .. m {
				for j in 0 .. n {
					value = math.max(value, math.abs(a[i * lda + j]))
				}
			}
			return value
		}
		.max_column_sum {
			for i in 0 .. n {
				work[i] = 0.0
			}
			for i in 0 .. m {
				for j in 0 .. n {
					work[j] += math.abs(a[i * lda + j])
				}
			}
			mut value := 0.0
			for i in 0 .. n {
				value = math.max(value, work[i])
			}
			return value
		}
		.max_row_sum {
			mut value := 0.0
			for i in 0 .. m {
				mut sum := 0.0
				for j in 0 .. n {
					sum += math.abs(a[i * lda + j])
				}
				value = math.max(value, sum)
			}
			return value
		}
		.frobenius {
			mut scale := 0.0
			mut sum := 1.0
			for i in 0 .. m {
				scale, sum = dlassq(n, a[i * lda..], 1, scale, sum)
			}
			return scale * math.sqrt(sum)
		}
	}
}
