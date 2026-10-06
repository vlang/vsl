module float32

// dot_unitary
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn dot_unitary(x []f32, y []f32) f32 {
	if y.len < x.len {
		panic('dot_unitary: second vector is shorter than first')
	}
	mut sum := f32(0)
	for i in 0 .. x.len {
		sum += y[i] * x[i]
	}
	return sum
}

// dot_inc
pub fn dot_inc(x []f32, y []f32, n u32, incX u32, incY u32, ix u32, iy u32) f32 {
	mut sum := f32(0)
	mut ix_ := ix
	mut iy_ := iy
	for i := 0; i < int(n); i++ {
		sum += y[iy_] * x[ix_]
		ix_ += incX
		iy_ += incY
	}
	return sum
}
