module float64

// dot_unitary
pub fn dot_unitary(x []f64, y []f64) f64 {
	mut sum := 0.0
	for i, v in x {
		sum += y[i] * v
	}
	return sum
}

// dot_inc
pub fn dot_inc(x []f64, y []f64, n u32, incX u32, incY u32, ix u32, iy u32) f64 {
	mut sum := 0.0
	mut ix_ := ix
	mut iy_ := iy
	for i := 0; i < int(n); i++ {
		sum += y[iy_] * x[ix_]
		ix_ += incX
		iy_ += incY
	}
	return sum
}
