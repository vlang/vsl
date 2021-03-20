module vlas

import runtime
import sync
import vsl.blas.vlas.internal.float64
import vsl.util

// dgemm performs one of the matrix-matrix operations
//  C = alpha * A * B + beta * C
//  C = alpha * Aᵀ * B + beta * C
//  C = alpha * A * Bᵀ + beta * C
//  C = alpha * Aᵀ * Bᵀ + beta * C
// where A is an m×k or k×m dense matrix, B is an n×k or k×n dense matrix, C is
// an m×n matrix, and alpha and beta are scalars. trans_a and trans_b specify whether A or
// B are transposed.
pub fn dgemm(trans_a u32, trans_b u32, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	match trans_a {
                cblas_no_trans, cblas_trans, cblas_conj_trans {}
                else {
                        panic(bad_transpose)
                }
	}
	match trans_b {
                cblas_no_trans, cblas_trans, cblas_conj_trans {}
                else {
                        panic(bad_transpose)
                }
	}
	if m < 0 {
		panic(mlt0)
	}
	if n < 0 {
		panic(nlt0)
	}
	if k < 0 {
		panic(klt0)
	}
	a_trans := trans_a == cblas_trans || trans_a == cblas_conj_trans
	if a_trans {
		if lda < util.imax(1, m) {
			panic(bad_ld_a)
		}
	} else {
		if lda < util.imax(1, k) {
			panic(bad_ld_a)
		}
	}
	b_trans := trans_b == cblas_trans || trans_b == cblas_conj_trans
	if b_trans {
		if ldb < util.imax(1, k) {
			panic(bad_ld_b)
		}
	} else {
		if ldb < util.imax(1, n) {
			panic(bad_ld_b)
		}
	}
	if ldc < util.imax(1, n) {
		panic(bad_ld_c)
	}

	// Quick return if possible.
	if m == 0 || n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a_trans {
		if a.len < (k-1)*lda+m {
			panic(short_a)
		}
	} else {
		if a.len < (m-1)*lda+k {
			panic(short_a)
		}
	}
	if b_trans {
		if b.len < (n-1)*ldb+k {
			panic(short_b)
		}
	} else {
		if b.len < (k-1)*ldb+n {
			panic(short_b)
		}
	}
	if c.len < (m-1)*ldc+n {
		panic(short_c)
	}

	// Quick return if possible.
	if (alpha == 0 || k == 0) && beta == 1 {
		return
	}

	// scale c
	if beta != 1 {
		if beta == 0 {
			for i := 0; i < m; i++ {
				mut ctmp := c[i*ldc..i*ldc+n]
				for j, _ in ctmp {
					ctmp[j] = 0
				}
			}
		} else {
			for i := 0; i < m; i++ {
				mut ctmp := c[i*ldc..i*ldc+n]
				for j, _ in ctmp {
					ctmp[j] *= beta
				}
			}
		}
	}

	dgemm_parallel(a_trans, b_trans, m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
}

fn dgemm_parallel(a_trans bool, b_trans bool, m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
        // dgemm_parallel computes a parallel matrix multiplication by partitioning
	// a and b into sub-blocks, and updating c with the multiplication of the sub-block
	// In all cases,
	// A = [ 	A_11	A_12 ... 	A_1j
	//			A_21	A_22 ...	A_2j
	//				...
	//			A_i1	A_i2 ...	A_ij]
	//
	// and same for B. All of the submatrix sizes are block_size×block_size except
	// at the edges.
	//
	// In all cases, there is one dimension for each matrix along which
	// C must be updated sequentially.
	// Cij = \sum_k Aik Bki,	(A * B)
	// Cij = \sum_k Aki Bkj,	(Aᵀ * B)
	// Cij = \sum_k Aik Bjk,	(A * Bᵀ)
	// Cij = \sum_k Aki Bjk,	(Aᵀ * Bᵀ)
	//
	// This code computes one {i, j} block sequentially along the k dimension,
	// and computes all of the {i, j} blocks concurrently. This
	// partitioning allows Cij to be updated in-place without race-conditions.
	// Instead of launching a goroutine for each possible concurrent computation,
	// a number of worker goroutines are created and channels are used to pass
	// available and completed cases.
	//
	// http://alexkr.com/docs/matrixmult.pdf is a good reference on matrix-matrix
	// multiplies, though this code does not copy matrices to attempt to eliminate
	// cache misses.

        max_k_len := k
        par_blocks := blocks(m, block_size) * blocks(n, block_size)
        if par_blocks < min_par_block {
                // The matrix multiplication is small in the dimensions where it can be
		// computed concurrently. Just do it in serial.
		dgemm_serial(a_trans, b_trans, m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
        }

        // worker_limit acts a number of maximum concurrent workers,
	// with the limit set to the number of procs available.
	// worker_limit := chan int{cap: runtime.nr_jobs()}

	// wg is used to wait for all
	mut wg := sync.new_waitgroup()
	wg.add(par_blocks)
        defer {
                wg.wait()
        }

        for i := 0; i < m; i += block_size {
		for j := 0; j < n; j += block_size {
			// worker_limit <- 0
			go fn(a_trans bool, b_trans bool, m int, n int, max_k_len int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64, i int, j int, mut wg sync.WaitGroup /*, worker_limit chan int */) {
				defer {
					wg.done()
					// <-worker_limit
				}

				mut leni := block_size
				if i+leni > m {
					leni = m - i
				}
				mut lenj := block_size
				if j+lenj > n {
					lenj = n - j
				}

				mut c_sub := slice_view_f64(c, ldc, i, j, leni, lenj)

				// Compute A_ik B_kj for all k
				for k := 0; k < max_k_len; k += block_size {
					mut lenk := block_size
					if k+lenk > max_k_len {
						lenk = max_k_len - k
					}
					mut a_sub := []f64{}
                                        mut b_sub := []f64{}
					if a_trans {
						a_sub = slice_view_f64(a, lda, k, i, lenk, leni)
					} else {
						a_sub = slice_view_f64(a, lda, i, k, leni, lenk)
					}
					if b_trans {
						b_sub = slice_view_f64(b, ldb, j, k, lenj, lenk)
					} else {
						b_sub = slice_view_f64(b, ldb, k, j, lenk, lenj)
					}
					dgemm_serial(a_trans, b_trans, leni, lenj, lenk, a_sub, lda, b_sub, ldb, mut c_sub, ldc, alpha)
				}
			}(a_trans, b_trans, m, n, max_k_len, a, lda, b, ldb, mut c, ldc, alpha, i, j, mut wg /*, worker_limit */)
		}
	}
}

// dgemm_serial is serial matrix multiply
fn dgemm_serial(a_trans bool, b_trans bool, m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
        if !a_trans && !b_trans {
		dgemm_serial_not_not(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
        }
	if a_trans && !b_trans {
		dgemm_serial_trans_not(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
        }
	if !a_trans && b_trans {
		dgemm_serial_not_trans(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
        }
	if a_trans && b_trans {
		dgemm_serial_trans_trans(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
        }
        panic("unreachable")
}

// dgemm_serial where neither a nor b are transposed
fn dgemm_serial_not_not(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	// This style is used instead of the literal [i*stride +j]) is used because
	// approximately 5 times faster.
	for i := 0; i < m; i++ {
		mut ctmp := c[i*ldc..i*ldc+n]
		for l, v in a[i*lda..i*lda+k] {
			tmp := alpha * v
			if tmp != 0 {
				float64.axpy_unitary(tmp, b[l*ldb..l*ldb+n], mut ctmp)
			}
		}
	}
}

// dgemm_serial where neither a is transposed and b is not
fn dgemm_serial_trans_not(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	// This style is used instead of the literal [i*stride +j]) is used because
	// approximately 5 times faster.
	for l := 0; l < k; l++ {
		btmp := b[l*ldb..l*ldb+n]
		for i, v in a[l*lda..l*lda+m] {
			tmp := alpha * v
			if tmp != 0 {
				mut ctmp := c[i*ldc..i*ldc+n]
				float64.axpy_unitary(tmp, btmp, mut ctmp)
			}
		}
	}
}

// dgemm_serial where neither a is not transposed and b is
fn dgemm_serial_not_trans(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	// This style is used instead of the literal [i*stride +j]) is used because
	// approximately 5 times faster.
	for i := 0; i < m; i++ {
		atmp := a[i*lda..i*lda+k]
		mut ctmp := c[i*ldc..i*ldc+n]
		for j := 0; j < n; j++ {
			ctmp[j] += alpha * float64.dot_unitary(atmp, b[j*ldb..j*ldb+k])
		}
	}
}

// dgemm_serial where both are transposed
fn dgemm_serial_trans_trans(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	// This style is used instead of the literal [i*stride +j]) is used because
	// approximately 5 times faster.
	for l := 0; l < k; l++ {
		for i, v in a[l*lda..l*lda+m] {
			tmp := alpha * v
			if tmp != 0 {
				mut ctmp := c[i*ldc..i*ldc+n]
				float64.axpy_inc(tmp, b[l..], mut ctmp, u32(n), u32(ldb), 1, 0, 0)
			}
		}
	}
}

fn slice_view_f64(a []f64, lda int, i int, j int, r int, c int) []f64 {
	return a[i*lda+j..(i+r-1)*lda+j+c]
}
