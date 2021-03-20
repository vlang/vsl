module blas

import strconv
import vsl.vmath
import vsl.vmath.complex
import vsl.errno

pub const (
	lapack_row_major    = 101
	lapack_col_major    = 102
	cblas_row_major     = u32(101)
	cblas_col_major     = u32(102)
	cblas_no_trans      = u32(111)
	cblas_trans         = u32(112)
	cblas_conj_trans    = u32(113)
	cblas_conj_no_trans = u32(114)
	cblas_upper         = u32(121)
	cblas_lower         = u32(122)
	cblas_non_unit      = u32(131)
	cblas_unit          = u32(132)
	cblas_left          = u32(141)
	cblas_right         = u32(142)
)

pub fn c_trans(trans bool) u32 {
	if trans {
		return blas.cblas_trans
	}
	return blas.cblas_no_trans
}

pub fn c_uplo(up bool) u32 {
	if up {
		return blas.cblas_upper
	}
	return blas.cblas_lower
}

pub fn l_uplo(up bool) byte {
	if up {
		return `U`
	}
	return `L`
}

pub fn job_vlr(doCalc bool) byte {
	if doCalc {
		return `V`
	}
	return `N`
}

// slice_to_col_major converts nested slice into an array representing a col-major matrix
//
// _**NOTE**: make sure to have at least 1x1 item_
pub fn slice_to_col_major(a [][]f64) []f64 {
	m := a.len
	n := a[0].len
	mut data := []f64{len: m * n}
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
pub fn col_major_to_slice(m int, n int, data []f64) [][]f64 {
	mut a := [][]f64{len: n, init: []f64{len: n}}
	for i := 0; i < m; i++ {
		for j := 0; j < n; j++ {
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
	for i := 0; i < m; i++ {
		if i > 0 {
			l += '\n'
		}
		for j := 0; j < n; j++ {
			l += strconv.v_sprintf(nfmt, data[i + j * m])
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
	for i := 0; i < m; i++ {
		l += '    {'
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			l += strconv.v_sprintf(nfmt, data[i + j * m])
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
	for i := 0; i < m; i++ {
		l += '    ['
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			l += strconv.v_sprintf(nfmt, data[i + j * m])
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
	for j := 0; j < n; j++ {
		for i := 0; i < m; i++ {
			data[k] = a[i][j]
			k++
		}
	}
	return data
}

// col_major_complex_to_slice converts col-major matrix to nested slice
pub fn col_major_complex_to_slice(m int, n int, data []complex.Complex) [][]complex.Complex {
	mut a := [][]complex.Complex{len: m, init: []complex.Complex{len: n}}
	for i := 0; i < m; i++ {
		for j := 0; j < n; j++ {
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
	for i := 0; i < m; i++ {
		if i > 0 {
			l += '\n'
		}
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ', '
			}
			v := data[i + j * m]
			l += strconv.v_sprintf(nfmt_r, v.re) + strconv.v_sprintf(nfmt_i, v.im) + 'i'
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
	for i := 0; i < m; i++ {
		l += '    {'
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			v := data[i + j * m]
			l += strconv.v_sprintf(nfmt_r, v.re) + strconv.v_sprintf(nfmt_i, v.im) + 'i'
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
	for i := 0; i < m; i++ {
		l += '    ['
		for j := 0; j < n; j++ {
			if j > 0 {
				l += ','
			}
			v := data[i + j * m]
			l += strconv.v_sprintf(nfmt_r, v.re) + strconv.v_sprintf(nfmt_i, v.im) + 'j'
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
pub fn extract_row(i int, m int, n int, A []f64) []f64 {
	mut rowi := []f64{len: n}
	for j := 0; j < n; j++ {
		rowi[j] = A[i + j * m]
	}
	return rowi
}

// extract_col extracts j column from (m,n) col-major matrix
pub fn extract_col(j int, m int, n int, A []f64) []f64 {
	mut colj := []f64{len: m}
	for i := 0; i < m; i++ {
		colj[i] = A[i + j * m]
	}
	return colj
}

// extract_row_complex extracts i row from (m,n) col-major matrix (complex version)
pub fn extract_row_complex(i int, m int, n int, A []complex.Complex) []complex.Complex {
	mut rowi := []complex.Complex{len: n}
	for j := 0; j < n; j++ {
		rowi[j] = A[i + j * m]
	}
	return rowi
}

// extract_col_complex extracts j column from (m,n) col-major matrix (complex version)
pub fn extract_col_complex(j int, m int, n int, A []complex.Complex) []complex.Complex {
	mut colj := []complex.Complex{len: m}
	for i := 0; i < m; i++ {
		colj[i] = A[i + j * m]
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
		if vmath.abs(wi[j]) > 0.0 {
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
		if vmath.abs(wi[j]) > 0.0 {
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
