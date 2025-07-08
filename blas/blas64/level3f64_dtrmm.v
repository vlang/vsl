module blas64

import vsl.float.float64
import math

// dtrmm performs one of the matrix-matrix operations
//  B = alpha * A * B   if side == .left and trans_a == .no_trans
//  B = alpha * Aᵀ * B  if side == .left and trans_a == .trans or .conj_trans
//  B = alpha * B * A   if side == .right and trans_a == .no_trans
//  B = alpha * B * Aᵀ  if side == .right and trans_a == .trans or .conj_trans
// where A is an n×n or m×m triangular matrix, B is an m×n matrix, and alpha is a scalar.
pub fn dtrmm(side Side, ul Uplo, trans_a Transpose, d Diagonal, m int, n int, alpha f64, a []f64, lda int, mut b []f64, ldb int) {
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
	if ldb < math.max(1, m) {
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
	if b.len < ldb * (n - 1) + m {
		panic(short_b)
	}

	if alpha == 0 {
		for i in 0 .. m {
			mut btmp := unsafe { b[i * ldb..i * ldb + n] }
			for j in 0 .. btmp.len {
				btmp[j] = 0
			}
		}
		return
	}

	non_unit := d == .non_unit
	if side == .left {
		if trans_a == .no_trans {
			if ul == .upper {
				for i in 0 .. m {
					mut tmp := alpha
					if non_unit {
						tmp *= a[i * lda + i]
					}
					mut btmp := unsafe { b[i * ldb..i * ldb + n] }
					float64.scal_unitary(tmp, mut btmp)
					// Add contributions from upper triangular part: a[i*lda+i+1 : i*lda+m]
					for ka in 0 .. m - i - 1 {
						k_idx := ka + i + 1
						va := a[i * lda + k_idx] // A[i,k] where k > i
						if va != 0 {
							float64.axpy_unitary(alpha * va, b[k_idx * ldb..k_idx * ldb + n], mut
								btmp)
						}
					}
				}
				return
			}
			for i := m - 1; i >= 0; i-- {
				mut tmp := alpha
				if non_unit {
					tmp *= a[i * lda + i]
				}
				mut btmp := unsafe { b[i * ldb..i * ldb + n] }
				float64.scal_unitary(tmp, mut btmp)
				// Add contributions from lower triangular part: a[i*lda : i*lda+i]
				for k_idx in 0 .. i {
					va := a[i * lda + k_idx] // A[i,k] where k < i
					if va != 0 {
						float64.axpy_unitary(alpha * va, b[k_idx * ldb..k_idx * ldb + n], mut
							btmp)
					}
				}
			}
			return
		}
		// Cases where a is transposed.
		if ul == .upper {
			for k_val := m - 1; k_val >= 0; k_val-- {
				mut btmpk := unsafe { b[k_val * ldb..k_val * ldb + n] }
				// For transpose upper triangular, access A^T[k,i] = A[i,k] where i > k using column-major: a[k * lda + i]
				for i in k_val + 1 .. m {
					va := a[k_val * lda + i]
					if va != 0 {
						float64.axpy_unitary(alpha * va, btmpk, mut b[i * ldb..i * ldb + n])
					}
				}
				tmp := if non_unit { alpha * a[k_val * lda + k_val] } else { alpha }
				if tmp != 1 {
					float64.scal_unitary(tmp, mut btmpk)
				}
			}
			return
		}
		for k_val in 0 .. m {
			mut btmpk := unsafe { b[k_val * ldb..k_val * ldb + n] }
			// For transpose lower triangular, access A^T[k,i] = A[i,k] where i < k using column-major: a[k * lda + i]
			for i in 0 .. k_val {
				va := a[k_val * lda + i]
				if va != 0 {
					float64.axpy_unitary(alpha * va, btmpk, mut b[i * ldb..i * ldb + n])
				}
			}
			tmp := if non_unit { alpha * a[k_val * lda + k_val] } else { alpha }
			if tmp != 1 {
				float64.scal_unitary(tmp, mut btmpk)
			}
		}
		return
	}
	// Cases where a is on the right
	if trans_a == .no_trans {
		if ul == .upper {
			for i in 0 .. m {
				mut btmp := unsafe { b[i * ldb..i * ldb + n] }
				for k_idx := n - 1; k_idx >= 0; k_idx-- {
					tmp := alpha * btmp[k_idx]
					if tmp == 0 {
						continue
					}
					btmp[k_idx] = tmp
					if non_unit {
						btmp[k_idx] *= a[k_idx * lda + k_idx]
					}
					// For right-side upper triangular, access A[k,j] where j > k using column-major: a[j * lda + k]
					for j in k_idx + 1 .. n {
						va := a[j * lda + k_idx]
						btmp[j] += tmp * va
					}
				}
			}
			return
		}
		for i in 0 .. m {
			mut btmp := unsafe { b[i * ldb..i * ldb + n] }
			for k_idx in 0 .. n {
				tmp := alpha * btmp[k_idx]
				if tmp == 0 {
					continue
				}
				btmp[k_idx] = tmp
				if non_unit {
					btmp[k_idx] *= a[k_idx * lda + k_idx]
				}
				// For right-side lower triangular, access A[k,j] where j < k using column-major: a[j * lda + k]
				for j in 0 .. k_idx {
					va := a[j * lda + k_idx]
					btmp[j] += tmp * va
				}
			}
		}
		return
	}
	// Cases where a is transposed.
	if ul == .upper {
		for i in 0 .. m {
			mut btmp := unsafe { b[i * ldb..i * ldb + n] }
			for j, vb in btmp {
				mut tmp := vb
				if non_unit {
					tmp *= a[j * lda + j]
				}
				// For transpose upper triangular, access A^T[j,k] = A[k,j] where k > j using column-major: a[j * lda + k]
				for col in j + 1 .. n {
					va := a[j * lda + col]
					tmp += va * btmp[col]
				}
				btmp[j] = alpha * tmp
			}
		}
		return
	}
	for i in 0 .. m {
		mut btmp := unsafe { b[i * ldb..i * ldb + n] }
		for j := n - 1; j >= 0; j-- {
			mut tmp := btmp[j]
			if non_unit {
				tmp *= a[j * lda + j]
			}
			// For transpose lower triangular, access A^T[j,k] = A[k,j] where k < j using column-major: a[j * lda + k]
			for col in 0 .. j {
				va := a[j * lda + col]
				tmp += va * btmp[col]
			}
			btmp[j] = alpha * tmp
		}
	}
}
