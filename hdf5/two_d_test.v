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

fn check2dims[T](ax [][]T, b int) {
	assert ax.len == b
	for i in 0 .. ax.len {
		assert ax[i].len == b
	}
}

const (
	h5dump     = 'h5dump'
	h5data     = 'hdf_two.h5'
	testfolder = os.join_path(os.vtmp_dir(),'vsl','two_d_test')
	testfile   = os.join_path(testfolder, h5data)
)

fn test_2d() {
	mut i8array := make2type[i8](3, 3)
	mut u8array := make2type[u8](3, 3)

	mut i16array := make2type[i16](3, 3)
	mut u16array := make2type[u16](3, 3)

	mut i32array := make2type[i32](3, 3)
	mut u32array := make2type[u32](3, 3)

	mut i64array := make2type[i64](3, 3)
	mut u64array := make2type[u64](3, 3)

	mut f32array := make2type[f32](3, 3)
	mut f64array := make2type[f64](3, 3)

	mut intarray := make2type[int](3, 3)

	for i in 0 .. 3 {
		for j in 0 .. 3 {
			i8array[i][j] = -i * 10 - j
			u8array[i][j] = i * 10 + j
			i16array[i][j] = -i * 100 + j
			u16array[i][j] = i * 100 + j
			i32array[i][j] = -i * 1000 + j
			u32array[i][j] = i * 1000 + j
			i64array[i][j] = -i * 10000 + j
			u64array[i][j] = i * 10000 + j
			intarray[i][j] = i * 20000 + j
			f32array[i][j] = i * 20.00 + j
			f64array[i][j] = i * 200.0 + j
		}
	}

	f := hdf5.new_file(testfile.str)?

	f.write_dataset2d(c'i8array', i8array)?
	f.write_dataset2d(c'u8array', u8array)?

	f.write_dataset2d(c'i16array', i16array)?
	f.write_dataset2d(c'u16array', u16array)?

	f.write_dataset2d(c'i32array', i32array)?
	f.write_dataset2d(c'u32array', u32array)?

	f.write_dataset2d(c'i64array', i64array)?
	f.write_dataset2d(c'u64array', u64array)?

	f.write_dataset2d(c'intarray', intarray)?

	f.write_dataset2d(c'f32array', f32array)?
	f.write_dataset2d(c'f64array', f64array)?

	f.close()
}

fn testsuite_begin() {
	os.rmdir_all(testfolder) or {}
	os.mkdir_all(testfolder)!

	assert os.exists_in_system_path(h5dump)

	test_2d()
}

fn testsuite_end() {
	os.rmdir_all(testfolder) or {}
}

// verify all datatypes in 2 dimensions
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
	// read_dataset2d will change the mut array size

	mut i8arrayrd := make2type[i8](1, 1)
	mut u8arrayrd := make2type[u8](1, 1)

	mut i16arrayrd := make2type[i16](1, 1)
	mut u16arrayrd := make2type[u16](1, 1)

	mut i32arrayrd := make2type[i32](1, 1)
	mut u32arrayrd := make2type[u32](1, 1)

	mut i64arrayrd := make2type[i64](1, 1)
	mut u64arrayrd := make2type[u64](1, 1)

	mut f32arrayrd := make2type[f32](1, 1)
	mut f64arrayrd := make2type[f64](1, 1)

	mut intarrayrd := make2type[int](1, 1)

	f := hdf5.open_file(testfile.str)?

	f.read_dataset2d(c'i8array', mut i8arrayrd)
	f.read_dataset2d(c'u8array', mut u8arrayrd)
	check2dims(i8arrayrd, 3)
	check2dims(u8arrayrd, 3)

	f.read_dataset2d(c'i16array', mut i16arrayrd)
	f.read_dataset2d(c'u16array', mut u16arrayrd)
	check2dims(i16arrayrd, 3)
	check2dims(u16arrayrd, 3)

	f.read_dataset2d(c'i32array', mut i32arrayrd)
	f.read_dataset2d(c'u32array', mut u32arrayrd)
	check2dims(i32arrayrd, 3)
	check2dims(u32arrayrd, 3)

	f.read_dataset2d(c'i64array', mut i64arrayrd)
	f.read_dataset2d(c'u64array', mut u64arrayrd)
	check2dims(i64arrayrd, 3)
	check2dims(u64arrayrd, 3)

	f.read_dataset2d(c'f32array', mut f32arrayrd)
	f.read_dataset2d(c'f64array', mut f64arrayrd)
	check2dims(f32arrayrd, 3)
	check2dims(f64arrayrd, 3)

	f.read_dataset2d(c'intarray', mut intarrayrd)
	check2dims(intarrayrd, 3)

	for i in 0 .. 3 {
		for j in 0 .. 3 {
			assert i8arrayrd[i][j] == -i * 10 - j
			assert u8arrayrd[i][j] == i * 10 + j
			assert i16arrayrd[i][j] == -i * 100 + j
			assert u16arrayrd[i][j] == i * 100 + j
			assert i32arrayrd[i][j] == -i * 1000 + j
			assert u32arrayrd[i][j] == i * 1000 + j
			assert i64arrayrd[i][j] == -i * 10000 + j
			assert u64arrayrd[i][j] == i * 10000 + j
			assert intarrayrd[i][j] == i * 20000 + j
			assert f32arrayrd[i][j] == i * 20.00 + j
			assert f64arrayrd[i][j] == i * 200.0 + j
		}
	}

	f.close()
}
