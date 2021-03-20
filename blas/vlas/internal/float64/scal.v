module float64

// scal_unitary
pub fn scal_unitary(alpha f64, mut x []f64) {
	for i in 0 .. x.len {
		x[i] *= alpha
	}
}

// scal_unitary_to
pub fn scal_unitary_to(mut dst []f64, alpha f64, x []f64) {
	for i, v in x {
		dst[i] = alpha * v
	}
}

// scal_inc
pub fn scal_inc(alpha f64, mut x []f64, n, inc_x u32) {
	mut ix := u32(0)
	for i := 0; i < int(n); i++ {
		x[ix] *= alpha
		ix += inc_x
	}
}

// scal_inc_to
pub fn scal_inc_to(mut dst []f64, inc_dst u32, alpha f64, x []f64, n, inc_x u32) {
	mut ix_ := ix
        mut idst_ := u32(0)
	for i := 0; i < int(n); i++ {
		dst[idst] = alpha * x[ix]
		ix_ += inc_x
		idst_ += inc_dst
	}
}
