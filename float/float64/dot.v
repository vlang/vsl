module float64

import simd

// dot_unitary
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn dot_unitary(x []f64, y []f64) f64 {
	if y.len < x.len {
		panic('dot_unitary: second vector is shorter than first')
	}
	mut i := 0
	mut sums := simd.splat_f64x4(0)
	for ; i + 4 <= x.len; i += 4 {
		x_values := simd.load_f64x4_at(x, i)
		y_values := simd.load_f64x4_at(y, i)
		sums = sums + x_values * y_values
	}
	mut sum := sums.sum()
	for ; i < x.len; i++ {
		sum += y[i] * x[i]
	}
	return sum
}

// dot_inc
pub fn dot_inc(x []f64, y []f64, n u32, incX u32, incY u32, ix u32, iy u32) f64 {
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
