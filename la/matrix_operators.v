module la

// Matrix addition is element-wise and requires equal shapes.
pub fn (a &Matrix[T]) + (b &Matrix[T]) &Matrix[T] {
	if a.m != b.m || a.n != b.n {
		panic('Matrix addition requires equal shapes, got ${a.m}x${a.n} and ${b.m}x${b.n}')
	}
	mut data := []T{len: a.m * a.n}
	for i in 0 .. data.len {
		data[i] = a.data[i] + b.data[i]
	}
	return &Matrix[T]{
		m:    a.m
		n:    a.n
		data: data
	}
}

// Matrix subtraction is element-wise and requires equal shapes.
pub fn (a &Matrix[T]) - (b &Matrix[T]) &Matrix[T] {
	if a.m != b.m || a.n != b.n {
		panic('Matrix subtraction requires equal shapes, got ${a.m}x${a.n} and ${b.m}x${b.n}')
	}
	mut data := []T{len: a.m * a.n}
	for i in 0 .. data.len {
		data[i] = a.data[i] - b.data[i]
	}
	return &Matrix[T]{
		m:    a.m
		n:    a.n
		data: data
	}
}

// Matrix multiplication uses the conventional row-by-column product.
pub fn (a &Matrix[T]) * (b &Matrix[T]) &Matrix[T] {
	if a.n != b.m {
		panic('Matrix multiplication requires matching inner dimensions, got ${a.m}x${a.n} and ${b.m}x${b.n}')
	}
	$if T is f64 {
		mut result := Matrix.new[f64](a.m, b.n)
		matrix_matrix_mul(mut result, 1.0, a, b)
		return result
	} $else $if T is f32 {
		mut result := Matrix.new[f32](a.m, b.n)
		matrix_matrix_mul_f32(mut result.data, a.m, b.n, a.n, 1.0, a.data, b.data)
		return result
	} $else {
		mut data := []T{len: a.m * b.n}
		for row in 0 .. a.m {
			for column in 0 .. b.n {
				mut value := T(0)
				for inner in 0 .. a.n {
					value += a.data[row * a.n + inner] * b.data[inner * b.n + column]
				}
				data[row * b.n + column] = value
			}
		}
		return &Matrix[T]{
			m:    a.m
			n:    b.n
			data: data
		}
	}
}

// Matrix division is element-wise and requires equal shapes.
pub fn (a &Matrix[T]) / (b &Matrix[T]) &Matrix[T] {
	if a.m != b.m || a.n != b.n {
		panic('Matrix division requires equal shapes, got ${a.m}x${a.n} and ${b.m}x${b.n}')
	}
	mut data := []T{len: a.m * a.n}
	for i in 0 .. data.len {
		data[i] = a.data[i] / b.data[i]
	}
	return &Matrix[T]{
		m:    a.m
		n:    a.n
		data: data
	}
}

// Matrix remainder is element-wise for integer element types.
pub fn (a &Matrix[T]) % (b &Matrix[T]) &Matrix[T] {
	$if T is $int {
		if a.m != b.m || a.n != b.n {
			panic('Matrix remainder requires equal shapes, got ${a.m}x${a.n} and ${b.m}x${b.n}')
		}
		mut data := []T{len: a.m * a.n}
		for i in 0 .. data.len {
			data[i] = a.data[i] % b.data[i]
		}
		return &Matrix[T]{
			m:    a.m
			n:    a.n
			data: data
		}
	} $else {
		panic('Matrix remainder is only defined for integer element types')
	}
}

// add_scalar returns a new matrix with the scalar added to every element.
pub fn (a &Matrix[T]) add_scalar(scalar T) &Matrix[T] {
	mut data := []T{len: a.m * a.n}
	for i in 0 .. data.len {
		data[i] = a.data[i] + scalar
	}
	return &Matrix[T]{
		m:    a.m
		n:    a.n
		data: data
	}
}

// sub_scalar returns a new matrix with the scalar subtracted from every element.
pub fn (a &Matrix[T]) sub_scalar(scalar T) &Matrix[T] {
	mut data := []T{len: a.m * a.n}
	for i in 0 .. data.len {
		data[i] = a.data[i] - scalar
	}
	return &Matrix[T]{
		m:    a.m
		n:    a.n
		data: data
	}
}

// scale returns a new matrix with every element multiplied by the scalar.
pub fn (a &Matrix[T]) scale(scalar T) &Matrix[T] {
	mut data := []T{len: a.m * a.n}
	for i in 0 .. data.len {
		data[i] = a.data[i] * scalar
	}
	return &Matrix[T]{
		m:    a.m
		n:    a.n
		data: data
	}
}

// div_scalar returns a new matrix with every element divided by the scalar.
pub fn (a &Matrix[T]) div_scalar(scalar T) &Matrix[T] {
	mut data := []T{len: a.m * a.n}
	for i in 0 .. data.len {
		data[i] = a.data[i] / scalar
	}
	return &Matrix[T]{
		m:    a.m
		n:    a.n
		data: data
	}
}

// remainder_scalar returns element-wise remainder for integer matrices.
pub fn (a &Matrix[T]) remainder_scalar(scalar T) &Matrix[T] {
	$if T is $int {
		mut data := []T{len: a.m * a.n}
		for i in 0 .. data.len {
			data[i] = a.data[i] % scalar
		}
		return &Matrix[T]{
			m:    a.m
			n:    a.n
			data: data
		}
	} $else {
		panic('Matrix remainder is only defined for integer element types')
	}
}
