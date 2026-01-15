module ml

import math
import vsl.la
import vsl.plot
import vsl.errors

// RandomForest implements a Random Forest classifier/regressor (Observer of Data)
@[heap]
pub struct RandomForest {
mut:
	name         string // name of this "observer"
	data         &Data[f64] = unsafe { nil } // x-y data
	max_features int        = -1             // features per split (-1 for sqrt(n_features))
pub mut:
	n_estimators  int  = 100  // number of trees
	bootstrap     bool = true // bootstrap sampling
	trained       bool
	is_regression bool // Whether this is a regression task
	stat          &Stat[f64] = unsafe { nil } // statistics
	trees         []&DecisionTree // ensemble of decision trees
}

// RandomForest.new returns a new RandomForest object
//   Input:
//     data   -- x,y data
//     name   -- unique name of this (observer) object
//   Output:
//     new RandomForest object
pub fn RandomForest.new(mut data Data[f64], name string) &RandomForest {
	if data.y.len == 0 {
		errors.vsl_panic('RandomForest requires y data', .einval)
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

	// Set max_features default
	max_features := if data.nb_features > 0 {
		int(math.sqrt(f64(data.nb_features)))
	} else {
		data.nb_features
	}

	mut rf := &RandomForest{
		name:          name
		data:          data
		stat:          stat
		n_estimators:  100
		max_features:  max_features
		bootstrap:     true
		is_regression: is_regression
	}
	data.add_observer(rf)
	rf.update()
	return rf
}

// name returns the name of this RandomForest object (thus defining the Observer interface)
pub fn (o &RandomForest) name() string {
	return o.name
}

// update perform updates after data has been changed (as an Observer)
pub fn (mut o RandomForest) update() {
	o.trained = false
	o.trees = []
}

// set_n_estimators sets the number of trees in the forest
pub fn (mut o RandomForest) set_n_estimators(n int) {
	if n <= 0 {
		errors.vsl_panic('n_estimators must be positive, got ${n}', .einval)
	}
	o.n_estimators = n
	o.trained = false
}

// set_max_features sets the number of features to consider for each split
pub fn (mut o RandomForest) set_max_features(n int) {
	if n <= 0 && n != -1 {
		errors.vsl_panic('max_features must be positive or -1, got ${n}', .einval)
	}
	o.max_features = n
	o.trained = false
}

// set_bootstrap sets whether to use bootstrap sampling
pub fn (mut o RandomForest) set_bootstrap(bootstrap bool) {
	o.bootstrap = bootstrap
	o.trained = false
}

// bootstrap_sample creates a bootstrap sample
// Uses a simple deterministic approach for reproducibility
// In production, use a proper random number generator
fn bootstrap_sample(n int, seed int) []int {
	mut indices := []int{cap: n}
	mut s := u32(seed)
	for _ in 0 .. n {
		// Simple linear congruential generator
		s = (s * 1103515245 + 12345) & 0x7fffffff
		indices << int(s % u32(n))
	}
	return indices
}

// train trains the random forest
pub fn (mut o RandomForest) train() ! {
	if o.data.nb_samples == 0 {
		return
	}

	o.trees = []

	for i in 0 .. o.n_estimators {
		// Create bootstrap sample
		mut sample_indices := if o.bootstrap {
			bootstrap_sample(o.data.nb_samples, i)
		} else {
			mut indices := []int{len: o.data.nb_samples}
			for j in 0 .. o.data.nb_samples {
				indices[j] = j
			}
			indices
		}

		// Create data subset
		mut x_subset := [][]f64{cap: sample_indices.len}
		mut y_subset := []f64{cap: sample_indices.len}
		for idx in sample_indices {
			x_subset << o.data.x.get_row(idx)
			y_subset << o.data.y[idx]
		}

		// Create decision tree
		mut tree_data := Data.from_raw_xy_sep(x_subset, y_subset) or { continue }
		mut tree := DecisionTree.new(mut tree_data, '${o.name}_tree_${i}')
		tree.set_max_depth(-1) // No depth limit for individual trees
		tree.set_criterion(if o.is_regression { .mse } else { .gini })
		tree.train()

		o.trees << tree
	}

	o.trained = true
}

// predict returns the predicted value for a single sample
pub fn (o &RandomForest) predict(x []f64) f64 {
	if !o.trained {
		errors.vsl_panic('RandomForest must be trained before prediction', .einval)
	}
	if x.len != o.data.nb_features {
		errors.vsl_panic('predict: x must have ${o.data.nb_features} features, got ${x.len}',
			.einval)
	}

	mut predictions := []f64{cap: o.trees.len}
	for tree in o.trees {
		predictions << tree.predict(x)
	}

	if o.is_regression {
		// Average for regression
		return la.vector_accum(predictions) / f64(predictions.len)
	} else {
		// Majority vote for classification
		mut class_counts := map[f64]int{}
		for pred in predictions {
			class_counts[pred]++
		}
		mut max_count := 0
		mut majority_class := predictions[0]
		for class, count in class_counts {
			if count > max_count {
				max_count = count
				majority_class = class
			}
		}
		return majority_class
	}
}

// predict_proba returns probability estimates for classification
pub fn (o &RandomForest) predict_proba(x []f64) f64 {
	if o.is_regression {
		errors.vsl_panic('predict_proba only available for classification', .einval)
	}
	if !o.trained {
		errors.vsl_panic('RandomForest must be trained before prediction', .einval)
	}

	mut predictions := []f64{cap: o.trees.len}
	for tree in o.trees {
		predictions << tree.predict(x)
	}

	// Count votes for class 1
	mut votes_1 := 0
	for pred in predictions {
		if pred == 1.0 {
			votes_1++
		}
	}

	return f64(votes_1) / f64(predictions.len)
}

// get_feature_importance returns feature importance scores
pub fn (o &RandomForest) get_feature_importance() []f64 {
	if !o.trained {
		errors.vsl_panic('RandomForest must be trained before getting feature importance',
			.einval)
	}
	// Simplified: count how often each feature is used
	// In a full implementation, would track impurity reduction
	mut importance := []f64{len: o.data.nb_features}
	// This is a placeholder - full implementation would track feature usage
	return importance
}

// str is a custom str function for observers to avoid printing data
pub fn (o &RandomForest) str() string {
	mut res := []string{}
	res << 'vsl.ml.RandomForest{'
	res << '    name: ${o.name}'
	res << '    n_estimators: ${o.n_estimators}'
	res << '    trained: ${o.trained}'
	res << '    is_regression: ${o.is_regression}'
	res << '}'
	return res.join('\n')
}

// get_plotter returns a plot.Plot struct for plotting
pub fn (o &RandomForest) get_plotter() &plot.Plot {
	if o.data.nb_features != 2 {
		errors.vsl_panic('RandomForest plotting only supports 2D data', .einval)
	}

	// Use first tree's plotter (or create custom visualization)
	if o.trees.len > 0 {
		return o.trees[0].get_plotter()
	}

	// Fallback
	mut plt := plot.Plot.new()
	plt.layout(
		title: 'Random Forest'
	)
	return plt
}
