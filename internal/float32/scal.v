module float32

// scal_unitary
pub fn scal_unitary(alpha f32, mut x []f32) {
	for i in 0 .. x.len {
		x[i] *= alpha
	}
}

// scal_unitary_to
pub fn scal_unitary_to(mut dst []f32, alpha f32, x []f32) {
	for i, v in x {
		dst[i] = alpha * v
	}
}

// scal_inc
pub fn scal_inc(alpha f32, mut x []f32, n u32, incx u32) {
	mut ix := u32(0)
	for i := 0; i < int(n); i++ {
		x[ix] *= alpha
		ix += incx
	}
}

// scal_inc_to
pub fn scal_inc_to(mut dst []f32, incdst u32, alpha f32, x []f32, n u32, incx u32) {
	mut ix := 0
	mut idst := u32(0)
	for i := 0; i < int(n); i++ {
		dst[idst] = alpha * x[ix]
		ix += int(incx)
		idst += incdst
	}
}
