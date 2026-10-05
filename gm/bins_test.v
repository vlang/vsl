module gm

import math

fn test_bins_insert_find_closest_and_empty_queries() {
	mut bins := Bins.new([0.0, 0.0], [1.0, 1.0], [4, 4])
	id_empty, distance_empty := bins.find_closest([0.1, 0.1])
	assert id_empty == -1
	assert distance_empty == math.inf(1)
	bins.append([0.1, 0.1], 7, unsafe { nil })
	bins.append([0.9, 0.9], 8, unsafe { nil })
	assert bins.nentries() == 2
	assert bins.nactive() == 2
	id, squared_distance := bins.find_closest([0.2, 0.1])
	assert id == 7
	assert math.abs(squared_distance - 0.01) < 1e-12
	assert bins.calc_index([1.0, 1.0]) >= 0
	assert bins.calc_index([1.1, 1.0]) == -1
}

fn test_bins_duplicate_point_is_not_inserted_twice() {
	mut bins := Bins.new([0.0, 0.0], [1.0, 1.0], [4, 4])
	mut next_id := 0
	id, already_exists := bins.find_closest_and_append(mut next_id, [0.5, 0.5], unsafe { nil },
		1e-8, unsafe { nil })
	assert id == 0
	assert !already_exists
	assert next_id == 1
	id_again, already_exists_again := bins.find_closest_and_append(mut next_id, [0.5, 0.5],
		unsafe { nil }, 1e-8, unsafe { nil })
	assert id_again == 0
	assert already_exists_again
	assert next_id == 1
	assert bins.nentries() == 1
}

fn test_bins_find_entries_along_2d_and_3d_segments() {
	mut bins_2d := Bins.new([0.0, 0.0], [1.0, 1.0], [4, 4])
	bins_2d.append([0.5, 0.5], 1, unsafe { nil })
	bins_2d.append([0.5, 0.8], 2, unsafe { nil })
	assert bins_2d.find_along_segment([0.0, 0.5], [1.0, 0.5], 0.1) == [1]

	mut bins_3d := Bins.new([0.0, 0.0, 0.0], [1.0, 1.0, 1.0], [4, 4, 4])
	bins_3d.append([0.5, 0.5, 0.75], 3, unsafe { nil })
	assert bins_3d.find_along_segment([0.5, 0.5, 0.0], [0.5, 0.5, 1.0], 0.1) == [3]
}
