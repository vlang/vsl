// vtest retry: 3
module h5

import os

const h5dump = 'h5dump'
const testfolder = os.join_path(os.vtmp_dir(), 'vsl', 'h5_roundtrip')
const testfile = os.join_path(testfolder, 'roundtrip.h5')

fn testsuite_begin() {
	os.rmdir_all(testfolder) or {}
	os.mkdir_all(testfolder) or {}
}

fn testsuite_end() {
	os.rmdir_all(testfolder) or {}
}

fn test_dataset_round_trip() ! {
	if !os.exists_in_system_path(h5dump) {
		eprintln('HDF5 round-trip test skipped: h5dump not available')
		return
	}

	expected := [f64(1.25), -2.5, 3.75]

	writer := Hdf5File.new(testfile)!
	mut writer_closed := false
	defer {
		if !writer_closed {
			writer.close()
		}
	}
	assert writer.write_dataset1d('values', expected)! >= 0
	writer.close()
	writer_closed = true

	mut actual := []f64{len: 1}
	reader := open_file(testfile)!
	defer { reader.close() }
	reader.read_dataset1d('values', mut actual)

	assert actual == expected
}
