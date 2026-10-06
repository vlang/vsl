module blas

import math
import runtime
import simd
import sync

fn sgemm_pure(trans_a Transpose, trans_b Transpose, m int, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut c []f32, ldc int) {
	a_trans := trans_a == .trans || trans_a == .conj_trans
	b_trans := trans_b == .trans || trans_b == .conj_trans
	if m < 0 || n < 0 || k < 0 {
		panic('sgemm: dimensions must be non-negative')
	}
	if m == 0 || n == 0 {
		return
	}
	if ldc < n {
		panic('sgemm: ldc must be at least n')
	}
	if m > 1 && m - 1 > (max_int - n) / ldc {
		panic('sgemm: dimensions overflow')
	}
	c_required := (m - 1) * ldc + n
	if c.len < c_required {
		panic('sgemm: output storage is shorter than its dimensions')
	}
	if k == 0 || alpha == 0 {
		for i in 0 .. m {
			for j in 0 .. n {
				c_index := i * ldc + j
				if beta == 0 {
					c[c_index] = 0
				} else if beta != 1 {
					c[c_index] *= beta
				}
			}
		}
		return
	}
	min_lda := if a_trans { m } else { k }
	min_ldb := if b_trans { k } else { n }
	if lda < min_lda || ldb < min_ldb {
		panic('sgemm: invalid leading dimension')
	}
	if a_trans {
		if k > 1 && lda > (max_int - m) / (k - 1) {
			panic('sgemm: dimensions overflow')
		}
	} else if m > 1 && lda > (max_int - k) / (m - 1) {
		panic('sgemm: dimensions overflow')
	}
	if b_trans {
		if n > 1 && ldb > (max_int - k) / (n - 1) {
			panic('sgemm: dimensions overflow')
		}
	} else if k > 1 && ldb > (max_int - n) / (k - 1) {
		panic('sgemm: dimensions overflow')
	}
	a_required := if a_trans { (k - 1) * lda + m } else { (m - 1) * lda + k }
	b_required := if b_trans { (n - 1) * ldb + k } else { (k - 1) * ldb + n }
	if a.len < a_required || b.len < b_required {
		panic('sgemm: input storage is shorter than its dimensions')
	}
	if !a_trans && !b_trans {
		sgemm_pure_no_trans(m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
		return
	}
	for i in 0 .. m {
		for j in 0 .. n {
			mut sum := f32(0)
			for p in 0 .. k {
				a_index := if a_trans { p * lda + i } else { i * lda + p }
				b_index := if b_trans { j * ldb + p } else { p * ldb + j }
				sum += a[a_index] * b[b_index]
			}
			c_index := i * ldc + j
			if beta == 0 {
				c[c_index] = alpha * sum
			} else {
				c[c_index] = alpha * sum + beta * c[c_index]
			}
		}
	}
}

@[direct_array_access]
fn sgemm_pure_no_trans(m int, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut c []f32, ldc int) {
	row_blocks := (m + 7) / 8
	worker_count := math.min(runtime.nr_jobs(), row_blocks)
	if worker_count <= 1 || m * n * k < 8_000_000 {
		sgemm_pure_no_trans_rows(0, m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
		return
	}
	mut wg := sync.new_waitgroup()
	wg.add(worker_count)
	for worker_index in 0 .. worker_count {
		start_row := (worker_index * row_blocks / worker_count) * 8
		end_row := math.min(m, ((worker_index + 1) * row_blocks / worker_count) * 8)
		go fn (start_row int, end_row int, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut c []f32, ldc int, mut wg sync.WaitGroup) {
			defer {
				wg.done()
			}
			sgemm_pure_no_trans_rows(start_row, end_row, n, k, alpha, a, lda, b, ldb, beta,
				mut c, ldc)
		}(start_row, end_row, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc, mut wg)
	}
	wg.wait()
}

@[direct_array_access]
fn sgemm_pure_no_trans_rows(row_start int, row_end int, n int, k int, alpha f32, a []f32, lda int, b []f32, ldb int, beta f32, mut c []f32, ldc int) {
	mut i := row_start
	for ; i + 8 <= row_end; i += 8 {
		a0 := i * lda
		a1 := a0 + lda
		a2 := a1 + lda
		a3 := a2 + lda
		a4 := a3 + lda
		a5 := a4 + lda
		a6 := a5 + lda
		a7 := a6 + lda
		c0 := i * ldc
		c1 := c0 + ldc
		c2 := c1 + ldc
		c3 := c2 + ldc
		c4 := c3 + ldc
		c5 := c4 + ldc
		c6 := c5 + ldc
		c7 := c6 + ldc
		mut j := 0
		for ; j + 8 <= n; j += 8 {
			mut sum0 := simd.splat_f32x8(0)
			mut sum1 := simd.splat_f32x8(0)
			mut sum2 := simd.splat_f32x8(0)
			mut sum3 := simd.splat_f32x8(0)
			mut sum4 := simd.splat_f32x8(0)
			mut sum5 := simd.splat_f32x8(0)
			mut sum6 := simd.splat_f32x8(0)
			mut sum7 := simd.splat_f32x8(0)
			for p in 0 .. k {
				b_values := simd.load_f32x8_at(b, p * ldb + j)
				sum0 = sum0 + simd.splat_f32x8(alpha * a[a0 + p]) * b_values
				sum1 = sum1 + simd.splat_f32x8(alpha * a[a1 + p]) * b_values
				sum2 = sum2 + simd.splat_f32x8(alpha * a[a2 + p]) * b_values
				sum3 = sum3 + simd.splat_f32x8(alpha * a[a3 + p]) * b_values
				sum4 = sum4 + simd.splat_f32x8(alpha * a[a4 + p]) * b_values
				sum5 = sum5 + simd.splat_f32x8(alpha * a[a5 + p]) * b_values
				sum6 = sum6 + simd.splat_f32x8(alpha * a[a6 + p]) * b_values
				sum7 = sum7 + simd.splat_f32x8(alpha * a[a7 + p]) * b_values
			}
			if beta != 0 {
				beta_vec := simd.splat_f32x8(beta)
				sum0 = sum0 + beta_vec * simd.load_f32x8_at(c, c0 + j)
				sum1 = sum1 + beta_vec * simd.load_f32x8_at(c, c1 + j)
				sum2 = sum2 + beta_vec * simd.load_f32x8_at(c, c2 + j)
				sum3 = sum3 + beta_vec * simd.load_f32x8_at(c, c3 + j)
				sum4 = sum4 + beta_vec * simd.load_f32x8_at(c, c4 + j)
				sum5 = sum5 + beta_vec * simd.load_f32x8_at(c, c5 + j)
				sum6 = sum6 + beta_vec * simd.load_f32x8_at(c, c6 + j)
				sum7 = sum7 + beta_vec * simd.load_f32x8_at(c, c7 + j)
			}
			sum0.store_at(mut c, c0 + j)
			sum1.store_at(mut c, c1 + j)
			sum2.store_at(mut c, c2 + j)
			sum3.store_at(mut c, c3 + j)
			sum4.store_at(mut c, c4 + j)
			sum5.store_at(mut c, c5 + j)
			sum6.store_at(mut c, c6 + j)
			sum7.store_at(mut c, c7 + j)
		}
		for ; j < n; j++ {
			mut sum0 := f32(0)
			mut sum1 := f32(0)
			mut sum2 := f32(0)
			mut sum3 := f32(0)
			mut sum4 := f32(0)
			mut sum5 := f32(0)
			mut sum6 := f32(0)
			mut sum7 := f32(0)
			for p in 0 .. k {
				b_value := b[p * ldb + j]
				sum0 += alpha * a[a0 + p] * b_value
				sum1 += alpha * a[a1 + p] * b_value
				sum2 += alpha * a[a2 + p] * b_value
				sum3 += alpha * a[a3 + p] * b_value
				sum4 += alpha * a[a4 + p] * b_value
				sum5 += alpha * a[a5 + p] * b_value
				sum6 += alpha * a[a6 + p] * b_value
				sum7 += alpha * a[a7 + p] * b_value
			}
			if beta != 0 {
				sum0 += beta * c[c0 + j]
				sum1 += beta * c[c1 + j]
				sum2 += beta * c[c2 + j]
				sum3 += beta * c[c3 + j]
				sum4 += beta * c[c4 + j]
				sum5 += beta * c[c5 + j]
				sum6 += beta * c[c6 + j]
				sum7 += beta * c[c7 + j]
			}
			c[c0 + j] = sum0
			c[c1 + j] = sum1
			c[c2 + j] = sum2
			c[c3 + j] = sum3
			c[c4 + j] = sum4
			c[c5 + j] = sum5
			c[c6 + j] = sum6
			c[c7 + j] = sum7
		}
	}
	for ; i < row_end; i++ {
		a_base := i * lda
		c_base := i * ldc
		for j in 0 .. n {
			mut sum := f32(0)
			for p in 0 .. k {
				sum += alpha * a[a_base + p] * b[p * ldb + j]
			}
			c_index := c_base + j
			if beta != 0 {
				sum += beta * c[c_index]
			}
			c[c_index] = sum
		}
	}
}
