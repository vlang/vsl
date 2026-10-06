module float64

// axpy_unitary
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn axpy_unitary(alpha f64, x []f64, mut y []f64) {
	if y.len < x.len {
		panic('axpy_unitary: destination is shorter than source')
	}
	for i in 0 .. x.len {
		y[i] += alpha * x[i]
	}
}

// axpy_unitary_to
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn axpy_unitary_to(mut dst []f64, alpha f64, x []f64, y []f64) {
	if dst.len < x.len || y.len < x.len {
		panic('axpy_unitary_to: destination or addend is shorter than source')
	}
	for i in 0 .. x.len {
		dst[i] = alpha * x[i] + y[i]
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
pub fn axpy_inc_to(mut dst []f64, incdst u32, idst u32, alpha f64, x []f64, y []f64, n u32, incX u32, incY u32, ix u32, iy u32) {
	mut ix_ := ix
	mut iy_ := iy
	mut idst_ := idst
	for i := 0; i < int(n); i++ {
		dst[idst_] = alpha * x[ix_] + y[iy_]
		ix_ += incX
		iy_ += incY
		idst_ += incdst
	}
}
