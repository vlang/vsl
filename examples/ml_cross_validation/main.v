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

fn mean(values []f64) f64 {
	mut sum := 0.0
	for value in values {
		sum += value
	}
	return sum / f64(values.len)
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
	logistic_scores := model_selection.cross_val_score_with_factory(x, y, folds,
		logistic_factory, scorer)!
	gaussian_nb_scores := model_selection.cross_val_score_with_factory(x, y, folds,
		gaussian_nb_factory, scorer)!

	println('Logistic regression fold accuracy: ${logistic_scores}')
	println('Logistic regression mean accuracy: ${mean(logistic_scores):.3f}')
	println('Gaussian Naive Bayes fold accuracy: ${gaussian_nb_scores}')
	println('Gaussian Naive Bayes mean accuracy: ${mean(gaussian_nb_scores):.3f}')
}
