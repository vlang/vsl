module float32

import simd

// dot_unitary returns the f32 dot product, accumulating rounded f32 products
// in f64 so low-order terms are retained until the final f32 result.
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn dot_unitary(x []f32, y []f32) f32 {
	if y.len < x.len {
		panic('dot_unitary: second vector is shorter than first')
	}
	mut sum0 := 0.0
	mut sum1 := 0.0
	mut sum2 := 0.0
	mut sum3 := 0.0
	mut i := 0
	for ; i + 8 <= x.len; i += 8 {
		x_values := simd.load_f32x8_at(x, i)
		y_values := simd.load_f32x8_at(y, i)
		products := (x_values * y_values).to_array()
		sum0 += f64(products[0]) + f64(products[4])
		sum1 += f64(products[1]) + f64(products[5])
		sum2 += f64(products[2]) + f64(products[6])
		sum3 += f64(products[3]) + f64(products[7])
	}
	for ; i < x.len; i++ {
		sum0 += f64(y[i] * x[i])
	}
	return f32((sum0 + sum1) + (sum2 + sum3))
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
