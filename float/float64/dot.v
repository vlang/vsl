module float64

import simd

// dot_unitary returns the f64 dot product, widening each block of products
// into four scalar accumulators so partial sums stay independent.
// Length validation allows direct indexed access in the hot loop.
@[direct_array_access]
pub fn dot_unitary(x []f64, y []f64) f64 {
	if y.len < x.len {
		panic('dot_unitary: second vector is shorter than first')
	}
	mut acc0 := simd.splat_f64x4(0)
	mut acc1 := simd.splat_f64x4(0)
	mut i := 0
	for ; i + 8 <= x.len; i += 8 {
		acc0 += simd.load_f64x4_at(x, i) * simd.load_f64x4_at(y, i)
		acc1 += simd.load_f64x4_at(x, i + 4) * simd.load_f64x4_at(y, i + 4)
	}
	for ; i + 4 <= x.len; i += 4 {
		acc0 += simd.load_f64x4_at(x, i) * simd.load_f64x4_at(y, i)
	}
	lanes := (acc0 + acc1).to_array()
	mut sum := (lanes[0] + lanes[1]) + (lanes[2] + lanes[3])
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
