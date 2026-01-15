module ml

import math
import vsl.la
import vsl.plot
import vsl.errors

// KernelType represents the type of kernel function
pub enum KernelType {
	linear
	polynomial
	rbf
}

// SVM implements a Support Vector Machine classifier (Observer of Data)
@[heap]
pub struct SVM {
mut:
	name string // name of this "observer"
	data &Data[f64] = unsafe { nil } // x-y data
	// SVM-specific
	support_vector_labels []f64 // labels of support vectors
	alpha                 []f64 // Lagrange multipliers [nb_samples]
	bias                  f64   // bias term
	kernel_type           KernelType = .linear
	degree                int        = 3 // polynomial kernel degree
pub mut:
	trained         bool
	stat            &Stat[f64] = unsafe { nil } // statistics
	support_vectors [][]f64 // support vectors
	c               f64 = 1.0 // regularization parameter
	gamma           f64 = 1.0 // RBF kernel parameter
}

// SVM.new returns a new SVM object
//   Input:
//     data   -- x,y data (y should be -1.0 or 1.0 for SVM)
//     name   -- unique name of this (observer) object
//   Output:
//     new SVM object
pub fn SVM.new(mut data Data[f64], name string) &SVM {
	if data.y.len == 0 {
		errors.vsl_panic('SVM requires y data (binary classification)', .einval)
	}
	mut stat := Stat.from_data(mut data, 'stat_' + name)
	stat.update()
	mut svm := &SVM{
		name:   name
		data:   data
		stat:   stat
		alpha:  []f64{len: data.nb_samples}
		c:      1.0
		gamma:  1.0
		degree: 3
	}
	data.add_observer(svm)
	svm.update()
	return svm
}

// name returns the name of this SVM object (thus defining the Observer interface)
pub fn (o &SVM) name() string {
	return o.name
}

// update perform updates after data has been changed (as an Observer)
pub fn (mut o SVM) update() {
	if o.data.nb_samples == 0 {
		return
	}
	if o.alpha.len != o.data.nb_samples {
		o.alpha = []f64{len: o.data.nb_samples}
	}
	o.trained = false
}

// set_kernel sets the kernel type and parameters
pub fn (mut o SVM) set_kernel(kernel_type KernelType, gamma f64, degree int) {
	o.kernel_type = kernel_type
	o.gamma = gamma
	o.degree = degree
	o.trained = false
}

// set_c sets the regularization parameter C
pub fn (mut o SVM) set_c(c f64) {
	if c <= 0 {
		errors.vsl_panic('SVM C parameter must be positive, got ${c}', .einval)
	}
	o.c = c
	o.trained = false
}

// kernel computes the kernel function K(xi, xj)
fn (o &SVM) kernel(xi []f64, xj []f64) f64 {
	match o.kernel_type {
		.linear {
			return la.vector_dot(xi, xj)
		}
		.polynomial {
			dot := la.vector_dot(xi, xj)
			return math.pow(1.0 + dot, f64(o.degree))
		}
		.rbf {
			diff := la.vector_add(1.0, xi, -1.0, xj)
			norm_sq := la.vector_dot(diff, diff)
			return math.exp(-o.gamma * norm_sq)
		}
	}
}

// train trains the SVM using simplified SMO (Sequential Minimal Optimization)
pub fn (mut o SVM) train(max_iter int, tolerance f64) {
	if o.data.nb_samples == 0 {
		return
	}

	// Convert labels to -1.0 and 1.0 if needed
	mut y := o.data.y.clone()
	for i in 0 .. y.len {
		if y[i] == 0.0 {
			y[i] = -1.0
		} else if y[i] != -1.0 && y[i] != 1.0 {
			y[i] = 1.0 // Convert to 1.0 if not already -1.0 or 1.0
		}
	}

	// Initialize alpha
	for i in 0 .. o.alpha.len {
		o.alpha[i] = 0.0
	}
	o.bias = 0.0

	// Simplified SMO algorithm
	for iter := 0; iter < max_iter; iter++ {
		mut num_changed := 0
		for i in 0 .. o.data.nb_samples {
			xi := o.data.x.get_row(i)
			ei := o.predict_raw(xi) - y[i]

			// Check KKT conditions
			if (y[i] * ei < -tolerance && o.alpha[i] < o.c)
				|| (y[i] * ei > tolerance && o.alpha[i] > 0) {
				// Select second alpha (j) randomly or using heuristics
				mut j := (i + 1) % o.data.nb_samples
				if j == i {
					j = (j + 1) % o.data.nb_samples
				}

				xj := o.data.x.get_row(j)
				ej := o.predict_raw(xj) - y[j]

				// Compute bounds
				mut l_bound := 0.0
				mut h_bound := o.c
				if y[i] == y[j] {
					l_bound = math.max(0.0, o.alpha[i] + o.alpha[j] - o.c)
					h_bound = math.min(o.c, o.alpha[i] + o.alpha[j])
				} else {
					l_bound = math.max(0.0, o.alpha[j] - o.alpha[i])
					h_bound = math.min(o.c, o.c + o.alpha[j] - o.alpha[i])
				}

				if math.abs(l_bound - h_bound) < 1e-10 {
					continue
				}

				// Compute eta (second derivative)
				kii := o.kernel(xi, xi)
				kij := o.kernel(xi, xj)
				kjj := o.kernel(xj, xj)
				eta := kii + kjj - 2.0 * kij

				if eta > 0 {
					// Update alpha[j]
					mut alpha_j_new := o.alpha[j] + y[j] * (ei - ej) / eta
					if alpha_j_new > h_bound {
						alpha_j_new = h_bound
					} else if alpha_j_new < l_bound {
						alpha_j_new = l_bound
					}

					// Update alpha[i]
					alpha_i_old := o.alpha[i]
					alpha_j_old := o.alpha[j]
					o.alpha[j] = alpha_j_new
					o.alpha[i] = o.alpha[i] + y[i] * y[j] * (alpha_j_old - o.alpha[j])

					// Update bias
					b1 := o.bias - ei - y[i] * (o.alpha[i] - alpha_i_old) * kii - y[j] * (o.alpha[j] - alpha_j_old) * kij
					b2 := o.bias - ej - y[i] * (o.alpha[i] - alpha_i_old) * kij - y[j] * (o.alpha[j] - alpha_j_old) * kjj

					if o.alpha[i] > 0 && o.alpha[i] < o.c {
						o.bias = b1
					} else if o.alpha[j] > 0 && o.alpha[j] < o.c {
						o.bias = b2
					} else {
						o.bias = (b1 + b2) / 2.0
					}

					num_changed++
				}
			}
		}

		if num_changed == 0 {
			break
		}
	}

	// Extract support vectors
	o.extract_support_vectors()
	o.trained = true
}

// predict_raw returns the raw prediction (before sign function)
fn (o &SVM) predict_raw(x []f64) f64 {
	mut result := o.bias
	for i in 0 .. o.data.nb_samples {
		if o.alpha[i] > 1e-10 {
			xi := o.data.x.get_row(i)
			result += o.alpha[i] * o.data.y[i] * o.kernel(xi, x)
		}
	}
	return result
}

// predict returns the predicted class (0.0 or 1.0, converted from -1.0/1.0)
pub fn (o &SVM) predict(x []f64) f64 {
	if !o.trained {
		errors.vsl_panic('SVM model must be trained before prediction', .einval)
	}
	if x.len != o.data.nb_features {
		errors.vsl_panic('predict: x must have ${o.data.nb_features} features, got ${x.len}',
			.einval)
	}
	raw := o.predict_raw(x)
	// Convert from -1.0/1.0 to 0.0/1.0 for consistency with other classifiers
	return if raw >= 0.0 { 1.0 } else { 0.0 }
}

// predict_proba returns probability estimate (for soft margin)
pub fn (o &SVM) predict_proba(x []f64) f64 {
	if !o.trained {
		errors.vsl_panic('SVM model must be trained before prediction', .einval)
	}
	raw := o.predict_raw(x)
	// Use sigmoid to convert to probability
	return 1.0 / (1.0 + math.exp(-raw))
}

// extract_support_vectors extracts support vectors (alpha > threshold)
fn (mut o SVM) extract_support_vectors() {
	mut sv := [][]f64{}
	mut sv_labels := []f64{}
	for i in 0 .. o.data.nb_samples {
		if o.alpha[i] > 1e-10 {
			sv << o.data.x.get_row(i)
			// Convert label back to original format if needed
			label := o.data.y[i]
			sv_labels << if label == -1.0 { 0.0 } else { 1.0 }
		}
	}
	o.support_vectors = sv
	o.support_vector_labels = sv_labels
}

// str is a custom str function for observers to avoid printing data
pub fn (o &SVM) str() string {
	mut res := []string{}
	res << 'vsl.ml.SVM{'
	res << '    name: ${o.name}'
	res << '    kernel_type: ${o.kernel_type}'
	res << '    c: ${o.c}'
	res << '    trained: ${o.trained}'
	res << '    n_support_vectors: ${o.support_vectors.len}'
	res << '}'
	return res.join('\n')
}

// get_plotter returns a plot.Plot struct for plotting the data and SVM decision boundary
pub fn (o &SVM) get_plotter() &plot.Plot {
	if o.data.nb_features != 2 {
		errors.vsl_panic('SVM plotting only supports 2D data', .einval)
	}

	// Generate a grid for decision boundary (not used in current implementation)
	// n_points := 50
	// x_values := util.lin_space(min_x, max_x, n_points)
	// y_values := util.lin_space(min_y, max_y, n_points)

	// Create plot
	mut plt := plot.Plot.new()
	plt.layout(
		title: 'Support Vector Machine'
	)

	// Plot data points
	x_col := o.data.x.get_col(0)
	y_col := o.data.x.get_col(1)
	mut class_0_x := []f64{}
	mut class_0_y := []f64{}
	mut class_1_x := []f64{}
	mut class_1_y := []f64{}

	for i in 0 .. o.data.nb_samples {
		label := o.data.y[i]
		if label == 0.0 || label == -1.0 {
			class_0_x << x_col[i]
			class_0_y << y_col[i]
		} else {
			class_1_x << x_col[i]
			class_1_y << y_col[i]
		}
	}

	if class_0_x.len > 0 {
		plt.scatter(
			name: 'class 0'
			x:    class_0_x
			y:    class_0_y
			mode: 'markers'
		)
	}

	if class_1_x.len > 0 {
		plt.scatter(
			name: 'class 1'
			x:    class_1_x
			y:    class_1_y
			mode: 'markers'
		)
	}

	// Plot support vectors
	if o.support_vectors.len > 0 {
		sv_x := o.support_vectors.map(it[0])
		sv_y := o.support_vectors.map(it[1])
		plt.scatter(
			name:   'support vectors'
			x:      sv_x
			y:      sv_y
			mode:   'markers'
			marker: plot.Marker{
				size: []f64{len: sv_x.len, init: 12.0}
			}
		)
	}

	return plt
}
