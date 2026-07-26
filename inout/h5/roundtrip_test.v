// vtest retry: 3
module h5

import os

const h5dump = 'h5dump'
const testfolder = os.join_path(os.vtmp_dir(), 'vsl', 'h5_roundtrip')
const testfile = os.join_path(testfolder, 'roundtrip.h5')

fn testsuite_begin() {
	os.rmdir_all(testfolder) or {}
	os.mkdir_all(testfolder) or {}

	assert os.exists_in_system_path(h5dump)
}

fn testsuite_end() {
	os.rmdir_all(testfolder) or {}
}

fn test_dataset_round_trip() ! {
	expected := [f64(1.25), -2.5, 3.75]
	file := Hdf5File.new(testfile)!
	assert file.write_dataset1d('values', expected)! >= 0
	file.close()

	mut actual := []f64{len: 1}
	read_file := open_file(testfile)!
	read_file.read_dataset1d('values', mut actual)
	read_file.close()

	assert actual == expected
}
