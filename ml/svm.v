module ml

import math
import rand

pub struct SVMConfig {
pub mut:
    max_iterations int = 1000
    learning_rate  f64 = 0.01
    tolerance      f64 = 1e-6
    c              f64 = 1.0
    kernel_type    KernelType = .linear
    kernel_param   f64 = 1.0
}

pub enum KernelType {
    linear
    polynomial
    rbf
    quadratic
    custom
}

pub type KernelFunction = fn ([]f64, []f64) f64

pub struct DataPoint {
pub mut:
    x []f64
    y int
}

pub struct SVMModel {
pub mut:
    support_vectors []DataPoint
    alphas          []f64
    b               f64
    kernel          KernelFunction = linear_kernel
    config          SVMConfig
}

pub struct MulticlassSVM {
pub mut:
    models [][]&SVMModel
}

pub fn linear_kernel(x []f64, y []f64) f64 {
    return dot_product(x, y)
}

pub fn polynomial_kernel(degree f64) KernelFunction {
    return fn [degree] (x []f64, y []f64) f64 {
        return math.pow(dot_product(x, y) + 1.0, degree)
    }
}

pub fn rbf_kernel(gamma f64) KernelFunction {
    return fn [gamma] (x []f64, y []f64) f64 {
        diff := vector_subtract(x, y)
        return math.exp(-gamma * dot_product(diff, diff))
    }
}

pub fn quadratic_kernel(x []f64, y []f64) f64 {
    dot := dot_product(x, y)
    return dot * dot
}

pub fn custom_kernel(x []f64, y []f64) f64 {
    z_x := math.pow(x[0], 2) + math.pow(x[1], 2)
    z_y := math.pow(y[0], 2) + math.pow(y[1], 2)
    return z_x * z_y
}

fn dot_product(a []f64, b []f64) f64 {
    mut sum := 0.0
    for i := 0; i < a.len; i++ {
        sum += a[i] * b[i]
    }
    return sum
}

fn vector_subtract(a []f64, b []f64) []f64 {
    mut result := []f64{len: a.len}
    for i := 0; i < a.len; i++ {
        result[i] = a[i] - b[i]
    }
    return result
}

pub fn train_svm(data []DataPoint, config SVMConfig) &SVMModel {
    kernel := match config.kernel_type {
        .linear { linear_kernel }
        .polynomial { polynomial_kernel(config.kernel_param) }
        .rbf { rbf_kernel(config.kernel_param) }
        .quadratic { quadratic_kernel }
        .custom { custom_kernel }
    }

    mut model := &SVMModel{
        config: config
        kernel: kernel
    }

    mut alphas := []f64{len: data.len, init: 0.0}
    mut b := 0.0

    for _ in 0 .. config.max_iterations {
        mut alpha_pairs_changed := 0

        for i := 0; i < data.len; i++ {
            ei := predict_raw(model, data[i].x) - f64(data[i].y)
            if (data[i].y * ei < -config.tolerance && alphas[i] < config.c) ||
                (data[i].y * ei > config.tolerance && alphas[i] > 0) {
                mut j := rand.intn(data.len - 1) or { 0 }
                if j >= i {
                    j += 1
                }

                ej := predict_raw(model, data[j].x) - f64(data[j].y)

                old_alpha_i, old_alpha_j := alphas[i], alphas[j]
                l, h := compute_l_h(config.c, alphas[i], alphas[j], data[i].y, data[j].y)

                if l == h {
                    continue
                }

                eta := 2 * kernel(data[i].x, data[j].x) - kernel(data[i].x, data[i].x) - kernel(data[j].x, data[j].x)
                if eta >= 0 {
                    continue
                }

                alphas[j] -= f64(data[j].y) * (ei - ej) / eta
                alphas[j] = math.max(l, math.min(h, alphas[j]))

                if math.abs(alphas[j] - old_alpha_j) < 1e-5 {
                    continue
                }

                alphas[i] += f64(data[i].y * data[j].y) * (old_alpha_j - alphas[j])

                b1 := b - ei - data[i].y * (alphas[i] - old_alpha_i) * kernel(data[i].x, data[i].x) -
                    data[j].y * (alphas[j] - old_alpha_j) * kernel(data[i].x, data[j].x)
                b2 := b - ej - data[i].y * (alphas[i] - old_alpha_i) * kernel(data[i].x, data[j].x) -
                    data[j].y * (alphas[j] - old_alpha_j) * kernel(data[j].x, data[j].x)

                if 0 < alphas[i] && alphas[i] < config.c {
                    b = b1
                } else if 0 < alphas[j] && alphas[j] < config.c {
                    b = b2
                } else {
                    b = (b1 + b2) / 2
                }

                alpha_pairs_changed += 1
            }
        }

        if alpha_pairs_changed == 0 {
            break
        }
    }

    model.b = b
    model.alphas = alphas
    mut support_vectors := []DataPoint{}
    for i, d in data {
        if alphas[i] > 0 {
            support_vectors << d
        }
    }
    model.support_vectors = support_vectors

    return model
}

fn compute_l_h(c f64, alpha_i f64, alpha_j f64, y_i int, y_j int) (f64, f64) {
    if y_i != y_j {
        return math.max(0.0, alpha_j - alpha_i), math.min(c, c + alpha_j - alpha_i)
    } else {
        return math.max(0.0, alpha_i + alpha_j - c), math.min(c, alpha_i + alpha_j)
    }
}

pub fn predict_raw(model &SVMModel, x []f64) f64 {
    mut result := 0.0
    for i, sv in model.support_vectors {
        result += model.alphas[i] * f64(sv.y) * model.kernel(x, sv.x)
    }
    return result + model.b
}

pub fn predict(model &SVMModel, x []f64) int {
    return if predict_raw(model, x) >= 0 { 1 } else { -1 }
}

pub fn train_multiclass_svm(data []DataPoint, config SVMConfig) &MulticlassSVM {
    mut classes := []int{}
    for point in data {
        if point.y !in classes {
            classes << point.y
        }
    }

    mut models := [][]&SVMModel{len: classes.len, init: []&SVMModel{}}

    for i := 0; i < classes.len; i++ {
        models[i] = []&SVMModel{len: classes.len, init: 0}
        for j := i + 1; j < classes.len; j++ {
            mut binary_data := []DataPoint{}
            for point in data {
                if point.y == classes[i] || point.y == classes[j] {
                    binary_data << DataPoint{
                        x: point.x
                        y: if point.y == classes[i] { 1 } else { -1 }
                    }
                }
            }
            models[i][j] = train_svm(binary_data, config)
        }
    }

    return &MulticlassSVM{models: models}
}

pub fn predict_multiclass(model &MulticlassSVM, x []f64) int {
    mut votes := map[int]int{}
    for i := 0; i < model.models.len; i++ {
        for j := i + 1; j < model.models.len; j++ {
            prediction := predict(model.models[i][j], x)
            if prediction == 1 {
                votes[i]++
            } else {
                votes[j]++
            }
        }
    }

    mut max_votes := 0
    mut predicted_class := 0
    for class, vote_count in votes {
        if vote_count > max_votes {
            max_votes = vote_count
            predicted_class = class
        }
    }

    return predicted_class
}

