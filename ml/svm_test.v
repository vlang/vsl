module ml

import rand
import math

fn test_linear_kernel() {
    x := [1.0, 2.0]
    y := [2.0, 3.0]
    result := ml.linear_kernel(x, y)
    expected := ml.dot_product(x, y)
    assert math.abs(result - expected) < 1e-6
    println('Linear kernel test passed.')
}

fn test_polynomial_kernel() {
    x := [1.0, 2.0]
    y := [2.0, 3.0]
    degree := 2.0
    kernel_fn := ml.polynomial_kernel(degree)
    result := kernel_fn(x, y)
    expected := math.pow(ml.dot_product(x, y) + 1.0, degree)
    assert math.abs(result - expected) < 1e-6
    println('Polynomial kernel test passed.')
}

fn test_rbf_kernel() {
    x := [1.0, 2.0]
    y := [2.0, 3.0]
    gamma := 0.5
    kernel_fn := ml.rbf_kernel(gamma)
    result := kernel_fn(x, y)
    diff := ml.vector_subtract(x, y)
    expected := math.exp(-gamma * ml.dot_product(diff, diff))
    assert math.abs(result - expected) < 1e-6
    println('RBF kernel test passed.')
}

fn test_quadratic_kernel() {
    x := [1.0, 2.0]
    y := [2.0, 3.0]
    result := ml.quadratic_kernel(x, y)
    expected := math.pow(ml.dot_product(x, y), 2)
    assert math.abs(result - expected) < 1e-6
    println('Quadratic kernel test passed.')
}

fn test_custom_kernel() {
    x := [1.0, 2.0]
    y := [2.0, 3.0]
    result := ml.custom_kernel(x, y)
    z_x := math.pow(x[0], 2) + math.pow(x[1], 2)
    z_y := math.pow(y[0], 2) + math.pow(y[1], 2)
    expected := z_x * z_y
    assert math.abs(result - expected) < 1e-6
    println('Custom kernel test passed.')
}

fn test_dot_product() {
    a := [1.0, 2.0]
    b := [3.0, 4.0]
    result := ml.dot_product(a, b)
    expected := 11.0
    assert math.abs(result - expected) < 1e-6
    println('Dot product test passed.')
}

fn test_vector_subtract() {
    a := [1.0, 2.0]
    b := [3.0, 4.0]
    result := ml.vector_subtract(a, b)
    expected := [-2.0, -2.0]
    assert result == expected
    println('Vector subtract test passed.')
}

fn test_svm() {
    data := [
        ml.DataPoint{x: [2.0, 3.0], y: 1},
        ml.DataPoint{x: [1.0, 2.0], y: -1},
        ml.DataPoint{x: [3.0, 3.0], y: 1},
        ml.DataPoint{x: [2.0, 1.0], y: -1},
    ]

    config := ml.SVMConfig{
        max_iterations: 100,
        learning_rate:  0.01,
        tolerance:      1e-5,
        c:              1.0,
        kernel_type:    .linear,
    }

    model := ml.train_svm(data, config)

    mut predictions := 0
    for point in data {
        pred := ml.predict(model, point.x)
        if pred == point.y {
            predictions += 1
        }
    }

    assert predictions == data.len

    println('SVM model training and prediction test passed.')
}

fn test_multiclass_svm() {
    data := [
        ml.DataPoint{x: [1.0, 2.0], y: 0},
        ml.DataPoint{x: [2.0, 3.0], y: 1},
        ml.DataPoint{x: [3.0, 1.0], y: 2},
        ml.DataPoint{x: [1.5, 2.5], y: 0},
        ml.DataPoint{x: [2.5, 3.5], y: 1},
        ml.DataPoint{x: [3.5, 1.5], y: 2},
    ]

    config := ml.SVMConfig{
        max_iterations: 100,
        learning_rate:  0.01,
        tolerance:      1e-5,
        c:              1.0,
        kernel_type:    .linear,
    }

    multiclass_model := ml.train_multiclass_svm(data, config)

    mut correct_predictions := 0
    for point in data {
        predicted_class := ml.predict_multiclass(multiclass_model, point.x)
        if predicted_class == point.y {
            correct_predictions += 1
        }
    }

    assert correct_predictions == data.len

    println('Multiclass SVM model training and prediction test passed.')
}

fn main() {
    test_linear_kernel()
    test_polynomial_kernel()
    test_rbf_kernel()
    test_quadratic_kernel()
    test_custom_kernel()
    test_dot_product()
    test_vector_subtract()
    test_svm()
    test_multiclass_svm()
}

