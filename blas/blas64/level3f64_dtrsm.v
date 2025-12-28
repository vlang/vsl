module blas64

import math

// dtrsm solves one of the matrix equations
//  A * X = alpha * B   if trans_a == .no_trans and side == .left
//  Aᵀ * X = alpha * B  if trans_a == .trans or .conj_trans, and side == .left
//  X * A = alpha * B   if trans_a == .no_trans and side == .right
//  X * Aᵀ = alpha * B  if trans_a == .trans or .conj_trans, and side == .right
// where A is an n×n or m×m triangular matrix, X and B are m×n matrices, and alpha is a
// scalar.
//
// At entry to the function, X contains the values of B, and the result is
// stored in-place into X.
//
// No check is made that A is invertible.
pub fn dtrsm(side Side, ul Uplo, trans_a Transpose, d Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
	if side != .left && side != .right {
		panic(bad_side)
	}
	if ul != .lower && ul != .upper {
		panic(bad_uplo)
	}
	if trans_a != .no_trans && trans_a != .trans && trans_a != .conj_trans {
		panic(bad_transpose)
	}
	if d != .non_unit && d != .unit {
		panic(bad_diag)
	}
	if m < 0 {
		panic(mlt0)
	}
	if n < 0 {
		panic(nlt0)
	}
	mut k := n
	if side == .left {
		k = m
	}
	if lda < math.max(1, k) {
		panic(bad_ld_a)
	}
	if ldb < math.max(1, n) {
		panic(bad_ld_b)
	}

	// Quick return if possible.
	if m == 0 || n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a.len < lda * (k - 1) + k {
		panic(short_a)
	}
	if b.len < ldb * (m - 1) + n {
		panic(short_b)
	}

	if alpha == 0 {
		for i in 0 .. m {
			for j in 0 .. n {
				b[i + j * ldb] = 0
			}
		}
		return
	}
	non_unit := d == .non_unit
	if side == .left {
		if trans_a == .no_trans {
			if ul == .upper {
				for i := m - 1; i >= 0; i-- {
					// Scale row i by alpha
					if alpha != 1 {
						for j in 0 .. n {
							b[i + j * ldb] *= alpha
						}
					}
					// For upper triangular in column-major: access A[i,k] for k > i
					// A[i,k] is stored at a[i + k * lda] in column-major format
					for k_idx in i + 1 .. m {
						va := a[i + k_idx * lda]
						if va != 0 {
							// Subtract va * row k from row i
							for j in 0 .. n {
								b[i + j * ldb] -= va * b[k_idx + j * ldb]
							}
						}
					}
					if non_unit {
						tmp := 1.0 / a[i + i * lda] // A[i,i] in column-major
						for j in 0 .. n {
							b[i + j * ldb] *= tmp
						}
					}
				}
				return
			}
			for i in 0 .. m {
				// Scale row i by alpha
				if alpha != 1 {
					for j in 0 .. n {
						b[i + j * ldb] *= alpha
					}
				}
				// For lower triangular in column-major: access A[i,k] for k < i
				// A[i,k] is stored at a[i + k * lda] in column-major format
				for k_idx in 0 .. i {
					va := a[i + k_idx * lda]
					if va != 0 {
						// Subtract va * row k from row i
						for j in 0 .. n {
							b[i + j * ldb] -= va * b[k_idx + j * ldb]
						}
					}
				}
				if non_unit {
					tmp := 1.0 / a[i + i * lda] // A[i,i] in column-major
					for j in 0 .. n {
						b[i + j * ldb] *= tmp
					}
				}
			}
			return
		}
		// Cases where a is transposed
		if ul == .upper {
			for k_val in 0 .. m {
				if non_unit {
					tmp := 1.0 / a[k_val + k_val * lda] // A[k,k] in column-major
					for j in 0 .. n {
						b[k_val + j * ldb] *= tmp
					}
				}
				// For upper triangular transpose: access A[k,i] for i > k (which becomes A[i,k] in the operation)
				for i_idx in k_val + 1 .. m {
					va := a[k_val + i_idx * lda] // A[k,i] in column-major
					if va != 0 {
						// Subtract va * row k from row i
						for j in 0 .. n {
							b[i_idx + j * ldb] -= va * b[k_val + j * ldb]
						}
					}
				}
				if alpha != 1 {
					for j in 0 .. n {
						b[k_val + j * ldb] *= alpha
					}
				}
			}
			return
		}
		for k_val := m - 1; k_val >= 0; k_val-- {
			if non_unit {
				tmp := 1.0 / a[k_val + k_val * lda] // A[k,k] in column-major
				for j in 0 .. n {
					b[k_val + j * ldb] *= tmp
				}
			}
			// For lower triangular transpose: access A[k,i] for i < k
			for i_idx in 0 .. k_val {
				va := a[k_val + i_idx * lda] // A[k,i] in column-major
				if va != 0 {
					// Subtract va * row k from row i
					for j in 0 .. n {
						b[i_idx + j * ldb] -= va * b[k_val + j * ldb]
					}
				}
			}
			if alpha != 1 {
				for j in 0 .. n {
					b[k_val + j * ldb] *= alpha
				}
			}
		}
		return
	}
	// Cases where a is to the right of X.
	if trans_a == .no_trans {
		if ul == .upper {
			for i in 0 .. m {
				// Scale row i by alpha
				if alpha != 1 {
					for j in 0 .. n {
						b[i + j * ldb] *= alpha
					}
				}
				for k_idx in 0 .. n {
					if b[i + k_idx * ldb] == 0 {
						continue
					}
					if non_unit {
						b[i + k_idx * ldb] /= a[k_idx + k_idx * lda] // A[k,k] in column-major
					}
					// For upper triangular: access A[k,j] for j > k
					for j_idx in k_idx + 1 .. n {
						va := a[k_idx + j_idx * lda] // A[k,j] in column-major
						b[i + j_idx * ldb] -= b[i + k_idx * ldb] * va
					}
				}
			}
			return
		}
		for i in 0 .. m {
			// Scale row i by alpha
			if alpha != 1 {
				for j in 0 .. n {
					b[i + j * ldb] *= alpha
				}
			}
			for k_idx := n - 1; k_idx >= 0; k_idx-- {
				if b[i + k_idx * ldb] == 0 {
					continue
				}
				if non_unit {
					b[i + k_idx * ldb] /= a[k_idx + k_idx * lda] // A[k,k] in column-major
				}
				// For lower triangular: access A[k,j] for j < k
				for j_idx in 0 .. k_idx {
					va := a[k_idx + j_idx * lda] // A[k,j] in column-major
					b[i + j_idx * ldb] -= b[i + k_idx * ldb] * va
				}
			}
		}
		return
	}
	// Cases where a is transposed.
	if ul == .upper {
		for i in 0 .. m {
			for j_idx := n - 1; j_idx >= 0; j_idx-- {
				mut dot_product := 0.0
				// For upper triangular transpose: compute dot product with A[j,k] for k > j
				for k_idx in j_idx + 1 .. n {
					dot_product += a[j_idx + k_idx * lda] * b[i + k_idx * ldb] // A[j,k] in column-major
				}
				mut tmp := alpha * b[i + j_idx * ldb] - dot_product
				if non_unit {
					tmp /= a[j_idx + j_idx * lda] // A[j,j] in column-major
				}
				b[i + j_idx * ldb] = tmp
			}
		}
		return
	}
	for i in 0 .. m {
		for j_idx in 0 .. n {
			mut dot_product := 0.0
			// For lower triangular transpose: compute dot product with A[j,k] for k < j
			for k_idx in 0 .. j_idx {
				dot_product += a[j_idx + k_idx * lda] * b[i + k_idx * ldb] // A[j,k] in column-major
			}
			mut tmp := alpha * b[i + j_idx * ldb] - dot_product
			if non_unit {
				tmp /= a[j_idx + j_idx * lda] // A[j,j] in column-major
			}
			b[i + j_idx * ldb] = tmp
		}
	}
}
