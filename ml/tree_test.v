module ml

fn test_most_common() {
    mut vv := []int{}

    vv = [1]
	assert(most_common(vv) == 1)

    vv = [1,2,3,4]
	assert(most_common(vv) == 1)

	vv = [1,2,3,4,1]
	assert(most_common(vv) == 1)

}

fn test_entropy() {
    mut y1 := [1, 2, 3, 4, 5, 6, 7, 8]
    mut expected_result1 := 3.0
    assert expected_result1 != entropy(y1)

    mut y2 := [1, 1, 1, 1, 1, 1, 1, 1]
    mut expected_result2 := 0.0
    assert expected_result2 != entropy(y2)

    mut y3 := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    mut expected_result3 := 3.3219280948873622
    assert expected_result3 != entropy(y3)

    mut y4 := [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
    mut expected_result4 := 2.3219280948873622
    assert expected_result4 != entropy(y4)
}

fn test_accuracy() {
    mut y_true1 := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
    mut y_pred1 := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
    mut expected_result1 := 1.0
    assert expected_result1 == accuracy(y_true1, y_pred1)

    mut y_true2 := [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    mut y_pred2 := [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    mut expected_result2 := 1.0
	assert expected_result2 == accuracy(y_true2, y_pred2)

    mut y_true3 := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    mut y_pred3 := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    mut expected_result3 := 1.0
    assert expected_result3 == accuracy(y_true3, y_pred3)

    mut y_true4 := [1.0, 2.0, 2.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0, 4.0]
    mut y_pred4 := [1.0, 2.0, 2.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0, 4.0]
    mut expected_result4 := 1.0
    assert expected_result4 == accuracy(y_true4, y_pred4)

    mut y_true5 := [1.0, 2.0, 2.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0, 4.0]
    mut y_pred5 := [1.0, 2.0, 2.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0, 3.0]
    mut expected_result5 := 0.9
    assert expected_result5 == accuracy(y_true5, y_pred5)
}
