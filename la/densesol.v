module la

import vsl.blas

// den_solve solves dense linear system using LAPACK (OpenBLaS)
//
//   Given:  a ⋅ x = b    find x   such that   x = a⁻¹ ⋅ b
//
pub fn den_solve(mut x []f64, a Matrix, b []f64, preserve_a bool) {
	mut a_ := a.transpose()
	if preserve_a {
		a_ = new_matrix(a.m, a.n)
		a_.data = a.transpose().data.clone()
	}
	for i in 0 .. x.len {
		x[i] = b[i]
	}
	ipiv := []int{len: a_.m}
	blas.dgesv(a_.m, 1, mut a_.data, a_.m, ipiv, mut x, 1)
}
