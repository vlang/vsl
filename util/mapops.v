module util

// int_ints_map_append appends a new item to a map of slice.
// Note: this function creates a new slice in the map if key is not found.
pub fn int_ints_map_append(o map[int][]int, key int, item int) map[int][]int {
	mut m := o.clone()
	if key in m {
		mut slice := m[key]
		slice << item
		m[key] = slice
	} else {
		m[key] = [item]
	}
	return m
}

// str_ints_map_append appends a new item to a map of slice.
// Note: this function creates a new slice in the map if key is not found.
pub fn str_ints_map_append(o map[string][]int, key string, item int) map[string][]int {
	mut m := o.clone()
	if key in m {
		mut slice := m[key]
		slice << item
		m[key] = slice
	} else {
		m[key] = [item]
	}
	return m
}

// str_flts_map_append appends a new item to a map of slice.
// Note: this function creates a new slice in the map if key is not found.
pub fn str_flts_map_append(o map[string][]f64, key string, item f64) map[string][]f64 {
	mut m := o.clone()
	if key in m {
		mut slice := m[key]
		slice << item
		m[key] = slice
	} else {
		m[key] = [item]
	}
	return m
}
