module blas64

import sync
import vsl.float.float64
import math
import runtime
import simd

// dgemm performs one of the matrix-matrix operations
//  C = alpha * A * B + beta * C
//  C = alpha * Aᵀ * B + beta * C
//  C = alpha * A * Bᵀ + beta * C
//  C = alpha * Aᵀ * Bᵀ + beta * C
// where A is an m×k or k×m dense matrix, B is an n×k or k×n dense matrix, C is
// an m×n matrix, and alpha and beta are scalars. trans_a and trans_b specify whether A or
// B are transposed.
pub fn dgemm(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f64, a []f64, lda int, b []f64, ldb int, beta f64, mut c []f64, ldc int) {
	if m < 0 {
		panic(mlt0)
	}
	if n < 0 {
		panic(nlt0)
	}
	if k < 0 {
		panic(klt0)
	}
	a_trans := trans_a == .trans || trans_a == .conj_trans
	if a_trans {
		if lda < math.max(1, m) {
			panic(bad_ld_a)
		}
	} else {
		if lda < math.max(1, k) {
			panic(bad_ld_a)
		}
	}
	b_trans := trans_b == .trans || trans_b == .conj_trans
	if b_trans {
		if ldb < math.max(1, k) {
			panic(bad_ld_b)
		}
	} else {
		if ldb < math.max(1, n) {
			panic(bad_ld_b)
		}
	}
	if ldc < math.max(1, n) {
		panic(bad_ld_c)
	}

	// Quick return if possible.
	if m == 0 || n == 0 {
		return
	}

	// For zero matrix size the following slice length checks are trivially satisfied.
	if a_trans {
		if a.len < (k - 1) * lda + m {
			panic(short_a)
		}
	} else {
		if a.len < (m - 1) * lda + k {
			panic(short_a)
		}
	}
	if b_trans {
		if b.len < (n - 1) * ldb + k {
			panic(short_b)
		}
	} else {
		if b.len < (k - 1) * ldb + n {
			panic(short_b)
		}
	}
	if c.len < (m - 1) * ldc + n {
		panic(short_c)
	}

	// Quick return if possible.
	if (alpha == 0 || k == 0) && beta == 1 {
		return
	}

	// scale c
	if beta != 1 {
		if beta == 0 {
			for i in 0 .. m {
				mut ctmp := unsafe { c[i * ldc..i * ldc + n] }
				for j, _ in ctmp {
					ctmp[j] = 0
				}
			}
		} else {
			for i in 0 .. m {
				mut ctmp := unsafe { c[i * ldc..i * ldc + n] }
				for j, _ in ctmp {
					ctmp[j] *= beta
				}
			}
		}
	}
	if alpha == 0 || k == 0 {
		return
	}

	dgemm_parallel(if a_trans { .trans } else { .no_trans },
		if b_trans { .trans } else { .no_trans }, m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
}

fn dgemm_parallel(a_trans Transpose, b_trans Transpose, m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
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

	// Run one goroutine per configured job, reusing each worker for many tiles.
	// This respects VJOBS and avoids allocating a goroutine for every output tile.
	worker_count := math.min(runtime.nr_jobs(), par_blocks)
	if worker_count <= 1 {
		dgemm_serial(a_trans, b_trans, m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
	}
	mut wg := sync.new_waitgroup()
	wg.add(worker_count)
	defer {
		wg.wait()
	}
	n_block_columns := blocks(n, block_size)
	for worker_index in 0 .. worker_count {
		go fn (a_trans Transpose, b_trans Transpose, m int, n int, max_k_len int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64, worker_index int, worker_count int, n_block_columns int, mut wg sync.WaitGroup) {
			defer {
				wg.done()
			}
			tile_count := blocks(m, block_size) * n_block_columns
			for tile_index := worker_index; tile_index < tile_count; tile_index += worker_count {
				block_row := tile_index / n_block_columns
				block_column := tile_index % n_block_columns
				i := block_row * block_size
				j := block_column * block_size
				leni := math.min(block_size, m - i)
				lenj := math.min(block_size, n - j)
				mut c_sub := slice_view_f64(*c, ldc, i, j, leni, lenj)
				// Compute A_ik B_kj for all k.
				for k := 0; k < max_k_len; k += block_size {
					lenk := math.min(block_size, max_k_len - k)
					mut a_sub := []f64{}
					mut b_sub := []f64{}
					if a_trans == .trans {
						a_sub = slice_view_f64(a, lda, k, i, lenk, leni)
					} else {
						a_sub = slice_view_f64(a, lda, i, k, leni, lenk)
					}
					if b_trans == .trans {
						b_sub = slice_view_f64(b, ldb, j, k, lenj, lenk)
					} else {
						b_sub = slice_view_f64(b, ldb, k, j, lenk, lenj)
					}
					dgemm_serial(a_trans, b_trans, leni, lenj, lenk, a_sub, lda, b_sub, ldb, mut
						c_sub, ldc, alpha)
				}
			}
		}(a_trans, b_trans, m, n, max_k_len, a, lda, b, ldb, mut c, ldc, alpha,
			worker_index, worker_count, n_block_columns, mut wg)
	}
}

// dgemm_serial is serial matrix multiply
fn dgemm_serial(a_trans Transpose, b_trans Transpose, m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	if a_trans != .trans && b_trans != .trans {
		dgemm_serial_not_not(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
	}
	if a_trans == .trans && b_trans != .trans {
		dgemm_serial_trans_not(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
	}
	if a_trans != .trans && b_trans == .trans {
		dgemm_serial_not_trans(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
	}
	if a_trans == .trans && b_trans == .trans {
		dgemm_serial_trans_trans(m, n, k, a, lda, b, ldb, mut c, ldc, alpha)
		return
	}
	panic('unreachable')
}

// dgemm_serial where neither a nor b are transposed
@[direct_array_access]
fn dgemm_serial_not_not(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	mut i := 0
	for ; i + 4 <= m; i += 4 {
		a0 := i * lda
		a1 := a0 + lda
		a2 := a1 + lda
		a3 := a2 + lda
		c_base := i * ldc
		c1 := c_base + ldc
		c2 := c1 + ldc
		c3 := c2 + ldc
		mut j := 0
		for ; j + 8 <= n; j += 8 {
			mut s00 := simd.splat_f64x4(0.0)
			mut s01 := simd.splat_f64x4(0.0)
			mut s10 := simd.splat_f64x4(0.0)
			mut s11 := simd.splat_f64x4(0.0)
			mut s20 := simd.splat_f64x4(0.0)
			mut s21 := simd.splat_f64x4(0.0)
			mut s30 := simd.splat_f64x4(0.0)
			mut s31 := simd.splat_f64x4(0.0)
			for l := 0; l < k; l++ {
				v0 := alpha * a[a0 + l]
				v1 := alpha * a[a1 + l]
				v2 := alpha * a[a2 + l]
				v3 := alpha * a[a3 + l]
				b_base := l * ldb + j
				b_values0 := simd.load_f64x4_at(b, b_base)
				b_values1 := simd.load_f64x4_at(b, b_base + 4)
				broadcast0 := simd.splat_f64x4(v0)
				broadcast1 := simd.splat_f64x4(v1)
				broadcast2 := simd.splat_f64x4(v2)
				broadcast3 := simd.splat_f64x4(v3)
				s00 = broadcast0.mul_add(b_values0, s00)
				s01 = broadcast0.mul_add(b_values1, s01)
				s10 = broadcast1.mul_add(b_values0, s10)
				s11 = broadcast1.mul_add(b_values1, s11)
				s20 = broadcast2.mul_add(b_values0, s20)
				s21 = broadcast2.mul_add(b_values1, s21)
				s30 = broadcast3.mul_add(b_values0, s30)
				s31 = broadcast3.mul_add(b_values1, s31)
			}
			simd.load_f64x4_at(c, c_base + j)
				.add(s00).store_at(mut c, c_base + j)
			simd.load_f64x4_at(c, c_base + j + 4)
				.add(s01).store_at(mut c, c_base + j + 4)
			simd.load_f64x4_at(c, c1 + j)
				.add(s10).store_at(mut c, c1 + j)
			simd.load_f64x4_at(c, c1 + j + 4)
				.add(s11).store_at(mut c, c1 + j + 4)
			simd.load_f64x4_at(c, c2 + j)
				.add(s20).store_at(mut c, c2 + j)
			simd.load_f64x4_at(c, c2 + j + 4)
				.add(s21).store_at(mut c, c2 + j + 4)
			simd.load_f64x4_at(c, c3 + j)
				.add(s30).store_at(mut c, c3 + j)
			simd.load_f64x4_at(c, c3 + j + 4)
				.add(s31).store_at(mut c, c3 + j + 4)
		}
		for ; j < n; j++ {
			for l := 0; l < k; l++ {
				b_value := b[l * ldb + j]
				v0 := alpha * a[a0 + l]
				v1 := alpha * a[a1 + l]
				v2 := alpha * a[a2 + l]
				v3 := alpha * a[a3 + l]
				c[c_base + j] += v0 * b_value
				c[c1 + j] += v1 * b_value
				c[c2 + j] += v2 * b_value
				c[c3 + j] += v3 * b_value
			}
		}
	}
	for ; i < m; i++ {
		c_base := i * ldc
		a_base := i * lda
		for l := 0; l < k; l++ {
			tmp := alpha * a[a_base + l]
			b_base := l * ldb
			for j := 0; j < n; j++ {
				c[c_base + j] += tmp * b[b_base + j]
			}
		}
	}
}

// dgemm_serial where neither a is transposed and b is not
fn dgemm_serial_trans_not(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	// This style is used instead of the literal [i*stride +j]) is used because
	// approximately 5 times faster.
	for l := 0; l < k; l++ {
		btmp := b[l * ldb..l * ldb + n]
		for i, v in a[l * lda..l * lda + m] {
			tmp := alpha * v
			mut ctmp := unsafe { c[i * ldc..i * ldc + n] }
			float64.axpy_unitary(tmp, btmp, mut ctmp)
		}
	}
}

// dgemm_serial where neither a is not transposed and b is
fn dgemm_serial_not_trans(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	// This style is used instead of the literal [i*stride +j]) is used because
	// approximately 5 times faster.
	for i in 0 .. m {
		atmp := a[i * lda..i * lda + k]
		mut ctmp := unsafe { c[i * ldc..i * ldc + n] }
		for j in 0 .. n {
			ctmp[j] += alpha * float64.dot_unitary(atmp, b[j * ldb..j * ldb + k])
		}
	}
}

// dgemm_serial where both are transposed
fn dgemm_serial_trans_trans(m int, n int, k int, a []f64, lda int, b []f64, ldb int, mut c []f64, ldc int, alpha f64) {
	// This style is used instead of the literal [i*stride +j]) is used because
	// approximately 5 times faster.
	for l := 0; l < k; l++ {
		for i, v in a[l * lda..l * lda + m] {
			tmp := alpha * v
			mut ctmp := unsafe { c[i * ldc..i * ldc + n] }
			float64.axpy_inc(tmp, b[l..], mut ctmp, u32(n), u32(ldb), 1, 0, 0)
		}
	}
}

fn slice_view_f64(a []f64, lda int, i int, j int, r int, c int) []f64 {
	return a[i * lda + j..(i + r - 1) * lda + j + c]
}
