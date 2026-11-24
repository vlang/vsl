module la

import vsl.errors

// Triplet is a simple representation of a sparse matrix, where the indices and values
// of this matrix are stored directly.
pub struct Triplet[T] {
mut:
	// matrix dimension (rows, columns)
	m int
	n int
	// current position and max number of entries allowed (non-zeros, including repetitions)
	pos int
	max int
	// indices for each x values (size=max)
	i []int
	j []int
	// values for each i, j (size=max)
	x []T
}

// CCMatrix represents a sparse matrix using the so-called "column-compressed format".
pub struct CCMatrix[T] {
mut:
	// matrix dimension (rows, columns)
	m int
	n int
	// number of non-zeros
	nnz int
	// pointers and row indices (len(p)=n+1, len(i)=nnz)
	p []int
	i []int
	// values (len(x)=nnz)
	x []T
}

// CSRMatrix represents a sparse matrix in compressed sparse row format.
pub struct CSRMatrix[T] {
mut:
	// matrix dimension (rows, columns)
	m int
	n int
	// number of non-zeros
	nnz int
	// row pointers and column indices (len(p)=m+1, len(j)=nnz)
	p []int
	j []int
	// values (len(x)=nnz)
	x []T
}

// Triplet.new returns a new Triplet. This is a wrapper to new(Triplet) followed by init()
pub fn Triplet.new[T](m int, n int, max int) &Triplet[T] {
	mut o := &Triplet[T]{}
	o.init(m, n, max)
	return o
}

// init allocates all memory required to hold a sparse matrix in triplet form
pub fn (mut o Triplet[T]) init(m int, n int, max int) {
	o.m, o.n, o.pos, o.max = m, n, 0, max
	o.i = []int{len: max}
	o.j = []int{len: max}
	o.x = []T{len: max}
}

// put inserts an element to a pre-allocated (with init) triplet matrix
pub fn (mut o Triplet[T]) put(i int, j int, x T) ! {
	if i < 0 || i >= o.m {
		return errors.error('cannot put item because index of row is outside range (i=${i}, m=${o.m})',
			.erange)
	}
	if j < 0 || j >= o.n {
		return errors.error('cannot put item because index of columns is outside range (j=${j}, n=${o.n})',
			.erange)
	}
	if o.pos >= o.max {
		return errors.error('cannot put item because max number of items has been exceeded (pos=${o.pos}, max=${o.max})',
			.erange)
	}
	o.i[o.pos], o.j[o.pos], o.x[o.pos] = i, j, x
	o.pos++
}

/*
* put_matrix_and_matrix_t adds the content of a matrix "a" and its transpose "at" to triplet "o"
 * ex:    0   1   2   3   4   5
 *      [... ... ... a00 a10 ...] 0
 *      [... ... ... a01 a11 ...] 1
 *      [... ... ... a02 a12 ...] 2      [. at  .]
 *      [a00 a01 a02 ... ... ...] 3  =>  [a  .  .]
 *      [a10 a11 a12 ... ... ...] 4      [.  .  .]
 *      [... ... ... ... ... ...] 5
*/
// put_matrix_and_matrix_t exposes this operation as part of the public API.
pub fn (mut o Triplet[T]) put_matrix_and_matrix_t(a &Triplet[T]) ! {
	if a.n + a.m > o.m || a.n + a.m > o.n {
		return errors.error('cannot put larger matrix into sparse matrix.\nb := [[.. at] [a ..]] with len(a)=(${a.m},${a.n}) and len(b)=(${o.m},${o.n})',
			.erange)
	}
	for k in 0 .. a.pos {
		o.put(a.n + a.i[k], a.j[k], a.x[k])! // puts a
		o.put(a.j[k], a.n + a.i[k], a.x[k])! // puts at
	}
}

/*
* put_cc_matrix_and_matrix_t adds the content of a compressed-column matrix "a" and its transpose "at" to triplet "o"
 * ex:    0   1   2   3   4   5
 *      [... ... ... a00 a10 ...] 0
 *      [... ... ... a01 a11 ...] 1
 *      [... ... ... a02 a12 ...] 2      [. at  .]
 *      [a00 a01 a02 ... ... ...] 3  =>  [a  .  .]
 *      [a10 a11 a12 ... ... ...] 4      [.  .  .]
 *      [... ... ... ... ... ...] 5
*/
// put_cc_matrix_and_matrix_t exposes this operation as part of the public API.
pub fn (mut o Triplet[T]) put_cc_matrix_and_matrix_t(a &CCMatrix[T]) ! {
	if a.n + a.m > o.m || a.n + a.m > o.n {
		return errors.error('cannot put larger matrix into sparse matrix.\nb := [[.. at] [a ..]] with len(a)=(${a.m},${a.n}) and len(b)=(${o.m},${o.n})',
			.erange)
	}
	for j := 0; j < a.n; j++ {
		for k := a.p[j]; k < a.p[j + 1]; k++ {
			o.put(a.n + a.i[k], j, a.x[k])! // puts a
			o.put(j, a.n + a.i[k], a.x[k])! // puts at
		}
	}
}

// start (re)starts index for inserting items using the put command
pub fn (mut o Triplet[T]) start() {
	o.pos = 0
}

// Len returns the number of items just inserted in the triplet
pub fn (mut o Triplet[T]) len() int {
	return o.pos
}

// max returns the maximum number of items that can be inserted in the triplet
pub fn (o Triplet[T]) max() int {
	return o.max
}

// size returns the row/column size of the matrix represented by the Triplet
pub fn (o Triplet[T]) size() (int, int) {
	return o.m, o.n
}

// to_dense returns the dense matrix corresponding to this Triplet
pub fn (o Triplet[T]) to_dense() &Matrix[T] {
	mut a := Matrix.new[T](o.m, o.n)
	for k := 0; k < o.pos; k++ {
		a.add(o.i[k], o.j[k], o.x[k])
	}
	return a
}

// to_cc returns the column-compressed matrix corresponding to this Triplet.
// Repeated coordinates are summed, matching to_dense semantics, and explicit
// zeros produced by cancellation are dropped.
pub fn (o Triplet[T]) to_cc() &CCMatrix[T] {
	mut by_column := []map[int]T{len: o.n}
	for j in 0 .. o.n {
		by_column[j] = map[int]T{}
	}
	for k := 0; k < o.pos; k++ {
		by_column[o.j[k]][o.i[k]] += o.x[k]
	}
	return cc_from_columns[T](o.m, o.n, by_column)
}

// to_csr returns the row-compressed matrix corresponding to this Triplet.
// Repeated coordinates are summed, and explicit zeros produced by cancellation
// are dropped.
pub fn (o Triplet[T]) to_csr() !&CSRMatrix[T] {
	if o.m < 0 || o.n < 0 {
		return error('cannot convert a triplet with negative dimensions to CSR')
	}
	mut by_row := []map[int]T{len: o.m}
	for row in 0 .. o.m {
		by_row[row] = map[int]T{}
	}
	for k in 0 .. o.pos {
		row := o.i[k]
		column := o.j[k]
		if row < 0 || row >= o.m || column < 0 || column >= o.n {
			return error('cannot convert a triplet with out-of-range coordinates to CSR')
		}
		by_row[row][column] += o.x[k]
	}
	return csr_from_rows[T](o.m, o.n, by_row)
}

// cc_from_columns assembles a CCMatrix from per-column row->value maps,
// sorting row indices within each column and dropping explicit zeros.
fn cc_from_columns[T](m int, n int, by_column []map[int]T) &CCMatrix[T] {
	mut p := []int{len: n + 1}
	mut rows := []int{}
	mut values := []T{}
	for j in 0 .. n {
		mut keys := by_column[j].keys()
		keys.sort()
		for row in keys {
			value := by_column[j][row]
			if value != T(0) {
				rows << row
				values << value
			}
		}
		p[j + 1] = rows.len
	}
	return &CCMatrix[T]{
		m:   m
		n:   n
		nnz: rows.len
		p:   p
		i:   rows
		x:   values
	}
}

// csr_from_rows assembles a CSRMatrix from per-row column->value maps,
// sorting column indices within each row and dropping explicit zeros.
fn csr_from_rows[T](m int, n int, by_row []map[int]T) &CSRMatrix[T] {
	mut p := []int{len: m + 1}
	mut columns := []int{}
	mut values := []T{}
	for row in 0 .. m {
		mut keys := by_row[row].keys()
		keys.sort()
		for column in keys {
			value := by_row[row][column]
			if value != T(0) {
				columns << column
				values << value
			}
		}
		p[row + 1] = columns.len
	}
	return &CSRMatrix[T]{
		m:   m
		n:   n
		nnz: columns.len
		p:   p
		j:   columns
		x:   values
	}
}

// column_maps returns per-column row->value maps for this CCMatrix.
fn (a &CCMatrix[T]) column_maps() []map[int]T {
	mut by_column := []map[int]T{len: a.n}
	for j in 0 .. a.n {
		by_column[j] = map[int]T{}
		for k := a.p[j]; k < a.p[j + 1]; k++ {
			by_column[j][a.i[k]] = a.x[k]
		}
	}
	return by_column
}

// to_dense returns the dense matrix corresponding to this CCMatrix.
pub fn (a &CCMatrix[T]) to_dense() &Matrix[T] {
	mut dense := Matrix.new[T](a.m, a.n)
	for j in 0 .. a.n {
		for k := a.p[j]; k < a.p[j + 1]; k++ {
			dense.set(a.i[k], j, a.x[k])
		}
	}
	return dense
}

// to_csr converts this column-compressed matrix to row-compressed storage.
pub fn (a &CCMatrix[T]) to_csr() &CSRMatrix[T] {
	mut by_row := []map[int]T{len: a.m}
	for row in 0 .. a.m {
		by_row[row] = map[int]T{}
	}
	for column in 0 .. a.n {
		for k in a.p[column] .. a.p[column + 1] {
			by_row[a.i[k]][column] = a.x[k]
		}
	}
	return csr_from_rows[T](a.m, a.n, by_row)
}

// CCMatrix addition is element-wise and requires equal shapes.
pub fn (a &CCMatrix[T]) + (b &CCMatrix[T]) &CCMatrix[T] {
	if a.m != b.m || a.n != b.n {
		panic('CCMatrix addition requires equal shapes, got ${a.m}x${a.n} and ${b.m}x${b.n}')
	}
	mut by_column := a.column_maps()
	other := b.column_maps()
	for j in 0 .. a.n {
		for row, value in other[j] {
			by_column[j][row] += value
		}
	}
	return cc_from_columns[T](a.m, a.n, by_column)
}

// size returns the row/column size of the CSR matrix.
pub fn (a &CSRMatrix[T]) size() (int, int) {
	return a.m, a.n
}

// nnz returns the number of stored nonzero entries.
pub fn (a &CSRMatrix[T]) nnz() int {
	return a.nnz
}

// to_dense returns the dense matrix corresponding to this CSRMatrix.
pub fn (a &CSRMatrix[T]) to_dense() &Matrix[T] {
	mut dense := Matrix.new[T](a.m, a.n)
	for row in 0 .. a.m {
		for k in a.p[row] .. a.p[row + 1] {
			dense.set(row, a.j[k], a.x[k])
		}
	}
	return dense
}

// to_cc converts this CSRMatrix to column-compressed storage.
pub fn (a &CSRMatrix[T]) to_cc() &CCMatrix[T] {
	mut by_column := []map[int]T{len: a.n}
	for column in 0 .. a.n {
		by_column[column] = map[int]T{}
	}
	for row in 0 .. a.m {
		for k in a.p[row] .. a.p[row + 1] {
			by_column[a.j[k]][row] = a.x[k]
		}
	}
	return cc_from_columns[T](a.m, a.n, by_column)
}

// matvec multiplies this matrix by a dense vector.
pub fn (a &CSRMatrix[T]) matvec(vector []T) ![]T {
	if vector.len != a.n {
		return error('CSR matvec vector length ${vector.len} does not match matrix column count ${a.n}')
	}
	mut result := []T{len: a.m}
	for row in 0 .. a.m {
		for k in a.p[row] .. a.p[row + 1] {
			result[row] += a.x[k] * vector[a.j[k]]
		}
	}
	return result
}

// rmatvec multiplies the transpose of this matrix by a dense vector.
pub fn (a &CSRMatrix[T]) rmatvec(vector []T) ![]T {
	if vector.len != a.m {
		return error('CSR rmatvec vector length ${vector.len} does not match matrix row count ${a.m}')
	}
	mut result := []T{len: a.n}
	for row in 0 .. a.m {
		for k in a.p[row] .. a.p[row + 1] {
			result[a.j[k]] += a.x[k] * vector[row]
		}
	}
	return result
}

// CCMatrix subtraction is element-wise and requires equal shapes.
pub fn (a &CCMatrix[T]) - (b &CCMatrix[T]) &CCMatrix[T] {
	if a.m != b.m || a.n != b.n {
		panic('CCMatrix subtraction requires equal shapes, got ${a.m}x${a.n} and ${b.m}x${b.n}')
	}
	mut by_column := a.column_maps()
	other := b.column_maps()
	for j in 0 .. a.n {
		for row, value in other[j] {
			by_column[j][row] -= value
		}
	}
	return cc_from_columns[T](a.m, a.n, by_column)
}
