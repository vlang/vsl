module ml

import math
import vsl.la
import vsl.plot
import vsl.errors

// CriterionType represents the splitting criterion
pub enum CriterionType {
	gini    // Gini impurity (for classification)
	entropy // Information gain / entropy (for classification)
	mse     // Mean Squared Error (for regression)
}

// TreeNode represents a node in the decision tree
@[heap]
pub struct TreeNode {
mut:
	feature_index int = -1 // Feature index for split (-1 for leaf)
	threshold     f64 // Threshold value for split
	left          &TreeNode = unsafe { nil } // Left child
	right         &TreeNode = unsafe { nil } // Right child
	value         f64  // Value for leaf nodes (class or regression value)
	is_leaf       bool // Whether this is a leaf node
	samples       int  // Number of samples in this node
}

// DecisionTree implements a decision tree classifier/regressor (Observer of Data)
@[heap]
pub struct DecisionTree {
mut:
	name              string // name of this "observer"
	data              &Data[f64]    = unsafe { nil } // x-y data
	stat              &Stat[f64]    = unsafe { nil } // statistics
	root              &TreeNode     = unsafe { nil } // Root of the tree
	max_depth         int           = -1             // Maximum depth (-1 for unlimited)
	min_samples_split int           = 2              // Minimum samples to split
	min_samples_leaf  int           = 1              // Minimum samples in leaf
	criterion         CriterionType = .gini          // Splitting criterion
	trained           bool
	is_regression     bool // Whether this is a regression task
}

// DecisionTree.new returns a new DecisionTree object
//   Input:
//     data   -- x,y data
//     name   -- unique name of this (observer) object
//   Output:
//     new DecisionTree object
pub fn DecisionTree.new(mut data Data[f64], name string) &DecisionTree {
	if data.y.len == 0 {
		errors.vsl_panic('DecisionTree requires y data', .einval)
	}
	mut stat := Stat.from_data(mut data, 'stat_' + name)
	stat.update()

	// Determine if regression or classification
	mut is_regression := false
	for i in 0 .. data.y.len {
		if data.y[i] != math.floor(data.y[i]) {
			is_regression = true
			break
		}
	}

	mut tree := &DecisionTree{
		name:              name
		data:              data
		stat:              stat
		max_depth:         -1
		min_samples_split: 2
		min_samples_leaf:  1
		criterion:         .gini
		is_regression:     is_regression
	}
	data.add_observer(tree)
	tree.update()
	return tree
}

// name returns the name of this DecisionTree object (thus defining the Observer interface)
pub fn (o &DecisionTree) name() string {
	return o.name
}

// update perform updates after data has been changed (as an Observer)
pub fn (mut o DecisionTree) update() {
	o.trained = false
	o.root = unsafe { nil }
}

// set_max_depth sets the maximum depth of the tree
pub fn (mut o DecisionTree) set_max_depth(depth int) {
	o.max_depth = depth
	o.trained = false
}

// set_min_samples_split sets the minimum samples required to split
pub fn (mut o DecisionTree) set_min_samples_split(min_samples int) {
	if min_samples < 2 {
		errors.vsl_panic('min_samples_split must be at least 2', .einval)
	}
	o.min_samples_split = min_samples
	o.trained = false
}

// set_min_samples_leaf sets the minimum samples in a leaf node
pub fn (mut o DecisionTree) set_min_samples_leaf(min_samples int) {
	if min_samples < 1 {
		errors.vsl_panic('min_samples_leaf must be at least 1', .einval)
	}
	o.min_samples_leaf = min_samples
	o.trained = false
}

// set_criterion sets the splitting criterion
pub fn (mut o DecisionTree) set_criterion(criterion CriterionType) {
	o.criterion = criterion
	o.trained = false
}

// gini_impurity computes Gini impurity for classification
fn gini_impurity(y []f64) f64 {
	if y.len == 0 {
		return 0.0
	}
	mut class_counts := map[f64]int{}
	for label in y {
		class_counts[label]++
	}
	mut gini := 1.0
	for _, count in class_counts {
		prob := f64(count) / f64(y.len)
		gini -= prob * prob
	}
	return gini
}

// entropy computes entropy for classification
fn entropy(y []f64) f64 {
	if y.len == 0 {
		return 0.0
	}
	mut class_counts := map[f64]int{}
	for label in y {
		class_counts[label]++
	}
	mut ent := 0.0
	for _, count in class_counts {
		if count > 0 {
			prob := f64(count) / f64(y.len)
			ent -= prob * math.log2(prob)
		}
	}
	return ent
}

// mse computes Mean Squared Error for regression
fn mse(y []f64) f64 {
	if y.len == 0 {
		return 0.0
	}
	mean := la.vector_accum(y) / f64(y.len)
	mut sum_sq := 0.0
	for val in y {
		diff := val - mean
		sum_sq += diff * diff
	}
	return sum_sq / f64(y.len)
}

// compute_impurity computes impurity based on criterion
fn (o &DecisionTree) compute_impurity(y []f64) f64 {
	match o.criterion {
		.gini {
			return gini_impurity(y)
		}
		.entropy {
			return entropy(y)
		}
		.mse {
			return mse(y)
		}
	}
}

// find_best_split finds the best split for a node
fn (o &DecisionTree) find_best_split(x_indices []int, y []f64) (int, f64, f64) {
	if x_indices.len < o.min_samples_split {
		return -1, 0.0, o.compute_impurity(y)
	}

	mut best_feature := -1
	mut best_threshold := 0.0
	mut best_impurity := math.max_f64
	parent_impurity := o.compute_impurity(y)

	for feature_idx in 0 .. o.data.nb_features {
		// Get unique values for this feature
		mut values := []f64{}
		for idx in x_indices {
			val := o.data.x.get(idx, feature_idx)
			values << val
		}
		values.sort()

		// Try thresholds between consecutive values
		for i in 0 .. values.len - 1 {
			threshold := (values[i] + values[i + 1]) / 2.0

			// Split data
			mut left_indices := []int{}
			mut right_indices := []int{}
			mut left_y := []f64{}
			mut right_y := []f64{}

			for j, idx in x_indices {
				val := o.data.x.get(idx, feature_idx)
				if val <= threshold {
					left_indices << idx
					left_y << y[j]
				} else {
					right_indices << idx
					right_y << y[j]
				}
			}

			if left_indices.len < o.min_samples_leaf || right_indices.len < o.min_samples_leaf {
				continue
			}

			// Compute weighted impurity
			left_impurity := o.compute_impurity(left_y)
			right_impurity := o.compute_impurity(right_y)
			weighted_impurity := (f64(left_indices.len) * left_impurity +
				f64(right_indices.len) * right_impurity) / f64(x_indices.len)

			// For classification, use information gain; for regression, use MSE reduction
			if o.is_regression {
				if weighted_impurity < best_impurity {
					best_impurity = weighted_impurity
					best_feature = feature_idx
					best_threshold = threshold
				}
			} else {
				// Information gain
				info_gain := parent_impurity - weighted_impurity
				if info_gain > 0 && weighted_impurity < best_impurity {
					best_impurity = weighted_impurity
					best_feature = feature_idx
					best_threshold = threshold
				}
			}
		}
	}

	return best_feature, best_threshold, best_impurity
}

// build_tree recursively builds the decision tree
fn (mut o DecisionTree) build_tree(x_indices []int, y []f64, depth int) &TreeNode {
	// Create node
	mut node := &TreeNode{
		samples: x_indices.len
	}

	// Check stopping criteria
	impurity := o.compute_impurity(y)
	should_stop := (o.max_depth >= 0 && depth >= o.max_depth)
		|| x_indices.len < o.min_samples_split || impurity < 1e-10

	if should_stop {
		// Make leaf node
		node.is_leaf = true
		if o.is_regression {
			// Use mean for regression
			node.value = la.vector_accum(y) / f64(y.len)
		} else {
			// Use majority class for classification
			mut class_counts := map[f64]int{}
			for label in y {
				class_counts[label]++
			}
			mut max_count := 0
			mut majority_class := y[0]
			for class, count in class_counts {
				if count > max_count {
					max_count = count
					majority_class = class
				}
			}
			node.value = majority_class
		}
		return node
	}

	// Find best split
	best_feature, best_threshold, _ := o.find_best_split(x_indices, y)

	if best_feature == -1 {
		// No good split found, make leaf
		node.is_leaf = true
		if o.is_regression {
			node.value = la.vector_accum(y) / f64(y.len)
		} else {
			mut class_counts := map[f64]int{}
			for label in y {
				class_counts[label]++
			}
			mut max_count := 0
			mut majority_class := y[0]
			for class, count in class_counts {
				if count > max_count {
					max_count = count
					majority_class = class
				}
			}
			node.value = majority_class
		}
		return node
	}

	// Split data
	mut left_indices := []int{}
	mut right_indices := []int{}
	mut left_y := []f64{}
	mut right_y := []f64{}

	for i, idx in x_indices {
		val := o.data.x.get(idx, best_feature)
		if val <= best_threshold {
			left_indices << idx
			left_y << y[i]
		} else {
			right_indices << idx
			right_y << y[i]
		}
	}

	// Set node properties
	node.feature_index = best_feature
	node.threshold = best_threshold
	node.is_leaf = false

	// Recursively build children
	node.left = o.build_tree(left_indices, left_y, depth + 1)
	node.right = o.build_tree(right_indices, right_y, depth + 1)

	return node
}

// train builds the decision tree
pub fn (mut o DecisionTree) train() {
	if o.data.nb_samples == 0 {
		return
	}

	// Create indices array
	mut x_indices := []int{len: o.data.nb_samples}
	for i in 0 .. o.data.nb_samples {
		x_indices[i] = i
	}

	// Build tree
	o.root = o.build_tree(x_indices, o.data.y, 0)
	o.trained = true
}

// predict_node predicts using a specific node
fn (o &DecisionTree) predict_node(node &TreeNode, x []f64) f64 {
	if node.is_leaf {
		return node.value
	}

	feature_val := x[node.feature_index]
	if feature_val <= node.threshold {
		return o.predict_node(node.left, x)
	} else {
		return o.predict_node(node.right, x)
	}
}

// predict returns the predicted value for a single sample
pub fn (o &DecisionTree) predict(x []f64) f64 {
	if !o.trained {
		errors.vsl_panic('DecisionTree must be trained before prediction', .einval)
	}
	if x.len != o.data.nb_features {
		errors.vsl_panic('predict: x must have ${o.data.nb_features} features, got ${x.len}',
			.einval)
	}
	return o.predict_node(o.root, x)
}

// predict_batch returns predictions for multiple samples
pub fn (o &DecisionTree) predict_batch(x [][]f64) []f64 {
	mut predictions := []f64{cap: x.len}
	for sample in x {
		predictions << o.predict(sample)
	}
	return predictions
}

// str is a custom str function for observers to avoid printing data
pub fn (o &DecisionTree) str() string {
	mut res := []string{}
	res << 'vsl.ml.DecisionTree{'
	res << '    name: ${o.name}'
	res << '    criterion: ${o.criterion}'
	res << '    max_depth: ${o.max_depth}'
	res << '    trained: ${o.trained}'
	res << '    is_regression: ${o.is_regression}'
	res << '}'
	return res.join('\n')
}

// get_plotter returns a plot.Plot struct for plotting (2D only)
pub fn (o &DecisionTree) get_plotter() &plot.Plot {
	if o.data.nb_features != 2 {
		errors.vsl_panic('DecisionTree plotting only supports 2D data', .einval)
	}

	// Create plot
	mut plt := plot.Plot.new()
	plt.layout(
		title: 'Decision Tree'
	)

	// Plot data points
	x_col := o.data.x.get_col(0)
	y_col := o.data.x.get_col(1)

	if o.is_regression {
		plt.scatter(
			name: 'dataset'
			x:    x_col
			y:    y_col
			mode: 'markers'
		)
	} else {
		// Separate by class
		mut class_0_x := []f64{}
		mut class_0_y := []f64{}
		mut class_1_x := []f64{}
		mut class_1_y := []f64{}

		for i in 0 .. o.data.nb_samples {
			label := o.data.y[i]
			if label == 0.0 {
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
	}

	return plt
}
