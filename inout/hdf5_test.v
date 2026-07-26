module inout

import os
import rand
import vsl.inout.h5

fn test_hdf5_dataset_round_trip() ! {
	if !os.exists_in_system_path('h5dump') {
		eprintln('HDF5 test skipped: h5dump is not available')
		return
	}

	test_dir := os.join_path(os.vtmp_dir(), 'vsl-inout-${rand.uuid_v4()}')
	test_file := os.join_path(test_dir, 'roundtrip.h5')
	os.mkdir_all(test_dir)!
	defer {
		os.rmdir_all(test_dir) or {}
	}

	expected := [f64(1.25), -2.5, 3.75]
	file := h5.Hdf5File.new(test_file)!
	mut file_closed := false
	defer {
		if !file_closed {
			file.close()
		}
	}
	assert file.write_dataset1d('values', expected)! >= 0
	file.close()
	file_closed = true

	mut actual := []f64{len: 1}
	read_file := h5.open_file(test_file)!
	mut read_file_closed := false
	defer {
		if !read_file_closed {
			read_file.close()
		}
	}
	read_file.read_dataset1d('values', mut actual)
	read_file.close()
	read_file_closed = true

	assert actual == expected
}
