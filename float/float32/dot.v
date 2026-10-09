module float32

import simd

// dot_unitary
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn dot_unitary(x []f32, y []f32) f32 {
	if y.len < x.len {
		panic('dot_unitary: second vector is shorter than first')
	}
	mut i := 0
	mut sums := simd.splat_f32x8(0)
	for ; i + 8 <= x.len; i += 8 {
		x_values := simd.load_f32x8_at(x, i)
		y_values := simd.load_f32x8_at(y, i)
		sums = sums + x_values * y_values
	}
	mut sum := sums.sum()
	for ; i < x.len; i++ {
		sum += y[i] * x[i]
	}
	return sum
}

// dot_inc
pub fn dot_inc(x []f32, y []f32, n u32, incX u32, incY u32, ix u32, iy u32) f32 {
	if n == 0 {
		return 0
	}
	if incX == 1 && incY == 1 {
		start_x, start_y, length := int(ix), int(iy), int(n)
		return dot_unitary(x[start_x..start_x + length], y[start_y..start_y + length])
	}
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
