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
