module lapack64

import math
import vsl.blas

// dgebal balances an n×n matrix A. Balancing consists of two stages, permuting
// and scaling. Both steps are optional and depend on the value of job.
//
// Permuting consists of applying a permutation matrix P such that the matrix
// that results from Pᵀ*A*P takes the upper block triangular form
//
//	         [ T1  X  Y  ]
//	Pᵀ A P = [  0  B  Z  ],
//	         [  0  0  T2 ]
//
// where T1 and T2 are upper triangular matrices and B contains at least one
// nonzero off-diagonal element in each row and column. The indices ilo and ihi
// mark the starting and ending columns of the submatrix B. The eigenvalues of A
// isolated in the first 0 to ilo-1 and last ihi+1 to n-1 elements on the
// diagonal can be read off without any roundoff error.
//
// Scaling consists of applying a diagonal similarity transformation D such that
// D^{-1}*B*D has the 1-norm of each row and its corresponding column nearly
// equal. The output matrix is
//
//	[ T1     X*D          Y    ]
//	[  0  inv(D)*B*D  inv(D)*Z ].
//	[  0      0           T2   ]
//
// Scaling may reduce the 1-norm of the matrix, and improve the accuracy of
// the computed eigenvalues and/or eigenvectors.
//
// job specifies the operations that will be performed on A.
// If job is BalanceJob.balance_none, dgebal sets scale[i] = 1 for all i and returns 0.
// If job is BalanceJob.permute, only permuting will be done.
// If job is BalanceJob.scale, only scaling will be done.
// If job is BalanceJob.permute_scale, both permuting and scaling will be done.
//
// On return, scale will contain information about the permutations and scaling
// factors applied to A. If π(j) denotes the index of the column interchanged
// with column j, and D[j,j] denotes the scaling factor applied to column j,
// then
//
//	scale[j] == π(j),     for j ∈ {0, ..., ilo-1, ihi+1, ..., n-1},
//	         == D[j,j],   for j ∈ {ilo, ..., ihi}.
//
// scale must have length equal to n, otherwise dgebal will panic.
//
// dgebal returns 0 on success, or a negative error code.
pub fn dgebal(job BalanceJob, n int, mut a []f64, lda int, mut scale []f64) int {
	if job != .balance_none && job != .permute && job != .scale && job != .permute_scale {
		panic(bad_balance_job)
	}
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}

	mut ilo := 0
	mut ihi := n - 1

	if n == 0 {
		return 0
	}

	if scale.len != n {
		panic(short_scale)
	}

	if job == .balance_none {
		for i in 0 .. n {
			scale[i] = 1.0
		}
		return 0
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}

	mut swapped := true

	if job == .scale {
		unsafe {
			goto scaling
		}
	}

	// Permutation to isolate eigenvalues if possible.
	//
	// Search for rows isolating an eigenvalue and push them down.
	for swapped {
		swapped = false

		rows: for i := ihi; i >= 0; i-- {
			for j := 0; j <= ihi; j++ {
				if i == j {
					continue
				}
				if a[i * lda + j] != 0.0 {
					continue rows
				}
			}
			// Row i has only zero off-diagonal elements in the
			// block A[ilo:ihi+1,ilo:ihi+1].
			scale[ihi] = f64(i)
			if i != ihi {
				mut a_row_i := unsafe { a[i..] }
				mut a_row_ihi := unsafe { a[ihi..] }
				blas.dswap(ihi + 1, mut a_row_i, lda, mut a_row_ihi, lda)
				mut a_col_i := unsafe { a[i * lda..] }
				mut a_col_ihi := unsafe { a[ihi * lda..] }
				blas.dswap(n, mut a_col_i, 1, mut a_col_ihi, 1)
			}
			if ihi == 0 {
				scale[0] = 1.0
				return 0
			}
			ihi--
			swapped = true
			break
		}
	}
	// Search for columns isolating an eigenvalue and push them left.
	swapped = true
	for swapped {
		swapped = false

		columns: for j := ilo; j <= ihi; j++ {
			for i := ilo; i <= ihi; i++ {
				if i == j {
					continue
				}
				if a[i * lda + j] != 0.0 {
					continue columns
				}
			}
			// Column j has only zero off-diagonal elements in the
			// block A[ilo:ihi+1,ilo:ihi+1].
			scale[ilo] = f64(j)
			if j != ilo {
				mut a_col_j := unsafe { a[j..] }
				mut a_col_ilo := unsafe { a[ilo..] }
				blas.dswap(ihi + 1, mut a_col_j, lda, mut a_col_ilo, lda)
				mut a_row_j := unsafe { a[j * lda + ilo..] }
				mut a_row_ilo := unsafe { a[ilo * lda + ilo..] }
				blas.dswap(n - ilo, mut a_row_j, 1, mut a_row_ilo, 1)
			}
			swapped = true
			ilo++
			break
		}
	}

	scaling: for i := ilo; i <= ihi; i++ {
		scale[i] = 1.0
	}

	if job == .permute {
		return 0
	}

	// Balance the submatrix in rows ilo to ihi.

	// sclfac should be a power of 2 to avoid roundoff errors.
	// Elements of scale are restricted to powers of sclfac,
	// therefore the matrix will be only nearly balanced.
	sclfac := 2.0
	// factor determines the minimum reduction of the row and column
	// norms that is considered non-negligible. It must be less than 1.
	factor := 0.95
	sfmin1 := dlamch_s / dlamch_p
	sfmax1 := 1.0 / sfmin1
	sfmin2 := sfmin1 * sclfac
	sfmax2 := 1.0 / sfmin2

	// Iterative loop for norm reduction.
	mut conv := false
	for !conv {
		conv = true
		for i := ilo; i <= ihi; i++ {
			a_col := unsafe { a[ilo * lda + i..] }
			mut c := blas.dnrm2(ihi - ilo + 1, a_col, lda)
			a_row := unsafe { a[i * lda + ilo..] }
			mut r := blas.dnrm2(ihi - ilo + 1, a_row, 1)
			a_col_i := unsafe { a[i..] }
			ica := blas.idamax(ihi + 1, a_col_i, lda)
			mut ca := math.abs(a[ica * lda + i])
			a_row_i := unsafe { a[i * lda + ilo..] }
			ira := blas.idamax(n - ilo, a_row_i, 1)
			mut ra := math.abs(a[i * lda + ilo + ira])

			// Guard against zero c or r due to underflow.
			if c == 0.0 || r == 0.0 {
				continue
			}
			mut g := r / sclfac
			mut f := 1.0
			s := c + r
			for c < g && math.max(f, math.max(c, ca)) < sfmax2
				&& math.min(r, math.min(g, ra)) > sfmin2 {
				if math.is_nan(c + f + ca + r + g + ra) {
					// Panic if NaN to avoid infinite loop.
					panic('lapack: NaN')
				}
				f *= sclfac
				c *= sclfac
				ca *= sclfac
				g /= sclfac
				r /= sclfac
				ra /= sclfac
			}
			g = c / sclfac
			for r <= g && math.max(r, ra) < sfmax2
				&& math.min(math.min(f, c), math.min(g, ca)) > sfmin2 {
				f /= sclfac
				c /= sclfac
				ca /= sclfac
				g /= sclfac
				r *= sclfac
				ra *= sclfac
			}

			if c + r >= factor * s {
				// Reduction would be negligible.
				continue
			}
			if f < 1.0 && scale[i] < 1.0 && f * scale[i] <= sfmin1 {
				continue
			}
			if f > 1.0 && scale[i] > 1.0 && scale[i] >= sfmax1 / f {
				continue
			}

			// Now balance.
			scale[i] *= f
			mut a_row_scale := unsafe { a[i * lda + ilo..] }
			blas.dscal(n - ilo, 1.0 / f, mut a_row_scale, 1)
			mut a_col_scale := unsafe { a[i..] }
			blas.dscal(ihi + 1, f, mut a_col_scale, lda)
			conv = false
		}
	}
	return 0
}
