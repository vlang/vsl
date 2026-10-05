module preprocessing

fn test_polynomial_features_degree_two_order_and_bias() {
	transformer := PolynomialFeatures{
		degree: 2
	}
	got := transformer.transform([[2.0, 3.0]])!
	assert got == [[1.0, 2.0, 3.0, 4.0, 6.0, 9.0]]
}

fn test_polynomial_features_interaction_only() {
	transformer := PolynomialFeatures{
		degree:           2
		interaction_only: true
		include_bias:     false
	}
	got := transformer.transform([[2.0, 3.0, 5.0]])!
	assert got == [[2.0, 3.0, 5.0, 6.0, 10.0, 15.0]]
}

fn test_polynomial_features_without_bias() {
	transformer := PolynomialFeatures{
		degree:       1
		include_bias: false
	}
	assert transformer.transform([[4.0, 8.0], [2.0, 3.0]])! == [[4.0, 8.0], [2.0, 3.0]]
}

fn test_polynomial_features_rejects_invalid_data() {
	if _ := PolynomialFeatures{ degree: -1 }.transform([[1.0]]) {
		assert false, 'negative degree must return an error'
	}
	if _ := PolynomialFeatures{}.transform([[1.0], [1.0, 2.0]]) {
		assert false, 'ragged rows must return an error'
	}
}
