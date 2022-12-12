import os
import hdf5

fn make1type[T](a int) []T {
	return []T{len: a, init: T(it)}
}

fn make2type[T](a int, b int) [][]T {
	return [][]T{len: a, init: []T{len: b}}
}

fn make3type[T](a int, b int, c int) [][][]T {
	return [][][]T{len: a, init: make2type[T](b, c)}
}

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

const (
	h5dump     = 'h5dump'
	h5data     = 'hdf_three.h5'
	testfolder = os.join_path(os.vtmp_dir(), 'vsl', 'three_d_test')
	testfile   = os.join_path(testfolder, h5data)
)

fn test_3d() {
	mut i8array := make3type[i8](3, 4, 5)
	mut u8array := make3type[u8](3, 4, 5)

	mut i16array := make3type[i16](3, 4, 5)
	mut u16array := make3type[u16](3, 4, 5)

	mut i32array := make3type[i32](3, 4, 5)
	mut u32array := make3type[u32](3, 4, 5)

	mut i64array := make3type[i64](3, 4, 5)
	mut u64array := make3type[u64](3, 4, 5)

	mut f32array := make3type[f32](3, 4, 5)
	mut f64array := make3type[f64](3, 4, 5)

	mut intarray := make3type[int](3, 4, 5)

	for i in 0 .. 3 {
		for j in 0 .. 4 {
			for k in 0 .. 5 {
				i8array[i][j][k] = -i * 30 - 2 * j - k
				u8array[i][j][k] = i * 30 + 2 * j + k + 1
				i16array[i][j][k] = -i * 100 + 10 * j + k
				u16array[i][j][k] = i * 100 + 10 * j + k
				i32array[i][j][k] = -i * 1000 - 10 * j - k
				u32array[i][j][k] = i * 1000 + 10 * j + k
				i64array[i][j][k] = -i * 10000 - 10 * j - k
				u64array[i][j][k] = i * 10000 + 10 * j + k
				intarray[i][j][k] = i * 20000 + 10 * j + k
				f32array[i][j][k] = i * 20.00 + 10 * j + k
				f64array[i][j][k] = i * 200.0 + 10 * j + k
			}
		}
	}

	f := hdf5.new_file(testfile.str)?

	f.write_dataset3d(c'i8array', i8array)?
	f.write_dataset3d(c'u8array', u8array)?

	f.write_dataset3d(c'i16array', i16array)?
	f.write_dataset3d(c'u16array', u16array)?

	f.write_dataset3d(c'i32array', i32array)?
	f.write_dataset3d(c'u32array', u32array)?

	f.write_dataset3d(c'i64array', i64array)?
	f.write_dataset3d(c'u64array', u64array)?

	f.write_dataset3d(c'intarray', intarray)?

	f.write_dataset3d(c'f32array', f32array)?
	f.write_dataset3d(c'f64array', f64array)?

	f.close()
}

fn testsuite_begin() {
	os.rmdir_all(testfolder) or {}
	os.mkdir_all(testfolder)!

	assert os.exists_in_system_path(h5dump)

	test_3d()
}

fn testsuite_end() {
	//        os.rmdir_all(testfolder) or {}
}

// verify all datatypes in 3 dimensions
fn test_run() {
	res := os.execute('h5dump ${testfile}')
	output := res.output.trim_space()
	assert output.contains('i8array')
	assert output.contains('u8array')
	assert output.contains('DATATYPE  H5T_STD_I8LE')
	assert output.contains('DATATYPE  H5T_STD_U8LE')

	assert output.contains('i16array')
	assert output.contains('u16array')
	assert output.contains('DATATYPE  H5T_STD_I16LE')
	assert output.contains('DATATYPE  H5T_STD_U16LE')

	assert output.contains('i32array')
	assert output.contains('u32array')
	assert output.contains('DATATYPE  H5T_STD_I32LE')
	assert output.contains('DATATYPE  H5T_STD_U32LE')

	assert output.contains('i64array')
	assert output.contains('u64array')
	assert output.contains('DATATYPE  H5T_STD_I64LE')
	assert output.contains('DATATYPE  H5T_STD_U64LE')

	assert output.contains('f32array')
	assert output.contains('f64array')
	assert output.contains('DATATYPE  H5T_IEEE_F32LE')
	assert output.contains('DATATYPE  H5T_IEEE_F64LE')

	assert output.contains('intarray')
	assert output.contains('DATATYPE  H5T_STD_I32LE')

	assert 2 == output.count('H5T_STD_I32LE') // i32 and int

	readback()?
	readback()? // worth doing twice
}

fn readback() ? {
	// read_dataset3d will change the mut array size

	mut i8arrayrd := make3type[i8](1, 1, 1)
	mut u8arrayrd := make3type[u8](1, 1, 1)

	mut i16arrayrd := make3type[i16](1, 1, 1)
	mut u16arrayrd := make3type[u16](1, 1, 1)

	mut i32arrayrd := make3type[i32](1, 1, 1)
	mut u32arrayrd := make3type[u32](1, 1, 1)

	mut i64arrayrd := make3type[i64](1, 1, 1)
	mut u64arrayrd := make3type[u64](1, 1, 1)

	mut f32arrayrd := make3type[f32](1, 1, 1)
	mut f64arrayrd := make3type[f64](1, 1, 1)

	mut intarrayrd := make3type[int](1, 1, 1)

	f := hdf5.open_file(testfile.str)?

	f.read_dataset3d(c'i8array', mut i8arrayrd)
	f.read_dataset3d(c'u8array', mut u8arrayrd)
	check3dims(i8arrayrd, 3, 4, 5)
	check3dims(u8arrayrd, 3, 4, 5)

	f.read_dataset3d(c'i16array', mut i16arrayrd)
	f.read_dataset3d(c'u16array', mut u16arrayrd)
	check3dims(i16arrayrd, 3, 4, 5)
	check3dims(u16arrayrd, 3, 4, 5)

	f.read_dataset3d(c'i32array', mut i32arrayrd)
	f.read_dataset3d(c'u32array', mut u32arrayrd)
	check3dims(i32arrayrd, 3, 4, 5)
	check3dims(u32arrayrd, 3, 4, 5)

	f.read_dataset3d(c'i64array', mut i64arrayrd)
	f.read_dataset3d(c'u64array', mut u64arrayrd)
	check3dims(i64arrayrd, 3, 4, 5)
	check3dims(u64arrayrd, 3, 4, 5)

	f.read_dataset3d(c'f32array', mut f32arrayrd)
	f.read_dataset3d(c'f64array', mut f64arrayrd)
	check3dims(f32arrayrd, 3, 4, 5)
	check3dims(f64arrayrd, 3, 4, 5)

	f.read_dataset3d(c'intarray', mut intarrayrd)
	check3dims(intarrayrd, 3, 4, 5)

	for i in 0 .. 3 {
		for j in 0 .. 4 {
			for k in 0 .. 5 {
				assert i8arrayrd[i][j][k] == -i * 30 - 2 * j - k
				assert u8arrayrd[i][j][k] == i * 30 + 2 * j + k + 1
				assert i16arrayrd[i][j][k] == -i * 100 + 10 * j + k
				assert u16arrayrd[i][j][k] == i * 100 + 10 * j + k
				assert i32arrayrd[i][j][k] == -i * 1000 - 10 * j - k
				assert u32arrayrd[i][j][k] == i * 1000 + 10 * j + k
				assert i64arrayrd[i][j][k] == -i * 10000 - 10 * j - k
				assert u64arrayrd[i][j][k] == i * 10000 + 10 * j + k
				assert intarrayrd[i][j][k] == i * 20000 + 10 * j + k
				assert f32arrayrd[i][j][k] == i * 20.00 + 10 * j + k
				assert f64arrayrd[i][j][k] == i * 200.0 + 10 * j + k
			}
		}
	}

	f.close()
}
