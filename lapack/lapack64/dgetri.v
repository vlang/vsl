module lapack64

import math
import vsl.blas

// dgetri computes the inverse of the matrix A using the LU factorization computed
// by dgetrf. On entry, a contains the PLU decomposition of A as computed by
// dgetrf and on exit contains the reciprocal of the original matrix.
//
// dgetri will not perform the inversion if the matrix is singular, and returns
// a boolean indicating whether the inversion was successful.
//
// work is temporary storage, and lwork specifies the usable memory length.
// At minimum, lwork >= n and this function will panic otherwise.
// dgetri is a blocked inversion, but the block size is limited
// by the temporary space available. If lwork == -1, instead of performing dgetri,
// the optimal work length will be stored into work[0].
pub fn dgetri(n int, mut a []f64, lda int, ipiv []int, mut work []f64, lwork int) bool {
	mut iws := math.max(1, n)
	if n < 0 {
		panic(n_lt0)
	}
	if lda < math.max(1, n) {
		panic(bad_ld_a)
	}
	if lwork < iws && lwork != -1 {
		panic(bad_l_work)
	}
	if work.len < math.max(1, lwork) {
		panic(short_work)
	}

	if n == 0 {
		work[0] = 1.0
		return true
	}

	mut nb := ilaenv(1, 'DGETRI', ' ', n, -1, -1, -1)
	if lwork == -1 {
		work[0] = f64(n * nb)
		return true
	}

	if a.len < (n - 1) * lda + n {
		panic(short_a)
	}
	if ipiv.len != n {
		panic(bad_len_ipiv)
	}

	// Form inv(U).
	ok := dtrtri(.upper, .non_unit, n, mut a, lda)
	if !ok {
		return false
	}

	mut nbmin := 2
	if 1 < nb && nb < n {
		iws = math.max(n * nb, 1)
		if lwork < iws {
			nb = lwork / n
			nbmin = math.max(2, ilaenv(2, 'DGETRI', ' ', n, -1, -1, -1))
		}
	}
	ldwork := nb

	// Solve the equation inv(A)*L = inv(U) for inv(A).
	if nb < nbmin || n <= nb {
		// Unblocked code.
		for j := n - 1; j >= 0; j-- {
			for i := j + 1; i < n; i++ {
				// Copy current column of L to work and replace with zeros.
				work[i] = a[i * lda + j]
				a[i * lda + j] = 0.0
			}
			// Compute current column of inv(A).
			if j < n - 1 {
				mut a_col := unsafe { a[j..] }
				mut work_vec := unsafe { work[j + 1..] }
				mut a_right := unsafe { a[(j + 1)..] }
				blas.dgemv(.no_trans, n, n - j - 1, -1.0, a_right, lda, work_vec, 1, 1.0, mut
					a_col, lda)
			}
		}
	} else {
		// Blocked code.
		nn := ((n - 1) / nb) * nb
		for j := nn; j >= 0; j -= nb {
			jb := math.min(nb, n - j)
			// Copy current block column of L to work and replace
			// with zeros.
			for jj := j; jj < j + jb; jj++ {
				for i := jj + 1; i < n; i++ {
					work[i * ldwork + (jj - j)] = a[i * lda + jj]
					a[i * lda + jj] = 0.0
				}
			}
			// Compute current block column of inv(A).
			if j + jb < n {
				mut a_col := unsafe { a[j..] }
				mut a_right := unsafe { a[(j + jb)..] }
				mut work_block := unsafe { work[(j + jb) * ldwork..] }
				blas.dgemm(.no_trans, .no_trans, n, jb, n - j - jb, -1.0, a_right, lda,
					work_block, ldwork, 1.0, mut a_col, lda)
			}
			mut a_col := unsafe { a[j..] }
			mut work_block := unsafe { work[j * ldwork..] }
			blas.dtrsm(.right, .lower, .no_trans, .unit, n, jb, 1.0, work_block, ldwork, mut
				a_col, lda)
		}
	}
	// Apply column interchanges.
	for j := n - 2; j >= 0; j-- {
		jp := ipiv[j]
		if jp != j {
			mut a_col_j := unsafe { a[j..] }
			mut a_col_jp := unsafe { a[jp..] }
			blas.dswap(n, mut a_col_j, lda, mut a_col_jp, lda)
		}
	}
	work[0] = f64(iws)
	return true
}
