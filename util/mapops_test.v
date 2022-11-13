module util

fn test_int_ints_map_append() {
	mut o := map[int][]int{}
	o = int_ints_map_append(o, 1, 2)
	o = int_ints_map_append(o, 2, 3)
	o = int_ints_map_append(o, 3, 4)
	assert o[1] == [2]
	assert o[2] == [3]
	assert o[3] == [4]
	assert o.len == 3
}

fn test_str_ints_map_append() {
	mut o := map[string][]int{}
	o = str_ints_map_append(o, 'a', 1)
	o = str_ints_map_append(o, 'b', 2)
	o = str_ints_map_append(o, 'c', 3)
	assert o['a'] == [1]
	assert o['b'] == [2]
	assert o['c'] == [3]
	assert o.len == 3
}

fn test_str_flts_map_append() {
	mut o := map[string][]f64{}
	o = str_flts_map_append(o, 'a', 1.0)
	o = str_flts_map_append(o, 'b', 2.0)
	o = str_flts_map_append(o, 'c', 3.0)
	assert o['a'] == [1.0]
	assert o['b'] == [2.0]
	assert o['c'] == [3.0]
	assert o.len == 3
}
