module hdf5

import os

const (
	h5dump     = 'h5dump'
	h5data     = 'hdf_test.h5'
	testfolder = os.join_path(os.vtmp_dir(), 'vsl', 'readhdf5')
	testfile   = os.join_path(testfolder, h5data)
	shortarray = []i32{len: 2}
)

fn testsuite_begin() {
	os.rmdir_all(hdf5.testfolder) or {}
	os.mkdir_all(hdf5.testfolder)!

	assert os.exists_in_system_path(hdf5.h5dump)

	f := new_file(hdf5.testfile)?
	f.write_dataset1d('Shortarray', hdf5.shortarray)?
	f.close()
}

fn testsuite_end() {
	os.rmdir_all(hdf5.testfolder) or {}
}

// verify simple operation of one datatype (int)
fn test_run() {
	res := os.execute('h5dump ${hdf5.testfile}')
	output := res.output.trim_space()
	assert output.contains('tsession')
	assert output.contains('Shortarray')
	assert output.contains('DATATYPE  H5T_STD_I32LE')
	assert output.contains('DATA {')
	assert output.contains('(0): 0, 0')
}
