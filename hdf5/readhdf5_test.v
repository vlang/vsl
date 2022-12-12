import os
import hdf5

const (
	h5dump     = 'h5dump'
	h5data     = 'hdf_test.h5'
	testfolder = os.join_path(os.vtmp_dir(),'vsl','readhdf5')
	testfile   = os.join_path(testfolder, h5data)
	shortarray = []i32{len: 2}
)

fn testsuite_begin() {
	os.rmdir_all(testfolder) or {}
	os.mkdir_all(testfolder)!

	assert os.exists_in_system_path(h5dump)

	f := hdf5.new_file(testfile.str)?
	f.write_dataset1d(c'Shortarray', shortarray)?
	f.close()
}

fn testsuite_end() {
	os.rmdir_all(testfolder) or {}
}

// verify simple operation of one datatype (int)
fn test_run() {
	res := os.execute('h5dump ${testfile}')
	output := res.output.trim_space()
	assert output.contains('tsession')
	assert output.contains('Shortarray')
	assert output.contains('DATATYPE  H5T_STD_I32LE')
	assert output.contains('DATA {')
	assert output.contains('(0): 0, 0')
}
