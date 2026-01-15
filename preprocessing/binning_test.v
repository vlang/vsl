module preprocessing

fn test_cut_basic() {
	values := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

	result := cut(values, 2, ['low', 'high'])!

	// First half should be 'low', second half 'high'
	assert result[0] == 'low'
	assert result[9] == 'high'
}

fn test_cut_auto_labels() {
	values := [1.0, 2.0, 3.0, 4.0, 5.0]

	result := cut(values, 3, [])!

	// Should use auto-generated labels
	assert result[0] == 'bin_0'
}

fn test_qcut_basic() {
	values := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

	result := qcut(values, 4, ['Q1', 'Q2', 'Q3', 'Q4'])!

	// Each quartile should have approximately equal frequency
	mut counts := map[string]int{}
	for label in result {
		counts[label]++
	}

	// With 10 values and 4 bins, distribution should be reasonable
	assert counts.len == 4
}

fn test_qcut_auto_labels() {
	values := [1.0, 2.0, 3.0, 4.0]

	result := qcut(values, 2, [])!

	// Should use Q1, Q2, etc.
	assert result[0] == 'Q1'
	assert result[3] == 'Q2'
}

fn test_binner_uniform() {
	values := [0.0, 25.0, 50.0, 75.0, 100.0]

	mut binner := Binner.new(4, .uniform, ['A', 'B', 'C', 'D'])
	result := binner.fit_transform(values)!

	assert binner.fitted == true
	assert result[0] == 'A' // 0 -> first bin
	assert result[4] == 'D' // 100 -> last bin
}

fn test_binner_quantile() {
	values := [1.0, 1.0, 1.0, 10.0, 10.0, 10.0, 100.0, 100.0, 100.0]

	mut binner := Binner.new(3, .quantile, ['low', 'medium', 'high'])
	result := binner.fit_transform(values)!

	// Each bin should have roughly equal frequency
	mut counts := map[string]int{}
	for label in result {
		counts[label]++
	}
	assert counts.len == 3
}

fn test_binner_transform_to_indices() {
	values := [1.0, 2.0, 3.0, 4.0, 5.0]

	mut binner := Binner.new(2, .uniform, [])
	binner.fit(values)!
	indices := binner.transform_to_indices(values)!

	assert indices[0] == 0 // first bin
	assert indices[4] == 1 // second bin
}

fn test_digitize() {
	values := [0.5, 1.5, 2.5, 3.5]
	bins := [1.0, 2.0, 3.0]

	result := digitize(values, bins)

	assert result[0] == 0 // 0.5 < 1.0
	assert result[1] == 1 // 1.0 < 1.5 < 2.0
	assert result[2] == 2 // 2.0 < 2.5 < 3.0
	assert result[3] == 3 // 3.5 > 3.0
}

fn test_binner_not_fitted_error() {
	binner := Binner.new(3, .uniform, [])

	if _ := binner.transform([1.0, 2.0, 3.0]) {
		assert false, 'should have returned error'
	}
}

fn test_cut_edge_cases() {
	// All same values
	values := [5.0, 5.0, 5.0, 5.0]

	result := cut(values, 2, ['a', 'b'])!

	// All values should be in the same bin
	for label in result {
		assert label == result[0]
	}
}
