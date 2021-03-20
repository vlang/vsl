module float32

// dot_unitary
pub fn dot_unitary(x []f32, y []f32) f32 {
        mut sum := 0.0
	for i, v in x {
		sum += y[i] * v
	}
	return sum
}

// dot_inc
pub fn dot_inc(x []f32, y []f32, n u32, incX u32, incY u32, ix u32, iy u32) f32 {
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

