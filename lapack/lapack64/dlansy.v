module lapack64

import math
import vsl.blas

// dlansy returns the value of the specified norm of an n×n symmetric matrix.
// If norm == MatrixNorm.max_column_sum or norm == MatrixNorm.max_row_sum, work must have length
// at least n, otherwise work is unused.
pub fn dlansy(norm MatrixNorm, uplo blas.Uplo, n int, a []f64, lda int, mut work []f64) f64 {
	if norm != .max_row_sum && norm != .max_column_sum && norm != .frobenius && norm != .max_abs {
		panic(lapack64.bad_norm)
	}
	if uplo != .upper && uplo != .lower {
		panic(lapack64.bad_uplo)
	}
	if n < 0 {
		panic('lapack: n < 0')
	}
	if lda < math.max(1, n) {
		panic(lapack64.bad_ld_a)
	}

	// Quick return if possible.
	if n == 0 {
		return 0.0
	}

	if a.len < (n-1) * lda + n {
		panic(lapack64.short_a)
	}
	if (norm == .max_column_sum || norm == .max_row_sum) && work.len < n {
		panic(lapack64.short_work)
	}

	match norm {
		.max_abs {
			if uplo == .upper {
				mut max := 0.0
				for i in 0 .. n {
					for j in i .. n {
						v := math.abs(a[i * lda + j])
						if math.is_nan(v) {
							return math.nan()
						}
						if v > max {
							max = v
						}
					}
				}
				return max
			}
			mut max := 0.0
			for i in 0 .. n {
				for j in 0 .. i + 1 {
					v := math.abs(a[i * lda + j])
					if math.is_nan(v) {
						return math.nan()
					}
					if v > max {
						max = v
					}
				}
			}
			return max
		}
		.max_row_sum, .max_column_sum {
			// A symmetric matrix has the same 1-norm and ∞-norm.
			for i in 0 .. n {
				work[i] = 0.0
			}
			if uplo == .upper {
				for i in 0 .. n {
					work[i] += math.abs(a[i * lda + i])
					for j in i + 1 .. n {
						v := math.abs(a[i * lda + j])
						work[i] += v
						work[j] += v
					}
				}
			} else {
				for i in 0 .. n {
					for j in 0 .. i {
						v := math.abs(a[i * lda + j])
						work[i] += v
						work[j] += v
					}
					work[i] += math.abs(a[i * lda + i])
				}
			}
			mut max := 0.0
			for i in 0 .. n {
				v := work[i]
				if math.is_nan(v) {
					return math.nan()
				}
				if v > max {
					max = v
				}
			}
			return max
		}
		else {
			// blas.frobenius:
			mut scale := 0.0
			mut sum := 1.0
			// Sum off-diagonals.
			if uplo == .upper {
				for i in 0 .. n - 1 {
					scale, sum = dlassq(n - i - 1, a[i * lda + i + 1..], 1, scale, sum)
				}
			} else {
				for i in 1 .. n {
					scale, sum = dlassq(i, a[i * lda..], 1, scale, sum)
				}
			}
			sum *= 2.0
			// Sum diagonal.
			scale, sum = dlassq(n, a, lda + 1, scale, sum)
			return scale * math.sqrt(sum)
		}
	}
}
