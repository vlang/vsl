module h5

import os

const h5dump = 'h5dump'
const h5data = 'hdf_test.h5'
const testfolder = os.join_path(os.vtmp_dir(), 'vsl', 'readhdf5')
const testfile = os.join_path(testfolder, h5data)
const shortarray = []i32{len: 2}

fn testsuite_begin() {
	os.rmdir_all(h5.testfolder) or {}
	os.mkdir_all(h5.testfolder)!

	assert os.exists_in_system_path(h5.h5dump)

	f := Hdf5File.new(h5.testfile)!
	f.write_dataset1d('Shortarray', h5.shortarray)!
	f.close()
}

fn testsuite_end() {
	os.rmdir_all(h5.testfolder) or {}
}

// verify simple operation of one datatype (int)
fn test_run() {
	res := os.execute('h5dump ${h5.testfile}')
	output := res.output.trim_space()
	assert output.contains('tsession')
	assert output.contains('Shortarray')
	assert output.contains('DATATYPE  H5T_STD_I32LE')
	assert output.contains('DATA {')
	assert output.contains('(0): 0, 0')
}
