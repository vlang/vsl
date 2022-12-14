module hdf5

// functions for testing

fn compare1d[T](ax []T, bx []T) {
	assert ax.len == bx.len
	for i in 0 .. ax.len {
		assert ax[i] == bx[i]
	}
}

fn compare2d[T](ax [][]T, bx [][]T) {
	assert ax.len == bx.len
	for i in 0 .. ax.len {
		compare1d(ax[i], bx[i])
	}
}

fn compare3d[T](ax [][][]T, bx [][][]T) {
	assert ax.len == bx.len
	for i in 0 .. ax.len {
		compare2d(ax[i], bx[i])
	}
}

fn check2dims[T](ax [][]T, b int, c int) {
	assert ax.len == b
	for i in 0 .. ax.len {
		assert ax[i].len == c
	}
}

fn check3dims[T](ax [][][]T, b int, c int, d int) {
	assert ax.len == b
	for i in 0 .. ax.len {
		assert ax[i].len == c
		for j in 0 .. ax[i].len {
			assert ax[i][j].len == d
		}
	}
}
