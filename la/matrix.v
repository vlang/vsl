module la

import math
import strconv
import vsl.errors

@[heap]
pub struct Matrix[T] {
pub mut:
	m    int
	n    int
	data []T
}

// Matrix.new allocates a new (empty) Matrix with given (m,n) (row/col sizes)
pub fn Matrix.new[T](m int, n int) &Matrix[T] {
	data := []T{len: m * n}
	return &Matrix[T]{
		m: m
		n: n
		data: data
	}
}

// Matrix.deep2 allocates a new Matrix from given (Deep2) nested slice.
// NOTE: make sure to have at least 1x1 item
pub fn Matrix.deep2[T](a [][]T) &Matrix[T] {
	mut o := Matrix.new[T](a.len, a[0].len)
	o.set_from_deep2(a)
	return o
}

// Matrix.raw creates a new Matrix using given raw data
// Input:
// rawdata -- data organized as column-major; e.g. Fortran format
// NOTE:
// (1) rawdata is not copied!
// (2) the external slice rawdata should not be changed or deleted
pub fn Matrix.raw[T](m int, n int, rawdata []T) &Matrix[T] {
	return &Matrix[T]{
		m: m
		n: n
		data: rawdata
	}
}

// set_from_deep2 sets matrix with data from a nested slice (Deep2) structure
pub fn (mut o Matrix[T]) set_from_deep2(a [][]T) {
	mut k := 0
	for i in 0 .. o.m {
		for j in 0 .. o.n {
			o.data[k] = a[i][j]
			k++
		}
	}
}

// set_diag sets diagonal matrix with diagonal components equal to val
pub fn (mut o Matrix[T]) set_diag(val T) {
	for i in 0 .. o.m {
		for j in 0 .. o.n {
			if i == j {
				o.data[i * o.n + j] = val
			} else {
				o.data[i * o.n + j] = 0
			}
		}
	}
}

// set sets value
pub fn (mut o Matrix[T]) set(i int, j int, val T) {
	o.data[i * o.n + j] = val // row-major
}

// get gets value
pub fn (o &Matrix[T]) get(i int, j int) T {
	return o.data[i * o.n + j] // row-major
}

// get_deep2 returns nested slice representation
pub fn (o &Matrix[T]) get_deep2() [][]T {
	mut m := [][]T{len: o.m, init: []T{len: o.n}}
	for i in 0 .. o.m {
		for j in 0 .. o.n {
			m[i][j] = o.data[i * o.n + j]
		}
	}
	return m
}

// clone returns a copy of this matrix
pub fn (o &Matrix[T]) clone() &Matrix[T] {
	mut clone := Matrix.new[T](o.m, o.n)
	clone.data = o.data.clone()
	return clone
}

// transpose returns the transpose matrix
pub fn (o &Matrix[T]) transpose() &Matrix[T] {
	mut tran := Matrix.new[T](o.n, o.m)
	for i := 0; i < o.n; i++ {
		for j := 0; j < o.m; j++ {
			tran.set(i, j, o.get(j, i))
		}
	}
	return tran
}

// copy_into copies the scaled components of this matrix into another one (result)
// result := alpha * this   ⇒   result[ij] := alpha * this[ij]
pub fn (o &Matrix[T]) copy_into(mut result Matrix[T], alpha T) {
	for k in 0 .. o.m * o.n {
		result.data[k] = alpha * o.data[k]
	}
}

// add adds value to (i,j) location
pub fn (mut o Matrix[T]) add(i int, j int, val T) {
	o.data[i * o.n + j] += val // row-major
}

// fill fills this matrix with a single number val
// aij = val
pub fn (mut o Matrix[T]) fill(val T) {
	for k in 0 .. o.m * o.n {
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
pub fn (mut o Matrix[T]) clear_rc(rows []int, cols []int, diag T) {
	for r in rows {
		for j in 0 .. o.n {
			if r == j {
				o.set(r, j, diag)
			} else {
				o.set(r, j, 0.0)
			}
		}
	}
	for c in cols {
		for i in 0 .. o.m {
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
pub fn (mut o Matrix[T]) clear_bry(diag T) {
	o.clear_rc([0, o.m - 1], [0, o.n - 1], diag)
}

// max_diff returns the maximum difference between the components of this and another matrix
pub fn (o &Matrix[T]) max_diff(another &Matrix[T]) T {
	mut maxdiff := math.abs(o.data[0] - another.data[0])
	for k := 1; k < o.m * o.n; k++ {
		diff := math.abs(o.data[k] - another.data[k])
		if diff > maxdiff {
			maxdiff = diff
		}
	}
	return maxdiff
}

// largest returns the largest component |a[ij]| of this matrix, normalised by den
// largest := |a[ij]| / den
pub fn (o &Matrix[T]) largest(den T) T {
	mut largest := math.abs(o.data[0])
	for k := 1; k < o.m * o.n; k++ {
		tmp := math.abs(o.data[k])
		if tmp > largest {
			largest = tmp
		}
	}
	return largest / den
}

// col access column j of this matrix. No copies are made since the internal data are in
// row-major format already.
// NOTE: this method can be used to modify the columns; e.g. with o.col(0)[0] = 123
@[inline]
pub fn (o &Matrix[T]) col(j int) []T {
	return o.get_col(j)
}

// get_row returns row i of this matrix
pub fn (o &Matrix[T]) get_row(i int) []T {
	return o.data[(i * o.n)..((i + 1) * o.n)]
}

// get_col returns column j of this matrix
pub fn (o &Matrix[T]) get_col(j int) []T {
	mut col := []T{len: o.m}
	for i in 0 .. o.m {
		col[i] = o.data[i * o.n + j]
	}
	return col
}

// extract_cols returns columns from j=start to j=endp1-1
// start -- first column
// endp1 -- "end-plus-one", the number of the last requested column + 1
pub fn (o &Matrix[T]) extract_cols(start int, endp1 int) !&Matrix[T] {
	if endp1 <= start {
		return errors.error("endp1 'end-plus-one' must be greater than start. start=${start}, endp1=${endp1} invalid",
			.efailed)
	}
	ncol := endp1 - start
	mut reduced := Matrix.new[T](o.m, ncol)
	for i in 0 .. o.m {
		for j := 0; j < ncol; j++ {
			reduced.set(i, j, o.get(i, j + start))
		}
	}
	return reduced
}

// extract_rows returns rows from i=start to i=endp1-1
// start -- first column
// endp1 -- "end-plus-one", the number of the last requested column + 1
pub fn (o &Matrix[T]) extract_rows(start int, endp1 int) !&Matrix[T] {
	if endp1 <= start {
		return errors.error("endp1 'end-plus-one' must be greater than start. start=${start}, endp1=${endp1} invalid",
			.efailed)
	}
	nrow := endp1 - start
	mut reduced := Matrix.new[T](nrow, o.n)
	reduced.data = o.data[start * o.m..endp1 * o.m]
	return reduced
}

// set_row sets the values of a row i with a single value
pub fn (mut o Matrix[T]) set_row(i int, value T) {
	for k := i * o.m; k < (i + 1) * o.m; k++ {
		o.data[k] = value
	}
}

// set_col sets the values of a column j with a single value
pub fn (mut o Matrix[T]) set_col(j int, value T) {
	for i in 0 .. o.m {
		o.data[i * o.n + j] = value
	}
}

// split_by_col splits this matrix into two matrices at column j
// j -- column index
pub fn (o &Matrix[T]) split_by_col(j int) !(&Matrix[T], &Matrix[T]) {
	if j < 0 || j >= o.n {
		return errors.error('j=${j} must be in range [0, ${o.n})', .efailed)
	}
	mut left := Matrix.new[T](o.m, j)
	mut right := Matrix.new[T](o.m, o.n - j)
	for i in 0 .. o.m {
		for k := 0; k < j; k++ {
			left.set(i, k, o.get(i, k))
		}
		for k := j; k < o.n; k++ {
			right.set(i, k - j, o.get(i, k))
		}
	}
	return left, right
}

// split_by_row splits this matrix into two matrices at row i
// i -- row index
pub fn (o &Matrix[T]) split_by_row(i int) !(&Matrix[T], &Matrix[T]) {
	if i < 0 || i >= o.m {
		return errors.error('i=${i} must be in range [0, ${o.m})', .efailed)
	}
	mut top := Matrix.new[T](i, o.n)
	mut bottom := Matrix.new[T](o.m - i, o.n)
	for j in 0 .. o.n {
		for k := 0; k < i; k++ {
			top.set(k, j, o.get(k, j))
		}
		for k := i; k < o.m; k++ {
			bottom.set(k - i, j, o.get(k, j))
		}
	}
	return top, bottom
}

// norm_frob returns the Frobenius norm of this matrix
// nrm := ‖a‖_F = sqrt(Σ_i Σ_j a[ij]⋅a[ij]) = ‖a‖_2
pub fn (o &Matrix[T]) norm_frob() T {
	mut nrm := 0.0
	for k in 0 .. o.m * o.n {
		nrm += o.data[k] * o.data[k]
	}
	return math.sqrt(nrm)
}

// norm_inf returns the infinite norm of this matrix
// nrm := ‖a‖_∞ = max_i ( Σ_j a[ij] )
pub fn (o &Matrix[T]) norm_inf() T {
	mut nrm := 0.0
	for i := 0; i < o.n; i++ { // sum first row
		nrm += math.abs(o.data[i])
	}
	mut sumrow := 0.0
	for i := 1; i < o.m; i++ {
		sumrow = 0.0
		for j in 0 .. o.n { // sum the other rows
			sumrow += math.abs(o.data[i * o.n + j])
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
pub fn (mut o Matrix[T]) apply(alpha T, another &Matrix[T]) {
	for k in 0 .. o.m * o.n {
		o.data[k] = alpha * another.data[k]
	}
}

// equals returns true if this matrix is equal to another matrix
// this == another   ⇒   this[i] == another[i]
// NOTE: "another" may be "this"
pub fn (o &Matrix[T]) equals(another &Matrix[T]) bool {
	for k in 0 .. o.m * o.n {
		if o.data[k] != another.data[k] {
			return false
		}
	}
	return true
}

pub fn (o &Matrix[T]) str() string {
	return o.print('')
}

// print prints matrix (without commas or brackets)
pub fn (o &Matrix[T]) print(nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%g '
	}
	mut l := ''
	for i in 0 .. o.m {
		if i > 0 {
			l += '\n'
		}
		for j in 0 .. o.n {
			l += safe_print(nfmt, o.get(i, j))
		}
	}
	return l
}

// print_v prints matrix in V format
pub fn (o &Matrix[T]) print_v(nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := '[][]${T.name}{\n'
	for i in 0 .. o.m {
		l += '    {'
		for j in 0 .. o.n {
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
pub fn (o &Matrix[T]) print_py(nfmt_ string) string {
	mut nfmt := nfmt_
	if nfmt == '' {
		nfmt = '%10g'
	}
	mut l := 'np.matrix([\n'
	for i in 0 .. o.m {
		l += '    ['
		for j in 0 .. o.n {
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

@[inline]
pub fn safe_print[T](format string, message T) string {
	return unsafe { strconv.v_sprintf(format, message) }
}
