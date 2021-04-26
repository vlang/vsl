module float64

// axpy_unitary
pub fn axpy_unitary(alpha f64, x []f64, mut y []f64) {
	for i, v in x {
		y[i] += alpha * v
	}
}

// axpy_unitary_to
pub fn axpy_unitary_to(mut dst []f64, alpha f64, x []f64, y []f64) {
	for i, v in x {
		dst[i] = alpha * v + y[i]
	}
}

// axpy_inc
pub fn axpy_inc(alpha f64, x []f64, mut y []f64, n u32, incX u32, incY u32, ix u32, iy u32) {
	mut ix_ := ix
	mut iy_ := iy
	for i := 0; i < int(n); i++ {
		y[iy_] += alpha * x[ix_]
		ix_ += incX
		iy_ += incY
	}
}

// axpy_inc_to
pub fn axpy_inc_to(mut dst []f64, inc_dst u32, idst u32, alpha f64, x []f64, y []f64, n u32, incX u32, incY u32, ix u32, iy u32) {
	mut ix_ := ix
	mut iy_ := iy
	mut idst_ := idst
	for i := 0; i < int(n); i++ {
		dst[idst_] = alpha * x[ix_] + y[iy_]
		ix_ += incX
		iy_ += incY
		idst_ += inc_dst
	}
}
