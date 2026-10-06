module blas

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
	for i in 0 .. m {
		c_base := i * ldc
		for j in 0 .. n {
			c_index := c_base + j
			if beta == 0 {
				c[c_index] = 0
			} else if beta != 1 {
				c[c_index] *= beta
			}
		}
	}
	for i in 0 .. m {
		a_base := i * lda
		c_base := i * ldc
		for p in 0 .. k {
			a_value := alpha * a[a_base + p]
			b_base := p * ldb
			for j in 0 .. n {
				c[c_base + j] += a_value * b[b_base + j]
			}
		}
	}
}
