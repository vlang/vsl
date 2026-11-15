module main

import vsl.metrics
import vsl.ml
import vsl.model_selection

fn logistic_factory(x_train [][]f64, y_train []f64) !model_selection.FoldPrediction {
	mut data := ml.Data.from_raw_xy_sep(x_train, y_train)!
	mut model := ml.LogReg.new(mut data, 'cross_val_logistic')
	model.train(ml.LogRegTrainConfig{
		epochs:        1000
		learning_rate: 0.1
	})
	return fn [model] (x_test [][]f64) ![]f64 {
		mut predictions := []f64{cap: x_test.len}
		for row in x_test {
			probability := model.predict(row)
			predictions << if probability >= 0.5 { 1.0 } else { 0.0 }
		}
		return predictions
	}
}

fn gaussian_nb_factory(x_train [][]f64, y_train []f64) !model_selection.FoldPrediction {
	mut data := ml.Data.from_raw_xy_sep(x_train, y_train)!
	model := ml.GaussianNB.new(mut data, 'cross_val_gaussian_nb')!
	return fn [model] (x_test [][]f64) ![]f64 {
		mut predictions := []f64{cap: x_test.len}
		for row in x_test {
			predictions << model.predict(row)!
		}
		return predictions
	}
}

fn main() {
	run() or { panic(err) }
}

fn run() ! {
	x := [
		[-2.0, -1.0],
		[2.0, 1.0],
		[-1.5, -0.8],
		[1.5, 0.8],
		[-1.2, -1.4],
		[1.2, 1.4],
		[-2.5, -1.2],
		[2.5, 1.2],
		[-0.8, -1.6],
		[0.8, 1.6],
	]
	y := [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
	folds := model_selection.StratifiedKFold.new(5, false, 42).split(y)!

	scorer := fn (y_true []f64, y_pred []f64) !f64 {
		return metrics.accuracy_score(y_true, y_pred)
	}
	candidates := [
		model_selection.CrossValCandidate{
			name:    'Logistic regression'
			factory: logistic_factory
		},
		model_selection.CrossValCandidate{
			name:    'Gaussian Naive Bayes'
			factory: gaussian_nb_factory
		},
	]
	results := model_selection.cross_val_compare(x, y, folds, candidates, 2, scorer)!
	for result in results {
		println('${result.name} fold accuracy: ${result.fold_scores}')
		println('${result.name} mean accuracy: ${result.mean_score:.3f}')
	}
}
