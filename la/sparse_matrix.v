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

// new_triplet returns a new Triplet. This is a wrapper to new(Triplet) followed by init()
pub fn new_triplet[T](m int, n int, max int) &Triplet[T] {
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
	if i >= o.m {
		return errors.error('cannot put item because index of row is outside range (i=${i}, m=${o.m})',
			.erange)
	}
	if j >= o.n {
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
	mut a := new_matrix[T](o.m, o.n)
	for k := 0; k < o.max; k++ {
		a.add(o.i[k], o.j[k], o.x[k])
	}
	return a
}
