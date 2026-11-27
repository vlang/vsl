module blas

// dot_i16_i64 computes an exact signed i16 dot product with an i64 accumulator.
pub fn dot_i16_i64(x []i16, y []i16) !i64 {
	if x.len != y.len {
		return error('dot_i16_i64: input lengths must match')
	}
	if x.len == 0 {
		return i64(0)
	}
	return C.vsl_blas_i16_dot_dispatch(x.len, &x[0], &y[0])
}
