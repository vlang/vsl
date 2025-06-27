module h5

import os

const h5dump = 'h5dump'
const h5data = 'hdf_types.h5'
const testfolder = os.join_path(os.vtmp_dir(), 'vsl', 'typeshdf5')
const testfile = os.join_path(testfolder, h5data)

const i8array = make1type[i8](2)
const u8array = make1type[u8](2)

const i16array = make1type[i16](2)
const u16array = make1type[u16](2)

const i32array = make1type[i32](2)
const u32array = make1type[u32](2)

const i64array = make1type[i64](2)
const u64array = make1type[u64](2)

const f32array = make1type[f32](2)
const f64array = make1type[f64](2)

const intarray = make1type[int](2)

fn testsuite_begin() {
	os.rmdir_all(testfolder) or {}
	os.mkdir_all(testfolder) or {}

	assert os.exists_in_system_path(h5dump)

	f := Hdf5File.new(testfile)!

	f.write_dataset1d('i8array', i8array)!
	f.write_dataset1d('u8array', u8array)!

	f.write_dataset1d('i16array', i16array)!
	f.write_dataset1d('u16array', u16array)!

	f.write_dataset1d('i32array', i32array)!
	f.write_dataset1d('u32array', u32array)!

	f.write_dataset1d('i64array', i64array)!
	f.write_dataset1d('u64array', u64array)!

	f.write_dataset1d('intarray', intarray)!

	f.write_dataset1d('f32array', f32array)!
	f.write_dataset1d('f64array', f64array)!

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
	assert 11 == output.count('(0): 0, 0') // uninitialized
	assert 2 == output.count('H5T_STD_I32LE') // i32 and int

	readback()!
	readback()! // worth doing twice
}

fn readback() ! {
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

	f := open_file(testfile)!

	f.read_dataset1d('i8array', mut i8arrayrd)
	f.read_dataset1d('u8array', mut u8arrayrd)
	compare1d(i8array, i8arrayrd)
	compare1d(u8array, u8arrayrd)

	f.read_dataset1d('i16array', mut i16arrayrd)
	f.read_dataset1d('u16array', mut u16arrayrd)
	compare1d(i16array, i16arrayrd)
	compare1d(u16array, u16arrayrd)

	f.read_dataset1d('i32array', mut i32arrayrd)
	f.read_dataset1d('u32array', mut u32arrayrd)
	compare1d(i32array, i32arrayrd)
	compare1d(u32array, u32arrayrd)

	f.read_dataset1d('i64array', mut i64arrayrd)
	f.read_dataset1d('u64array', mut u64arrayrd)
	compare1d(i64array, i64arrayrd)
	compare1d(u64array, u64arrayrd)

	f.read_dataset1d('f32array', mut f32arrayrd)
	f.read_dataset1d('f64array', mut f64arrayrd)
	compare1d(f32array, f32arrayrd)
	compare1d(f64array, f64arrayrd)

	f.read_dataset1d('intarray', mut intarrayrd)
	compare1d(intarray, intarrayrd)

	f.close()
}
