import os
import hdf5

fn make1type[T](a int) []T {
	return []T{len: a, init: T(it)}
}

fn compare1d[T](ax []T, bx []T) {
	assert ax.len == bx.len
	for i in 0 .. ax.len {
		assert ax[i] == bx[i]
	}
}

const (
	h5dump     = 'h5dump'
	h5data     = 'hdf_types.h5'
	testfolder = os.join_path(os.vtmp_dir(),'vsl','typeshdf5')
	testfile   = os.join_path(testfolder, h5data)

	i8array    = make1type[i8](2)
	u8array    = make1type[u8](2)

	i16array   = make1type[i16](2)
	u16array   = make1type[u16](2)

	i32array   = make1type[i32](2)
	u32array   = make1type[u32](2)

	i64array   = make1type[i64](2)
	u64array   = make1type[u64](2)

	f32array   = make1type[f32](2)
	f64array   = make1type[f64](2)

	intarray   = make1type[int](2)
)

fn testsuite_begin() {
	os.rmdir_all(testfolder) or {}
	os.mkdir_all(testfolder)!

	assert os.exists_in_system_path(h5dump)

	f := hdf5.new_file(testfile.str)?

	f.write_dataset1d(c'i8array', i8array)?
	f.write_dataset1d(c'u8array', u8array)?

	f.write_dataset1d(c'i16array', i16array)?
	f.write_dataset1d(c'u16array', u16array)?

	f.write_dataset1d(c'i32array', i32array)?
	f.write_dataset1d(c'u32array', u32array)?

	f.write_dataset1d(c'i64array', i64array)?
	f.write_dataset1d(c'u64array', u64array)?

	f.write_dataset1d(c'intarray', intarray)?

	f.write_dataset1d(c'f32array', f32array)?
	f.write_dataset1d(c'f64array', f64array)?

	f.close()
}

fn testsuite_end() {
	//        os.rmdir_all(testfolder) or {}
}

// verify all datatypes in 1 dimension
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

	assert 11 == output.count('DATASET')
	assert 11 == output.count('DATATYPE')
	assert 11 == output.count('DATASPACE  SIMPLE { ( 2 ) / ( 2 ) }')
	assert 11 == output.count('(0): 0, 1')
	assert 2 == output.count('H5T_STD_I32LE') // i32 and int

	readback()?
	readback()? // worth doing twice
}

fn readback() ? {
	// read_dataset1d will change the mut array size
	mut i8arrayrd := make1type[i8](1)
	mut u8arrayrd := make1type[u8](1)

	mut i16arrayrd := make1type[i16](1)
	mut u16arrayrd := make1type[u16](1)

	mut i32arrayrd := make1type[i32](1)
	mut u32arrayrd := make1type[u32](1)

	mut i64arrayrd := make1type[i64](1)
	mut u64arrayrd := make1type[u64](1)

	mut f32arrayrd := make1type[f32](1)
	mut f64arrayrd := make1type[f64](1)

	mut intarrayrd := make1type[int](1)

	f := hdf5.open_file(testfile.str)?

	f.read_dataset1d(c'i8array', mut i8arrayrd)
	f.read_dataset1d(c'u8array', mut u8arrayrd)
	compare1d(i8array, i8arrayrd)
	compare1d(u8array, u8arrayrd)

	f.read_dataset1d(c'i16array', mut i16arrayrd)
	f.read_dataset1d(c'u16array', mut u16arrayrd)
	compare1d(i16array, i16arrayrd)
	compare1d(u16array, u16arrayrd)

	f.read_dataset1d(c'i32array', mut i32arrayrd)
	f.read_dataset1d(c'u32array', mut u32arrayrd)
	compare1d(i32array, i32arrayrd)
	compare1d(u32array, u32arrayrd)

	f.read_dataset1d(c'i64array', mut i64arrayrd)
	f.read_dataset1d(c'u64array', mut u64arrayrd)
	compare1d(i64array, i64arrayrd)
	compare1d(u64array, u64arrayrd)

	f.read_dataset1d(c'f32array', mut f32arrayrd)
	f.read_dataset1d(c'f64array', mut f64arrayrd)
	compare1d(f32array, f32arrayrd)
	compare1d(f64array, f64arrayrd)

	f.read_dataset1d(c'intarray', mut intarrayrd)
	compare1d(intarray, intarrayrd)

	f.close()
}
