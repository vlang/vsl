module float64

import runtime
import sync

// ger performs the rank-one operation
//  A += alpha * x * yᵀ
// where A is an m×n dense matrix, x and y are vectors, and alpha is a scalar.
pub fn ger(m u32, n u32, alpha f64, x []f64, incx u32, y []f64, incy u32, mut a []f64, lda u32) {
	if incx == 1 && incy == 1 {
		for i, xv in x[..m] {
			axpy_unitary(alpha * xv, y[..n], mut a[u32(i) * lda..u32(i) * lda + n])
		}
		return
	}

	mut ky := u32(0)
	mut kx := u32(0)
	if int(incy) < 0 {
		ky = u32(-int(n - 1) * int(incy))
	}
	if int(incx) < 0 {
		kx = u32(-int(m - 1) * int(incx))
	}

	mut ix := kx
	for i := 0; i < int(m); i++ {
		axpy_inc(alpha * x[ix], y, mut a[u32(i) * lda..u32(i) * lda + n], n, incy, 1, ky, 0)
		ix += incx
	}
}

// gemv_n computes
//  y = alpha * A * x + beta * y
// where A is an m×n dense matrix, x and y are vectors, and alpha and beta are scalars.
pub fn gemv_n(m u32, n u32, alpha f64, a []f64, lda u32, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if m == 0 || n == 0 {
		return
	}
	if incx == 1 && incy == 1 {
		workers := gemv_n_workers(m, n, 8)
		if workers > 1 {
			mut wg := sync.new_waitgroup()
			wg.add(workers)
			chunk := int(m) / workers
			for t in 0 .. workers {
				r0 := t * chunk
				r1 := if t == workers - 1 { int(m) } else { r0 + chunk }
				go fn (m u32, n u32, alpha f64, a []f64, lda u32, x []f64, beta f64, mut y []f64, r0 int, r1 int, mut wg sync.WaitGroup) {
					defer {
						wg.done()
					}
					for i in r0 .. r1 {
						sum := dot_unitary(a[lda * u32(i)..lda * u32(i) + n], x)
						if beta == 0 {
							y[i] = alpha * sum
						} else {
							y[i] = beta * y[i] + alpha * sum
						}
					}
				}(m, n, alpha, a, lda, x, beta, mut y, r0, r1, mut wg)
			}
			wg.wait()
			return
		}
		for i in 0 .. m {
			sum := dot_unitary(a[lda * i..lda * i + n], x)
			if beta == 0 {
				y[i] = alpha * sum
			} else {
				y[i] = beta * y[i] + alpha * sum
			}
		}
		return
	}
	if incx > 0 && incy > 0 {
		mut iy := 0
		for i in 0 .. int(m) {
			sum := dot_inc(x, a[int(lda) * i..int(lda) * i + int(n)], n, u32(incx), 1, 0, 0)
			if beta == 0 {
				y[iy] = alpha * sum
			} else {
				y[iy] = beta * y[iy] + alpha * sum
			}
			iy += incy
		}
		return
	}
	start_x := if incx < 0 { (int(n) - 1) * -incx } else { 0 }
	start_y := if incy < 0 { (int(m) - 1) * -incy } else { 0 }
	for i in 0 .. int(m) {
		mut sum := 0.0
		mut ix := start_x
		for j in 0 .. int(n) {
			sum += a[int(lda) * i + j] * x[ix]
			ix += incx
		}
		iy := start_y + i * incy
		if beta == 0 {
			y[iy] = alpha * sum
		} else {
			y[iy] = beta * y[iy] + alpha * sum
		}
	}
}

// gemv_n_workers sizes the row-block pool for gemv_n: one worker per
// block while every worker streams at least ~4MB, so spawn cost (~10s
// of us) vanishes next to DRAM time, and never fewer than the serial
// kernel needs. Mirrors the sgemm worker bounding (runtime.nr_jobs,
// VJOBS-tunable); the transposed path stays serial because all rows
// accumulate into the same y (a reduction, not a partition).
fn gemv_n_workers(m u32, n u32, elem_bytes u64) int {
	if m < 2 {
		return 1
	}
	if u64(m) * u64(n) * elem_bytes < u64(16) << 20 {
		return 1
	}
	mut workers := runtime.nr_jobs()
	if workers < 2 {
		return 1
	}
	if workers > int(m) {
		workers = int(m)
	}
	for workers > 2 && u64(m) * u64(n) * elem_bytes / u64(workers) < u64(4) << 20 {
		workers--
	}
	return workers
}

// gemv_t computes
//  y = alpha * Aᵀ * x + beta * y
// where A is an m×n dense matrix, x and y are vectors, and alpha and beta are scalars.
pub fn gemv_t(m u32, n u32, alpha f64, a []f64, lda u32, x []f64, incx int, beta f64, mut y []f64, incy int) {
	if m == 0 || n == 0 {
		return
	}
	if incx == 1 && incy == 1 {
		if beta == 0 {
			for j in 0 .. n {
				y[j] = 0
			}
		} else {
			scal_unitary(beta, mut y[..n])
		}
		for i in 0 .. m {
			axpy_unitary_to(mut y[..n], alpha * x[i], a[lda * i..lda * i + n], y[..n])
		}
		return
	}
	if incx > 0 && incy > 0 {
		for j in 0 .. int(n) {
			iy := j * incy
			if beta == 0 {
				y[iy] = 0
			} else {
				y[iy] *= beta
			}
		}
		for i in 0 .. int(m) {
			axpy_inc(alpha * x[i * incx], a[int(lda) * i..int(lda) * i + int(n)], mut y, n, 1,
				u32(incy), 0, 0)
		}
		return
	}
	start_x := if incx < 0 { (int(m) - 1) * -incx } else { 0 }
	start_y := if incy < 0 { (int(n) - 1) * -incy } else { 0 }
	for j in 0 .. int(n) {
		mut sum := 0.0
		mut ix := start_x
		for i in 0 .. int(m) {
			sum += a[int(lda) * i + j] * x[ix]
			ix += incx
		}
		iy := start_y + j * incy
		if beta == 0 {
			y[iy] = alpha * sum
		} else {
			y[iy] = beta * y[iy] + alpha * sum
		}
	}
}
