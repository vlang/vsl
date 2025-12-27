module blas

import strconv
import math
import math.complex
import vsl.errors
import vsl.blas.blas64

// MemoryLayout is used to specify the memory layout of a matrix.
pub enum MemoryLayout {
	row_major = 101
	col_major = 102
}

// Transpose is used to specify the transposition of a matrix.
pub enum Transpose {
	no_trans      = 111
	trans         = 112
	conj_trans    = 113
	conj_no_trans = 114
}

// Uplo is used to specify whether the upper or lower triangle of a matrix is
pub enum Uplo {
	upper = 121
	lower = 122
	all   = 99
}

// Diagonal is used to specify whether the diagonal of a matrix is unit or non-unit.
pub enum Diagonal {
	non_unit = 131
	unit     = 132
}

// Side is used to specify whether a matrix is on the left or right side in a matrix-matrix multiplication.
pub enum Side {
	left  = 141
	right = 142
}

// slice_to_col_major converts nested slice into an array representing a col-major matrix
//
// _**NOTE**: make sure to have at least 1x1 item_
pub fn slice_to_col_major(a [][]f64) []f64 {
	m := a.len
	n := a[0].len
	mut data := []f64{len: m * n}
	mut k := 0
	for j in 0 .. n {
		for i in 0 .. m {
			data[k] = a[i][j]
			k++
		}
	}
	return data
}

// col_major_to_slice converts col-major matrix to nested slice
pub fn col_major_to_slice(m int, n int, data []f64) [][]f64 {
	mut a := [][]f64{len: n, init: []f64{len: n}}
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = data[i + j * m]
		}
	}
	return a
}

// print_col_major prints matrix (without commas or brackets)
pub fn print_col_major(m int, n int, data []f64, nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%g '
	}
	mut l := ''
	for i in 0 .. m {
		if i > 0 {
			l += '\n'
		}
		for j in 0 .. n {
			l += unsafe { strconv.v_sprintf(nfmt, data[i + j * m]) }
		}
	}
	return l
}

// print_col_major_v prints matrix in v format
pub fn print_col_major_v(m int, n int, data []f64, nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := '[][]f64{\n'
	for i in 0 .. m {
		l += '    {'
		for j in 0 .. n {
			if j > 0 {
				l += ','
			}
			l += unsafe { strconv.v_sprintf(nfmt, data[i + j * m]) }
		}
		l += '},\n'
	}
	l += '}'
	return l
}

// print_col_major_py prints matrix in Python format
pub fn print_col_major_py(m int, n int, data []f64, nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := 'np.matrix([\n'
	for i in 0 .. m {
		l += '    ['
		for j in 0 .. n {
			if j > 0 {
				l += ','
			}
			l += unsafe { strconv.v_sprintf(nfmt, data[i + j * m]) }
		}
		l += '],\n'
	}
	l += '], dtype=float)'
	return l
}

// slice_to_col_major_complex converts nested slice into an array representing a col-major matrix of
// complex numbers.
//
// `data[i+j*m] = a[i][j]`
//
// _**NOTE**: make sure to have at least 1x1 item_
pub fn slice_to_col_major_complex(a [][]complex.Complex) []complex.Complex {
	m := a.len
	n := a[0].len
	mut data := []complex.Complex{len: m * n}
	mut k := 0
	for j in 0 .. n {
		for i in 0 .. m {
			data[k] = a[i][j]
			k++
		}
	}
	return data
}

// col_major_complex_to_slice converts col-major matrix to nested slice
pub fn col_major_complex_to_slice(m int, n int, data []complex.Complex) [][]complex.Complex {
	mut a := [][]complex.Complex{len: m, init: []complex.Complex{len: n}}
	for i in 0 .. m {
		for j in 0 .. n {
			a[i][j] = data[i + j * m]
		}
	}
	return a
}

// print_col_major_complex prints matrix (without commas or brackets).
// _**NOTE**: if non-empty, nfmt_i must have '+' e.g. %+g_
pub fn print_col_major_complex(m int, n int, data []complex.Complex, nfmt_r_ string, nfmt_i_ string) string {
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
	for i in 0 .. m {
		if i > 0 {
			l += '\n'
		}
		for j in 0 .. n {
			if j > 0 {
				l += ', '
			}
			v := data[i + j * m]
			l += unsafe { strconv.v_sprintf(nfmt_r, v.re) + strconv.v_sprintf(nfmt_i, v.im) + 'i' }
		}
	}
	return l
}

// print_col_major_complex_v prints matrix in v format
// _**NOTE**: if non-empty, nfmt_i must have '+' e.g. %+g_
pub fn print_col_major_complex_v(m int, n int, data []complex.Complex, nfmt_r_ string, nfmt_i_ string) string {
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
	for i in 0 .. m {
		l += '    {'
		for j in 0 .. n {
			if j > 0 {
				l += ','
			}
			v := data[i + j * m]
			l += unsafe { strconv.v_sprintf(nfmt_r, v.re) + strconv.v_sprintf(nfmt_i, v.im) + 'i' }
		}
		l += '},\n'
	}
	l += '}'
	return l
}

// print_col_major_omplex_py prints matrix in Python format
// _**NOTE**: if non-empty, nfmt_i must have '+' e.g. %+g_
pub fn print_col_major_omplex_py(m int, n int, data []complex.Complex, nfmt_r_ string, nfmt_i_ string) string {
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
	for i in 0 .. m {
		l += '    ['
		for j in 0 .. n {
			if j > 0 {
				l += ','
			}
			v := data[i + j * m]
			l += unsafe { strconv.v_sprintf(nfmt_r, v.re) + strconv.v_sprintf(nfmt_i, v.im) + 'j' }
		}
		l += '],\n'
	}
	l += '], dtype=complex)'
	return l
}

// get_join_complex joins real and imag parts of array
pub fn get_join_complex(v_real []f64, v_imag []f64) []complex.Complex {
	mut v := []complex.Complex{len: v_real.len}
	for i := 0; i < v_real.len; i++ {
		v[i] = complex.complex(v_real[i], v_imag[i])
	}
	return v
}

// get_split_complex splits real and imag parts of array
pub fn get_split_complex(v []complex.Complex) ([]f64, []f64) {
	mut v_real := []f64{len: v.len}
	mut v_imag := []f64{len: v.len}
	for i := 0; i < v.len; i++ {
		v_real[i] = v[i].re
		v_imag[i] = v[i].im
	}
	return v_real, v_imag
}

// join_complex joins real and imag parts of array
pub fn join_complex(v_real []f64, v_imag []f64) []complex.Complex {
	mut v := []complex.Complex{len: v_real.len}
	for i := 0; i < v_real.len; i++ {
		v[i] = complex.complex(v_real[i], v_imag[i])
	}
	return v
}

// split_complex splits real and imag parts of array
pub fn split_complex(v []complex.Complex) ([]f64, []f64) {
	mut v_real := []f64{len: v.len}
	mut v_imag := []f64{len: v.len}
	for i := 0; i < v.len; i++ {
		v_real[i] = v[i].re
		v_imag[i] = v[i].im
	}
	return v_real, v_imag
}

// extract_row extracts i row from (m,n) col-major matrix
pub fn extract_row(i int, m int, n int, a []f64) []f64 {
	mut rowi := []f64{len: n}
	for j in 0 .. n {
		rowi[j] = a[i + j * m]
	}
	return rowi
}

// extract_col extracts j column from (m,n) col-major matrix
pub fn extract_col(j int, m int, n int, a []f64) []f64 {
	mut colj := []f64{len: m}
	for i in 0 .. m {
		colj[i] = a[i + j * m]
	}
	return colj
}

// extract_row_complex extracts i row from (m,n) col-major matrix (complex version)
pub fn extract_row_complex(i int, m int, n int, a []complex.Complex) []complex.Complex {
	mut rowi := []complex.Complex{len: n}
	for j in 0 .. n {
		rowi[j] = a[i + j * m]
	}
	return rowi
}

// extract_col_complex extracts j column from (m,n) col-major matrix (complex version)
pub fn extract_col_complex(j int, m int, n int, a []complex.Complex) []complex.Complex {
	mut colj := []complex.Complex{len: m}
	for i in 0 .. m {
		colj[i] = a[i + j * m]
	}
	return colj
}

// eigenvecs_build builds complex eigenvectros created by Dgeev function
//
// **input:**
// `wr`, `wi`: real and imag parts of eigenvalues.
// `v`: left or right eigenvectors from Dgeev.
//
// **output:**
// `vv`: complex version of left or right eigenvector [pre-allocated].
//
// _**NOTE**: (no checks made)_.
//
// `n = wr.len = wi.len = v.len`
// `2 * n = vv.len`
pub fn eigenvecs_build(mut vv []complex.Complex, wr []f64, wi []f64, v []f64) {
	n := wr.len
	mut dj := 1 // increment for next conjugate pair
	for j := 0; j < n; j += dj {
		// loop over columns == eigenvalues
		if math.abs(wi[j]) > 0.0 {
			// eigenvalue is complex
			if j > n - 2 {
				errors.vsl_panic('last eigenvalue cannot be complex', .efailed)
			}
			for i in 0 .. n {
				// loop over rows
				p := i + j * n
				q := i + (j + 1) * n
				vv[p] = complex.complex(v[p], v[q])
				vv[q] = complex.complex(v[p], -v[q])
			}
			dj = 2
		} else {
			for i in 0 .. n {
				// loop over rows
				p := i + j * n
				vv[p] = complex.complex(v[p], 0.0)
			}
			dj = 1
		}
	}
}

// eigenvecs_build_both builds complex left and right eigenvectros created by Dgeev function
//
// **input:**
// `wr`, `wi`:real and imag parts of eigenvalues.
// `vl`, `vr`:left and right eigenvectors from Dgeev.
//
// **output:**
// `vvl`, `vvr`:complex version of left and right eigenvectors [pre-allocated].
//
// _**NOTE**: (no checks made)_.
//
// `n = wr.len = wi.len = vl.len = vr.len`
// `2 * n = vvl.len = vvr.len`
pub fn eigenvecs_build_both(mut vvl []complex.Complex, mut vvr []complex.Complex, wr []f64, wi []f64, vl []f64, vr []f64) {
	n := wr.len
	mut dj := 1 // increment for next conjugate pair
	for j := 0; j < n; j += dj {
		// loop over columns == eigenvalues
		if math.abs(wi[j]) > 0.0 {
			// eigenvalue is complex
			if j > n - 2 {
				errors.vsl_panic('last eigenvalue cannot be complex', .efailed)
			}
			for i in 0 .. n {
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
			for i in 0 .. n {
				// loop over rows
				p := i + j * n
				vvl[p] = complex.complex(vl[p], 0.0)
				vvr[p] = complex.complex(vr[p], 0.0)
			}
			dj = 1
		}
	}
}

// ========================================================================
// ENUM CONVERSION FUNCTIONS
// ========================================================================
// These functions provide explicit conversion between VSL enum types and
// the underlying blas64 enum types. This is necessary because V's enum
// type aliases don't work as expected - they're treated as distinct types.

// Convert VSL MemoryLayout to blas64.MemoryLayout
pub fn to_blas64_layout(layout MemoryLayout) blas64.MemoryLayout {
	return match layout {
		.row_major { blas64.MemoryLayout.row_major }
		.col_major { blas64.MemoryLayout.col_major }
	}
}

// Convert blas64.MemoryLayout to VSL MemoryLayout
pub fn from_blas64_layout(layout blas64.MemoryLayout) MemoryLayout {
	return match layout {
		.row_major { MemoryLayout.row_major }
		.col_major { MemoryLayout.col_major }
	}
}

// Convert VSL Transpose to blas64.Transpose
pub fn to_blas64_transpose(trans Transpose) blas64.Transpose {
	return match trans {
		.no_trans { blas64.Transpose.no_trans }
		.trans { blas64.Transpose.trans }
		.conj_trans { blas64.Transpose.conj_trans }
		.conj_no_trans { blas64.Transpose.conj_no_trans }
	}
}

// Convert blas64.Transpose to VSL Transpose
pub fn from_blas64_transpose(trans blas64.Transpose) Transpose {
	return match trans {
		.no_trans { Transpose.no_trans }
		.trans { Transpose.trans }
		.conj_trans { Transpose.conj_trans }
		.conj_no_trans { Transpose.conj_no_trans }
	}
}

// Convert VSL Uplo to blas64.Uplo
pub fn to_blas64_uplo(uplo Uplo) blas64.Uplo {
	return match uplo {
		.upper { blas64.Uplo.upper }
		.lower { blas64.Uplo.lower }
		.all { blas64.Uplo.all }
	}
}

// Convert blas64.Uplo to VSL Uplo
pub fn from_blas64_uplo(uplo blas64.Uplo) Uplo {
	return match uplo {
		.upper { Uplo.upper }
		.lower { Uplo.lower }
		.all { Uplo.all }
	}
}

// Convert VSL Diagonal to blas64.Diagonal
pub fn to_blas64_diagonal(diag Diagonal) blas64.Diagonal {
	return match diag {
		.non_unit { blas64.Diagonal.non_unit }
		.unit { blas64.Diagonal.unit }
	}
}

// Convert blas64.Diagonal to VSL Diagonal
pub fn from_blas64_diagonal(diag blas64.Diagonal) Diagonal {
	return match diag {
		.non_unit { Diagonal.non_unit }
		.unit { Diagonal.unit }
	}
}

// Convert VSL Side to blas64.Side
pub fn to_blas64_side(side Side) blas64.Side {
	return match side {
		.left { blas64.Side.left }
		.right { blas64.Side.right }
	}
}

// Convert blas64.Side to VSL Side
pub fn from_blas64_side(side blas64.Side) Side {
	return match side {
		.left { Side.left }
		.right { Side.right }
	}
}
