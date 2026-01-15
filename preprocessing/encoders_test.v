module preprocessing

fn test_label_encoder_basic() {
	labels := ['cat', 'dog', 'bird', 'cat', 'dog']

	mut encoder := LabelEncoder.new()
	result := encoder.fit_transform(labels)!

	assert encoder.fitted == true
	assert encoder.classes_.len == 3

	// Same labels should have same encoding
	assert result[0] == result[3] // both 'cat'
	assert result[1] == result[4] // both 'dog'
}

fn test_label_encoder_inverse() {
	labels := ['a', 'b', 'c', 'a']

	mut encoder := LabelEncoder.new()
	encoded := encoder.fit_transform(labels)!
	decoded := encoder.inverse_transform(encoded)!

	assert decoded == labels
}

fn test_label_encoder_unknown_label() {
	labels := ['a', 'b', 'c']

	mut encoder := LabelEncoder.new()
	encoder.fit(labels)!

	// Trying to transform unknown label should error
	if _ := encoder.transform(['d']) {
		assert false, 'should have returned error for unknown label'
	}
}

fn test_one_hot_encoder_basic() {
	data := [['red'], ['blue'], ['green'], ['red']]

	mut encoder := OneHotEncoder.new(false)
	result := encoder.fit_transform(data)!

	assert encoder.fitted == true
	assert result[0].len == 3 // 3 categories
	assert result.len == 4 // 4 samples

	// Each row should have exactly one 1.0
	for row in result {
		mut sum := 0.0
		for val in row {
			sum += val
		}
		assert sum == 1.0
	}
}

fn test_one_hot_encoder_drop_first() {
	data := [['a'], ['b'], ['c']]

	mut encoder := OneHotEncoder.new(true) // drop_first = true
	result := encoder.fit_transform(data)!

	// With 3 categories and drop_first, we get 2 columns
	assert result[0].len == 2

	// First category should be [0, 0]
	assert result[0] == [0.0, 0.0]
}

fn test_one_hot_encoder_multiple_features() {
	data := [['a', 'x'], ['b', 'y'], ['a', 'x']]

	mut encoder := OneHotEncoder.new(false)
	result := encoder.fit_transform(data)!

	// 2 categories for first feature + 2 for second = 4 columns
	assert result[0].len == 4
}

fn test_one_hot_encoder_get_feature_names() {
	data := [['cat'], ['dog'], ['bird']]

	mut encoder := OneHotEncoder.new(false)
	encoder.fit(data)!

	names := encoder.get_feature_names(['animal'])!

	assert names.len == 3
	assert 'animal_cat' in names
	assert 'animal_dog' in names
	assert 'animal_bird' in names
}

fn test_ordinal_encoder_basic() {
	data := [['low'], ['medium'], ['high'], ['low']]

	mut encoder := OrdinalEncoder.new()
	result := encoder.fit_transform(data)!

	assert encoder.fitted == true
	// Same categories should have same value
	assert result[0][0] == result[3][0]
}

fn test_ordinal_encoder_multiple_features() {
	data := [['a', '1'], ['b', '2'], ['a', '1']]

	mut encoder := OrdinalEncoder.new()
	result := encoder.fit_transform(data)!

	assert result[0].len == 2 // 2 features
	assert result[0] == result[2] // same input -> same output
}

fn test_encoder_not_fitted_error() {
	encoder := LabelEncoder.new()

	if _ := encoder.transform(['a']) {
		assert false, 'should have returned error'
	}
}
