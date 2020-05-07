// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module blas

import vsl.math
import vsl.math.complex
import vsl.io
import vsl.errno

// slice_to_col_major converts nested slice into an array representing a col-major matrix
//
//
// NOTE: make sure to have at least 1x1 item
pub fn slice_to_col_major(a [][]f64) []f64 {
	m := a.len
	n := a[0].len
	mut data := [0.0].repeat(m * n)
	mut k := 0
	for j := 0; j < n; j++ {
		for i := 0; i < m; i++ {
			data[k] = a[i][j]
			k++
		}
	}
	return data
}

// col_major_to_slice converts col-major matrix to nested slice
pub fn col_major_to_slice(m, n int, data []f64) [][]f64 {
	mut a := [[]f64{}].repeat(n)
	for i := 0; i < m; i++ {
		a[i] = [0.0].repeat(n)
		for j := 0; j < n; j++ {
			a[i][j] = data[i + j * m]
		}
	}
	return a
}

// print_col_major prints matrix (without commas or brackets)
pub fn print_col_major(m, n int, data []f64, nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%g '
	}
	mut l := ''
	for i := 0; i < m; i++ {
		if i > 0 {
			l += '\n'
		}
		for j := 0; j < n; j++ {
			l += io.safe_print_f64(nfmt, data[i + j * m])
		}
	}
	return l
}

// print_col_major_v prints matrix in v format
pub fn print_col_major_v(m, n int, data []f64, nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := '[][]f64{\n'
	for i := 0; i < m; i++ {
		l += '    {'
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			l += io.safe_print_f64(nfmt, data[i + j * m])
		}
		l += '},\n'
	}
	l += '}'
	return l
}

// print_col_major_py prints matrix in Python format
pub fn print_col_major_py(m, n int, data []f64, nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := 'np.matrix([\n'
	for i := 0; i < m; i++ {
		l += '    ['
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			l += io.safe_print_f64(nfmt, data[i + j * m])
		}
		l += '],\n'
	}
	l += '], dtype=float)'
	return l
}

// complex ///////////////////////////////////////////////////////////////////////////////////////
// slice_to_col_major_complex converts nested slice into an array representing a col-major matrix of
// complex numbers.
//
// Example:
// _            _
// |  0+0i  3+3i  |
// a = |  1+1i  4+4i  |          ⇒   data = [0+0i, 1+1i, 2+2i, 3+3i, 4+4i, 5+5i]
// |_ 2+2i  5+5i _|(m x n)
//
// data[i+j*m] = a[i][j]
//
// NOTE: make sure to have at least 1x1 item
pub fn slice_to_col_major_complex(a []complex.Complex) []complex.Complex {
	m := a.len
	n := a[0].len
	mut data := [complex.complex(0.0, 0.0)].repeat(m * n)
	mut k := 0
	for j := 0; j < n; j++ {
		for i := 0; i < m; i++ {
			data[k] = a[i][j]
			k++
		}
	}
	return data
}

// col_major_complex_to_slice converts col-major matrix to nested slice
pub fn col_major_complex_to_slice(m, n int, data []complex.Complex) []complex.Complex {
	mut a := [[]complex.Complex{}].repeat(m)
	for i := 0; i < m; i++ {
		a[i] = [complex.complex(0.0, 0.0)].repeat(n)
		for j := 0; j < n; j++ {
			a[i][j] = data[i + j * m]
		}
	}
	return a
}

// print_col_major_complex prints matrix (without commas or brackets).
// NOTE: if non-empty, nfmt_i must have '+' e.g. %+g
pub fn print_col_major_complex(m, n int, data []complex.Complex, nfmt_r_, nfmt_i_ string) string {
	mut nfmt_r := nfmt_r_
	mut nfmt_i := nfmt_i_
	if nfmt_r == '' {
		nfmt_r = '%g'
	}
	if nfmt_i == '' {
		nfmt_i = '%+g'
	}
	if !nfmt_i.contains('+') {
		nfmt_i = nfmt_i.replace('%', '%+')
	}
	mut l := ''
	for i := 0; i < m; i++ {
		if i > 0 {
			l += '\n'
		}
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ', '
			}
			v := data[i + j * m]
			l += io.safe_print_f64(nfmt_r, v.re) + io.safe_print_f64(nfmt_i, v.im) + 'i'
		}
	}
	return l
}

// print_col_major_complex_v prints matrix in v format
// NOTE: if non-empty, nfmt_i must have '+' e.g. %+g
pub fn print_col_major_complex_v(m, n int, data []complex.Complex, nfmt_r_, nfmt_i_ string) string {
	mut nfmt_r := nfmt_r_
	mut nfmt_i := nfmt_i_
	if nfmt_r == '' {
		nfmt_r = '%g'
	}
	if nfmt_i == '' {
		nfmt_i = '%+g'
	}
	if !nfmt_i.contains('+') {
		nfmt_i = nfmt_i.replace('%', '%+')
	}
	mut l := '[][]cplx.Complex{\n'
	for i := 0; i < m; i++ {
		l += '    {'
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			v := data[i + j * m]
			l += io.safe_print_f64(nfmt_r, v.re) + io.safe_print_f64(nfmt_i, v.im) + 'i'
		}
		l += '},\n'
	}
	l += '}'
	return l
}

// print_col_major_omplex_py prints matrix in Python format
// NOTE: if non-empty, nfmt_i must have '+' e.g. %+g
pub fn print_col_major_omplex_py(m, n int, data []complex.Complex, nfmt_r_, nfmt_i_ string) string {
	mut nfmt_r := nfmt_r_
	mut nfmt_i := nfmt_i_
	if nfmt_r == '' {
		nfmt_r = '%g'
	}
	if nfmt_i == '' {
		nfmt_i = '%+g'
	}
	if !nfmt_i.contains('+') {
		nfmt_i = nfmt_i.replace('%', '%+')
	}
	mut l := 'np.matrix([\n'
	for i := 0; i < m; i++ {
		l += '    ['
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			v := data[i + j * m]
			l += io.safe_print_f64(nfmt_r, v.re) + io.safe_print_f64(nfmt_i, v.im) + 'j'
		}
		l += '],\n'
	}
	l += '], dtype=complex)'
	return l
}

// complex arrays //////////////////////////////////////////////////////////////////////////////////
// get_join_complex joins real and imag parts of array
pub fn get_join_complex(v_real, v_imag []f64) []complex.Complex {
	mut v := [complex.complex(0.0, 0.0)].repeat(v_real.len)
	for i := 0; i < v_real.len; i++ {
		v[i] = complex.complex(v_real[i], v_imag[i])
	}
	return v
}

// get_split_complex splits real and imag parts of array
pub fn get_split_complex(v []complex.Complex) ([]f64, []f64) {
	mut v_real := [0.0].repeat(v.len)
	mut v_imag := [0.0].repeat(v.len)
	for i := 0; i < v.len; i++ {
		v_real[i] = v[i].re
		v_imag[i] = v[i].im
	}
	return v_real, v_imag
}

// join_complex joins real and imag parts of array
pub fn join_complex(v_real, v_imag []f64) []complex.Complex {
	mut v := [complex.complex(0.0, 0.0)].repeat(v_real.len)
	for i := 0; i < v_real.len; i++ {
		v[i] = complex.complex(v_real[i], v_imag[i])
	}
	return v
}

// split_complex splits real and imag parts of array
pub fn split_complex(v []complex.Complex) ([]f64, []f64) {
	mut v_real := [0.0].repeat(v.len)
	mut v_imag := [0.0].repeat(v.len)
	for i := 0; i < v.len; i++ {
		v_real[i] = v[i].re
		v_imag[i] = v[i].im
	}
	return v_real, v_imag
}

// extraction //////////////////////////////////////////////////////////////////////////////////////
// extract_row extracts i row from (m,n) col-major matrix
pub fn extract_row(i, m, n int, A []f64) []f64 {
	mut rowi := [0.0].repeat(n)
	for j := 0; j < n; j++ {
		rowi[j] = A[i + j * m]
	}
	return rowi
}

// extract_col extracts j column from (m,n) col-major matrix
pub fn extract_col(j, m, n int, A []f64) []f64 {
	mut colj := [0.0].repeat(m)
	for i := 0; i < m; i++ {
		colj[i] = A[i + j * m]
	}
	return colj
}

// extract_row_complex extracts i row from (m,n) col-major matrix (complex version)
pub fn extract_row_complex(i, m, n int, A []complex.Complex) []complex.Complex {
	mut rowi := [complex.complex(0.0, 0.0)].repeat(n)
	for j := 0; j < n; j++ {
		rowi[j] = A[i + j * m]
	}
	return rowi
}

// extract_col_complex extracts j column from (m,n) col-major matrix (complex version)
pub fn extract_col_complex(j, m, n int, A []complex.Complex) []complex.Complex {
	mut colj := [complex.complex(0.0, 0.0)].repeat(m)
	for i := 0; i < m; i++ {
		colj[i] = A[i + j * m]
	}
	return colj
}

// eigenvector matrices ////////////////////////////////////////////////////////////////////////////
// eigenvecs_build builds complex eigenvectros created by Dgeev function
// INPUT:
// wr, wi -- real and imag parts of eigenvalues
// v      -- left or right eigenvectors from Dgeev
// OUTPUT:
// vv -- complex version of left or right eigenvector [pre-allocated]
// NOTE (no checks made)
// n = wr.len = wi.len = v.len
// 2 * n = len(vv)
pub fn eigenvecs_build(mut vv []complex.Complex, wr, wi, v []f64) {
	n := wr.len
	mut dj := 1 // increment for next conjugate pair
	for j := 0; j < n; j += dj {
		// loop over columns == eigenvalues
		if math.abs(wi[j]) > 0.0 {
			// eigenvalue is complex
			if j > n - 2 {
				errno.vsl_panic('last eigenvalue cannot be complex', .efailed)
			}
			for i := 0; i < n; i++ {
				// loop over rows
				p := i + j * n
				q := i + (j + 1) * n
				vv[p] = complex.complex(v[p], v[q])
				vv[q] = complex.complex(v[p], -v[q])
			}
			dj = 2
		} else {
			for i := 0; i < n; i++ {
				// loop over rows
				p := i + j * n
				vv[p] = complex.complex(v[p], 0.0)
			}
			dj = 1
		}
	}
}

// eigenvecs_build_both builds complex left and right eigenvectros created by Dgeev function
// INPUT:
// wr, wi -- real and imag parts of eigenvalues
// vl, vr -- left and right eigenvectors from Dgeev
// OUTPUT:
// vvl, vvr -- complex version of left and right eigenvectors [pre-allocated]
// NOTE (no checks made)
// n = wr.len = wi.len = len(vl) = len(vr)
// 2 * n = len(vvl) = len(vvr)
pub fn eigenvecs_build_both(mut vvl, mut vvr []complex.Complex, wr, wi, vl, vr []f64) {
	n := wr.len
	mut dj := 1 // increment for next conjugate pair
	for j := 0; j < n; j += dj {
		// loop over columns == eigenvalues
		if math.abs(wi[j]) > 0.0 {
			// eigenvalue is complex
			if j > n - 2 {
				errno.vsl_panic('last eigenvalue cannot be complex', .efailed)
			}
			for i := 0; i < n; i++ {
				// loop over rows
				p := i + j * n
				q := i + (j + 1) * n
				vvl[p] = complex.complex(vl[p], vl[q])
				vvr[p] = complex.complex(vr[p], vr[q])
				vvl[q] = complex.complex(vl[p], -vl[q])
				vvr[q] = complex.complex(vr[p], -vr[q])
			}
			dj = 2
		} else {
			for i := 0; i < n; i++ {
				// loop over rows
				p := i + j * n
				vvl[p] = complex.complex(vl[p], 0.0)
				vvr[p] = complex.complex(vr[p], 0.0)
			}
			dj = 1
		}
	}
}
