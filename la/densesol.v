module la

import vsl.vlas

// den_solve solves dense linear system using LAPACK (OpenBLaS)
//
//   Given:  a ⋅ x = b    find x   such that   x = a⁻¹ ⋅ b
//
pub fn den_solve(mut x []f64, a &Matrix[f64], b []f64, preserve_a bool) {
	mut a_ := unsafe { a }
	if preserve_a {
		a_ = Matrix.new[f64](a.m, a.n)
		a_.data = a.data.clone()
	}
	for i in 0 .. x.len {
		x[i] = b[i]
	}
	ipiv := []int{len: a_.m}
	vlas.dgesv(a_.m, 1, mut a_.data, a_.m, ipiv, mut x, 1)
}
