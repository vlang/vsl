module float64

// dot_unitary
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn dot_unitary(x []f64, y []f64) f64 {
	if y.len < x.len {
		panic('dot_unitary: second vector is shorter than first')
	}
	mut sum0 := 0.0
	mut sum1 := 0.0
	mut sum2 := 0.0
	mut sum3 := 0.0
	mut i := 0
	for ; i + 4 <= x.len; i += 4 {
		sum0 += x[i] * y[i]
		sum1 += x[i + 1] * y[i + 1]
		sum2 += x[i + 2] * y[i + 2]
		sum3 += x[i + 3] * y[i + 3]
	}
	mut sum := (sum0 + sum1) + (sum2 + sum3)
	for ; i < x.len; i++ {
		sum += y[i] * x[i]
	}
	return sum
}

// dot_inc
pub fn dot_inc(x []f64, y []f64, n u32, incX u32, incY u32, ix u32, iy u32) f64 {
	if n == 0 {
		return 0
	}
	if incX == 1 && incY == 1 {
		start_x, start_y, length := int(ix), int(iy), int(n)
		return dot_unitary(x[start_x..start_x + length], y[start_y..start_y + length])
	}
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
