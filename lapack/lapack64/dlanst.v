module lapack64

import math

// dlanst computes the specified norm of a symmetric tridiagonal matrix A.
// The diagonal elements of A are stored in d and the off-diagonal elements
// are stored in e.
pub fn dlanst(norm MatrixNorm, n int, d []f64, e []f64) f64 {
	if norm != .max_row_sum && norm != .max_column_sum && norm != .frobenius && norm != .max_abs {
		panic(bad_norm)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if n == 0 {
		return 0.0
	}
	if d.len < n {
		panic(short_d)
	}
	if e.len < n - 1 {
		panic(short_e)
	}

	match norm {
		.max_abs {
			mut anorm := math.abs(d[n - 1])
			for i in 0 .. n - 1 {
				mut sum := math.abs(d[i])
				if anorm < sum || math.is_nan(sum) {
					anorm = sum
				}
				sum = math.abs(e[i])
				if anorm < sum || math.is_nan(sum) {
					anorm = sum
				}
			}
			return anorm
		}
		.max_row_sum, .max_column_sum {
			if n == 1 {
				return math.abs(d[0])
			}
			mut anorm := math.abs(d[0]) + math.abs(e[0])
			mut sum := math.abs(e[n - 2]) + math.abs(d[n - 1])
			if anorm < sum || math.is_nan(sum) {
				anorm = sum
			}
			for i in 1 .. n - 1 {
				sum = math.abs(d[i]) + math.abs(e[i]) + math.abs(e[i - 1])
				if anorm < sum || math.is_nan(sum) {
					anorm = sum
				}
			}
			return anorm
		}
		.frobenius {
			mut scale := 0.0
			mut sum := 1.0
			if n > 1 {
				scale, sum = dlassq(n - 1, e, 1, scale, sum)
				sum = 2 * sum
			}
			scale, sum = dlassq(n, d, 1, scale, sum)
			return scale * math.sqrt(sum)
		}
	}
}
