module la

import vsl.errno
import vsl.la.blas
import vsl.vmath

pub struct Matrix {
pub mut:
	m    int
	n    int
	data []f64
}

// matrix allocates a new (empty) Matrix with given (m,n) (row/col sizes)
pub fn new_matrix(m int, n int) Matrix {
	data := []f64{len: m * n}
	return Matrix{
		m: m
		n: n
		data: data
	}
}

// matrix_deep2 allocates a new Matrix from given (Deep2) nested slice.
// NOTE: make sure to have at least 1x1 item
pub fn matrix_deep2(a [][]f64) Matrix {
	mut o := new_matrix(a.len, a[0].len)
	o.set_from_deep2(a)
	return o
}

// matrix_raw creates a new Matrix using given raw data
// Input:
// rawdata -- data organized as column-major; e.g. Fortran format
// NOTE:
// (1) rawdata is not copied!
// (2) the external slice rawdata should not be changed or deleted
pub fn matrix_raw(m int, n int, rawdata []f64) Matrix {
	return Matrix{
		m: m
		n: n
		data: rawdata
	}
}

// set_from_deep2 sets matrix with data from a nested slice (Deep2) structure
pub fn (mut o Matrix) set_from_deep2(a [][]f64) {
	mut k := 0
	for j := 0; j < o.n; j++ {
		for i := 0; i < o.m; i++ {
			o.data[k] = a[i][j]
			k++
		}
	}
}

// set_diag sets diagonal matrix with diagonal components equal to val
pub fn (mut o Matrix) set_diag(val f64) {
	for i := 0; i < o.m; i++ {
		for j := 0; j < o.n; j++ {
			if i == j {
				o.data[i + j * o.m] = val
			} else {
				o.data[i + j * o.m] = 0
			}
		}
	}
}

// set sets value
pub fn (mut o Matrix) set(i int, j int, val f64) {
	o.data[i + j * o.m] = val // col-major
}

// get gets value
pub fn (o Matrix) get(i int, j int) f64 {
	return o.data[i + j * o.m] // col-major
}

// get_deep2 returns nested slice representation
pub fn (o Matrix) get_deep2() [][]f64 {
	mut m := [][]f64{len: o.m, init: []f64{len: o.n}}
	for i := 0; i < o.m; i++ {
		for j := 0; j < o.n; j++ {
			m[i][j] = o.data[i + j * o.m]
		}
	}
	return m
}

// clone returns a copy of this matrix
pub fn (o Matrix) clone() Matrix {
	mut clone := new_matrix(o.m, o.n)
	clone.data = o.data.clone()
	return clone
}

// transpose returns the transpose matrix
pub fn (o Matrix) transpose() Matrix {
	mut tran := new_matrix(o.n, o.m)
	for i := 0; i < o.n; i++ {
		for j := 0; j < o.m; j++ {
			tran.set(i, j, o.get(j, i))
		}
	}
	return tran
}

// copy_into copies the scaled components of this matrix into another one (result)
// result := alpha * this   ⇒   result[ij] := alpha * this[ij]
pub fn (o Matrix) copy_into(mut result Matrix, alpha f64) {
	for k := 0; k < o.m * o.n; k++ {
		result.data[k] = alpha * o.data[k]
	}
}

// add adds value to (i,j) location
pub fn (mut o Matrix) add(i int, j int, val f64) {
	o.data[i + j * o.m] += val // col-major
}

// fill fills this matrix with a single number val
// aij = val
pub fn (mut o Matrix) fill(val f64) {
	for k := 0; k < o.m * o.n; k++ {
		o.data[k] = val
	}
}

/*
 * clear_rc clear rows and columns and set diagonal components
 *                _         _                                     _         _
 * Example:      |  1 2 3 4  |                                   |  1 2 3 4  |
 * A =           |  5 6 7 8  |  ⇒  clear([1,2], [], 1.0)  ⇒  A = |  0 1 0 0  |
 *               |_ 4 3 2 1 _|                                   |_ 0 0 1 0 _|
*/
pub fn (mut o Matrix) clear_rc(rows []int, cols []int, diag f64) {
	for r in rows {
		for j := 0; j < o.n; j++ {
			if r == j {
				o.set(r, j, diag)
			} else {
				o.set(r, j, 0.0)
			}
		}
	}
	for c in cols {
		for i := 0; i < o.m; i++ {
			if i == c {
				o.set(i, c, diag)
			} else {
				o.set(i, c, 0.0)
			}
		}
	}
}

/*
 * clear_bry clears boundaries
 *                _       _                          _       _
 * Example:      |  1 2 3  |                        |  1 0 0  |
 * A =           |  4 5 6  |  ⇒  clear(1.0)  ⇒  A = |  0 5 0  |
 *               |_ 7 8 9 _|                        |_ 0 0 1 _|
*/
pub fn (mut o Matrix) clear_bry(diag f64) {
	o.clear_rc([0, o.m - 1], [0, o.n - 1], diag)
}

// max_diff returns the maximum difference between the components of this and another matrix
pub fn (o Matrix) max_diff(another Matrix) f64 {
	mut maxdiff := vmath.abs(o.data[0] - another.data[0])
	for k := 1; k < o.m * o.n; k++ {
		diff := vmath.abs(o.data[k] - another.data[k])
		if diff > maxdiff {
			maxdiff = diff
		}
	}
	return maxdiff
}

// largest returns the largest component |a[ij]| of this matrix, normalised by den
// largest := |a[ij]| / den
pub fn (o Matrix) largest(den f64) f64 {
	mut largest := vmath.abs(o.data[0])
	for k := 1; k < o.m * o.n; k++ {
		tmp := vmath.abs(o.data[k])
		if tmp > largest {
			largest = tmp
		}
	}
	return largest / den
}

// col access column j of this matrix. No copies are made since the internal data are in
// col-major format already.
// NOTE: this method can be used to modify the columns; e.g. with o.col(0)[0] = 123
pub fn (o Matrix) col(j int) []f64 {
	return o.data[(j * o.m)..((j + 1) * o.m)]
}

// get_row returns row i of this matrix
pub fn (o Matrix) get_row(i int) []f64 {
	mut row := []f64{len: o.n}
	for j := 0; j < o.n; j++ {
		row[j] = o.data[i + j * o.m]
	}
	return row
}

// get_col returns column j of this matrix
pub fn (o Matrix) get_col(j int) []f64 {
	return o.data[(j * o.m)..((j + 1) * o.m)]
}

// extract_cols returns columns from j=start to j=endp1-1
// start -- first column
// endp1 -- "end-plus-one", the number of the last requested column + 1
pub fn (o Matrix) extract_cols(start int, endp1 int) Matrix {
	if endp1 <= start {
		errno.vsl_panic("endp1 'end-plus-one' must be greater than start. start=$start, endp1=$endp1 invalid",
			.efailed)
	}
	ncol := endp1 - start
	mut reduced := new_matrix(o.m, ncol)
	reduced.data = o.data[start * o.m..endp1 * o.m]
	return reduced
}

// set_col sets the values of a column j with a single value
pub fn (mut o Matrix) set_col(j int, value f64) {
	for k := j * o.m; k < (j + 1) * o.m; k++ {
		o.data[k] = value
	}
}

// norm_frob returns the Frobenius norm of this matrix
// nrm := ‖a‖_F = sqrt(Σ_i Σ_j a[ij]⋅a[ij]) = ‖a‖_2
pub fn (o Matrix) norm_frob() f64 {
	mut nrm := 0.0
	for k := 0; k < o.m * o.n; k++ {
		nrm += o.data[k] * o.data[k]
	}
	return vmath.sqrt(nrm)
}

// norm_inf returns the infinite norm of this matrix
// nrm := ‖a‖_∞ = max_i ( Σ_j a[ij] )
pub fn (o Matrix) norm_inf() f64 {
	mut nrm := 0.0
	for j := 0; j < o.n; j++ { // sum first row
		nrm += vmath.abs(o.data[j * o.m])
	}
	mut sumrow := 0.0
	for i := 1; i < o.m; i++ {
		sumrow = 0.0
		for j := 0; j < o.n; j++ { // sum the other rows
			sumrow += vmath.abs(o.data[i + j * o.m])
			if sumrow > nrm {
				nrm = sumrow
			}
		}
	}
	return nrm
}

// apply sets this matrix with the scaled components of another matrix
// this := alpha * another   ⇒   this[i] := alpha * another[i]
// NOTE: "another" may be "this"
pub fn (mut o Matrix) apply(alpha f64, another Matrix) {
	for k := 0; k < o.m * o.n; k++ {
		o.data[k] = alpha * another.data[k]
	}
}

// det computes the determinant of matrix using the LU factorization
// NOTE: this method may fail due to overflow...
pub fn (o Matrix) det() f64 {
	if o.m != o.n {
		errno.vsl_panic('matrix must be square to compute determinant. $o.m × $o.n is invalid\n',
			.efailed)
	}
	mut ai := o.data.clone()
	ipiv := []int{len: int(vmath.min(o.m, o.n))}
	blas.dgetrf(o.m, o.n, mut ai, o.m, ipiv) // NOTE: ipiv are 1-based indices
	mut det := 1.0
	for i := 0; i < o.m; i++ {
		if ipiv[i] - 1 == i { // NOTE: ipiv are 1-based indices
			det = det * ai[i + i * o.m]
		} else {
			det = -det * ai[i + i * o.m]
		}
	}
	return det
}

[inline]
pub fn (o Matrix) str() string {
	return o.print('')
}

// print prints matrix (without commas or brackets)
pub fn (o Matrix) print(nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%g '
	}
	mut l := ''
	for i := 0; i < o.m; i++ {
		if i > 0 {
			l += '\n'
		}
		for j := 0; j < o.n; j++ {
			l += safe_print(nfmt, o.get(i, j))
		}
	}
	return l
}

// print_v prints matrix in V format
pub fn (o Matrix) print_v(nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := '[][]f64{\n'
	for i := 0; i < o.m; i++ {
		l += '    {'
		for j := 0; j < o.n; j++ {
			if j > 0 {
				l += ','
			}
			l += safe_print(nfmt, o.get(i, j))
		}
		l += '},\n'
	}
	l += '}'
	return l
}

// print_py prints matrix in Python format
pub fn (o Matrix) print_py(nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := 'np.matrix([\n'
	for i := 0; i < o.m; i++ {
		l += '    ['
		for j := 0; j < o.n; j++ {
			if j > 0 {
				l += ','
			}
			l += safe_print(nfmt, o.get(i, j))
		}
		l += '],\n'
	}
	l += '], dtype=float)'
	return l
}

[inline]
pub fn safe_print<T>(format string, message T) string {
	buf := [byte(0)]
	mut ptr := &buf[0]
	unsafe { C.sprintf(charptr(ptr), charptr(format.str), message) }
	return tos(buf.data, vstrlen(buf.data))
}
